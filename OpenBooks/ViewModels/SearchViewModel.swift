import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    var searchText = ""
    private(set) var state: SearchViewState = .noResults
    private(set) var resultIndices: [Int] = []

    private let service: BookSearchService
    private let booksState: BooksState
    private let suggestionsCacheKey: String?

    init(service: BookSearchService, booksState: BooksState,
         cacheSuggestions: Bool = false) {
        self.service = service
        self.booksState = booksState
        self.suggestionsCacheKey = cacheSuggestions ? "OpenBooks.Suggestions.v1" : nil
    }

    func prepareForSearch() {
        resultIndices = []
        state = .loading
    }

    func restoreCachedSuggestions() {
        guard let suggestionsCacheKey,
              let data = UserDefaults.standard.data(forKey: suggestionsCacheKey),
              let stored = try? JSONDecoder().decode([Book].self, from: data),
              !stored.isEmpty else { return }
        resultIndices = booksState.addSearchResults(stored)
        state = resultIndices.isEmpty ? .noResults : .content
    }

    func searchBooks(retainingResults: Bool = false) async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !retainingResults { resultIndices = [] }

        guard !query.isEmpty else {
            state = .noResults
            return
        }

        if resultIndices.isEmpty { state = .loading }
        do {
            let results = try await service.searchBooks(query: query)
            try Task.checkCancellation()
            if !results.isEmpty || resultIndices.isEmpty {
                resultIndices = booksState.addSearchResults(results)
            }
            state = resultIndices.isEmpty ? .noResults : .content
            if let suggestionsCacheKey, !results.isEmpty {
                let items = results.map { book in
                    Book(title: book.title, author: book.author, year: book.year,
                         hasCover: book.hasCover, isSaved: false,
                         synopsis: book.synopsis, genre: book.genre,
                         themes: book.themes, id: book.id, coverID: book.coverID)
                }
                if let data = try? JSONEncoder().encode(items) {
                    UserDefaults.standard.set(data, forKey: suggestionsCacheKey)
                }
            }
        } catch {
            if Task.isCancelled { return }
            state = resultIndices.isEmpty ? .error(error.localizedDescription) : .content
        }
    }
}
