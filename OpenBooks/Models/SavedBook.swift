import SwiftData

@Model
final class SavedBook {
    @Attribute(.unique) var bookID: String
    var title: String
    var author: String
    var year: String?
    var hasCover: Bool
    var coverID: Int?
    var themes: [String]?

    init(book: Book) {
        bookID = book.id
        title = book.title
        author = book.author
        year = book.year
        hasCover = book.hasCover
        coverID = book.coverID
        themes = book.themes
    }

    func asBook() -> Book {
        Book(
            title: title,
            author: author,
            year: year,
            hasCover: hasCover,
            isSaved: true,
            themes: themes ?? [],
            id: bookID,
            coverID: coverID
        )
    }
}
