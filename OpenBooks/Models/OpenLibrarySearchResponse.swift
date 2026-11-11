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
