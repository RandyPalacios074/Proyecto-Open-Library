import Observation

@MainActor
@Observable
final class BooksState {
    var books: [Book] = mockBooks

    func loadFavorites(using repository: SavedBooksRepository) throws {
        let savedIDs = Set(try repository.savedBooks().map(\.bookID))
        for index in books.indices {
            books[index].isSaved = savedIDs.contains(books[index].id)
        }
    }

    func toggleSaved(at index: Int, using repository: SavedBooksRepository) throws {
        guard books.indices.contains(index) else { return }

        let book = books[index]
        if book.isSaved {
            try repository.delete(book)
        } else {
            try repository.save(book)
        }

        try loadFavorites(using: repository)
    }
}
