import Foundation

protocol BookSearchService: Sendable {
    func searchBooks(query: String) async throws -> [Book]
}

enum BookSearchError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding
    case connectivity(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "No se pudo construir la dirección de búsqueda."
        case .invalidResponse:
            return "La respuesta del servidor no es válida."
        case .httpStatus(let code):
            return "Open Library respondió con el código HTTP \(code)."
        case .decoding:
            return "No se pudo interpretar la información de Open Library."
        case .connectivity(let message):
            return "No se pudo conectar con Open Library: \(message)"
        }
    }
}

struct OpenLibraryBookSearchService: BookSearchService {
    func searchBooks(query: String) async throws -> [Book] {
        var components = URLComponents(string: "https://openlibrary.org/search.json")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "fields", value: "key,title,author_name,first_publish_year,cover_i"),
            URLQueryItem(name: "limit", value: "15")
        ]

        guard let url = components?.url else {
            throw BookSearchError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("OpenBooks/1.0 (educational iOS application)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            throw BookSearchError.connectivity(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BookSearchError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw BookSearchError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
                .docs.map { $0.asBook() }
        } catch {
            throw BookSearchError.decoding
        }
    }
}


@MainActor
protocol BookDetailsService {
    func details(for bookID: String) async throws -> OpenLibraryWorkDetails?
}

@MainActor
final class OpenLibraryBookDetailsService: BookDetailsService {
    private var cache: [String: OpenLibraryWorkDetails] = [:]
    private var requests: [String: Task<OpenLibraryWorkDetails?, Error>] = [:]

    func details(for bookID: String) async throws -> OpenLibraryWorkDetails? {
        if let cached = cache[bookID] { return cached }
        if let running = requests[bookID] { return try await running.value }

        let task = Task { try await Self.fetchDetails(for: bookID) }
        requests[bookID] = task
        defer { requests[bookID] = nil }

        let result = try await task.value
        if let result { cache[bookID] = result }
        return result
    }

    private static func fetchDetails(for bookID: String) async throws -> OpenLibraryWorkDetails? {
        let workID = bookID.replacingOccurrences(of: "/works/", with: "")
        guard bookID == "/works/\(workID)",
              workID.range(of: #"^OL[0-9]+W$"#, options: .regularExpression) != nil,
              let url = URL(string: "https://openlibrary.org/works/\(workID).json") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("OpenBooks/1.0 (educational iOS application)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            throw BookSearchError.connectivity(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw BookSearchError.invalidResponse
        }
        if http.statusCode == 404 { return nil }
        guard (200...299).contains(http.statusCode) else {
            throw BookSearchError.httpStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(OpenLibraryWorkResponse.self, from: data).asDetails()
        } catch {
            throw BookSearchError.decoding
        }
    }
}
