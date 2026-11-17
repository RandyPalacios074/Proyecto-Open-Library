import SwiftData

@MainActor
protocol FavoriteBooksStore {
    func savedBookIDs() throws -> Set<String>
    func savedBookSummaries() throws -> [Book]
    func save(_ book: Book) throws -> Bool
    func delete(_ book: Book) throws -> Bool
    func updateMetadata(_ book: Book) throws
}

@MainActor
extension FavoriteBooksStore {
    func updateMetadata(_ book: Book) throws {}
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

    func updateMetadata(_ book: Book) throws {
        let saved = try savedBooks().filter { $0.bookID == book.id }
        guard !saved.isEmpty else { return }

        for item in saved {
            if let coverID = book.coverID {
                item.coverID = coverID
                item.hasCover = true
            }
            if !book.themes.isEmpty {
                item.themes = book.themes
            }
        }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

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
