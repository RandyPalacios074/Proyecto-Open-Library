import Foundation

struct OpenLibrarySearchResponse: Decodable, Sendable {
    let docs: [OpenLibraryBookDTO]
}

struct OpenLibraryBookDTO: Decodable, Sendable {
    let key: String
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverID: Int?
    let subject: [String]?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverID = "cover_i"
        case subject
    }

    func asBook() -> Book {
        let authors = (authorName ?? []).joined(separator: ", ")
        let workID = key.hasPrefix("/") ? key : "/works/\(key)"
        let validCoverID = coverID.flatMap { $0 > 0 ? $0 : nil }

        return Book(
            title: title,
            author: authors.isEmpty ? "Autor desconocido" : authors,
            year: firstPublishYear.map(String.init),
            hasCover: validCoverID != nil,
            isSaved: false,
            themes: Array((subject ?? []).prefix(3)),
            id: workID,
            coverID: validCoverID
        )
    }
}


struct OpenLibraryWorkDetails: Sendable {
    let description: String?
    let themes: [String]
    let coverID: Int?
}

struct OpenLibraryWorkResponse: Decodable {
    let description: OpenLibraryWorkDescription?
    let subjects: [String]?
    let covers: [Int]?

    func asDetails() -> OpenLibraryWorkDetails {
        let descriptionText = description?.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return OpenLibraryWorkDetails(
            description: descriptionText?.isEmpty == false ? descriptionText : nil,
            themes: Array((subjects ?? []).filter { !$0.isEmpty }.prefix(3)),
            coverID: covers?.first(where: { $0 > 0 })
        )
    }
}

struct OpenLibraryWorkDescription: Decodable {
    let text: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let plain = try? container.decode(String.self) {
            text = plain
        } else {
            let typed = try container.decode(DescriptionValue.self)
            text = typed.value
        }
    }

    private struct DescriptionValue: Decodable {
        let value: String
    }
}
