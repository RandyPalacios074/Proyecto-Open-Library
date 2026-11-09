import SwiftData

@MainActor
protocol FavoriteBooksStore {
    func savedBookIDs() throws -> Set<String>
    func savedBookSummaries() throws -> [Book]
    func save(_ book: Book) throws -> Bool
    func delete(_ book: Book) throws -> Bool
}

@MainActor
final class SavedBooksRepository: FavoriteBooksStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func savedBooks() throws -> [SavedBook] {
        try context.fetch(FetchDescriptor<SavedBook>())
    }

    func savedBookIDs() throws -> Set<String> {
        Set(try savedBooks().map(\.bookID))
    }

    func savedBookSummaries() throws -> [Book] {
        try savedBooks().map { $0.asBook() }
    }

    @discardableResult
    func save(_ book: Book) throws -> Bool {
        guard try !savedBooks().contains(where: { $0.bookID == book.id }) else {
            return false
        }

        context.insert(SavedBook(book: book))
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            throw error
        }
    }

    @discardableResult
    func delete(_ book: Book) throws -> Bool {
        let matches = try savedBooks().filter { $0.bookID == book.id }
        guard !matches.isEmpty else { return false }

        for savedBook in matches {
            context.delete(savedBook)
        }

        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            throw error
        }
    }
}
