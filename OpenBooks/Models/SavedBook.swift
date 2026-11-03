import SwiftData

@Model
final class SavedBook {
    @Attribute(.unique) var bookID: String
    var title: String
    var author: String
    var year: String?
    var hasCover: Bool

    init(book: Book) {
        bookID = book.id
        title = book.title
        author = book.author
        year = book.year
        hasCover = book.hasCover
    }
}
