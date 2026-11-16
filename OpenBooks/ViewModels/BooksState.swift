import Foundation
import Observation

@MainActor
@Observable
final class BooksState {
    private let store: FavoriteBooksStore
    var books: [Book]
    var showingPersistenceError = false
    var persistenceErrorMessage = ""

    init(store: FavoriteBooksStore, books: [Book] = []) {
        self.store = store
        self.books = books
    }

    func loadFavorites() {
        do {
            try refreshFavorites()
            clearPersistenceError()
        } catch {
            showPersistenceError(error)
        }
    }

    func addSearchResults(_ results: [Book]) -> [Int] {
        var indices: [Int] = []
        for book in results {
            if let index = books.firstIndex(where: { $0.id == book.id }) {
                let previous = books[index]
                let updated = Book(
                    title: book.title,
                    author: book.author,
                    year: book.year ?? previous.year,
                    hasCover: book.hasCover || previous.hasCover,
                    isSaved: previous.isSaved,
                    synopsis: book.synopsis ?? previous.synopsis,
                    genre: book.genre ?? previous.genre,
                    themes: book.themes.isEmpty ? previous.themes : book.themes,
                    id: book.id,
                    coverID: book.coverID ?? previous.coverID
                )
                books[index] = updated
                if updated.isSaved && updated.coverID != previous.coverID {
                    do {
                        try store.updateMetadata(updated)
                    } catch {
                        showPersistenceError(error)
                    }
                }
                if !indices.contains(index) {
                    indices.append(index)
                }
            } else {
                books.append(book)
                indices.append(books.count - 1)
            }
        }
        return indices
    }

    func applyWorkDetails(_ details: OpenLibraryWorkDetails, at index: Int) {
        guard books.indices.contains(index) else { return }
        let book = books[index]
        let updated = Book(
            title: book.title,
            author: book.author,
            year: book.year,
            hasCover: book.hasCover || details.coverID != nil,
            isSaved: book.isSaved,
            synopsis: details.description ?? book.synopsis,
            genre: book.genre,
            themes: details.themes.isEmpty ? book.themes : details.themes,
            id: book.id,
            coverID: book.coverID ?? details.coverID
        )
        books[index] = updated

        if updated.isSaved {
            do {
                try store.updateMetadata(updated)
            } catch {
                showPersistenceError(error)
            }
        }
    }

    func toggleSaved(at index: Int) -> Bool {
        guard books.indices.contains(index) else { return false }

        do {
            let book = books[index]
            if book.isSaved {
                _ = try store.delete(book)
            } else {
                _ = try store.save(book)
            }
            try refreshFavorites()
            clearPersistenceError()
            return true
        } catch {
            showPersistenceError(error)
            return false
        }
    }

    func clearPersistenceError() {
        showingPersistenceError = false
        persistenceErrorMessage = ""
    }

    private func refreshFavorites() throws {
        let savedBooks = try store.savedBookSummaries()
        let savedIDs = Set(savedBooks.map(\.id))
        for savedBook in savedBooks where !books.contains(where: { $0.id == savedBook.id }) {
            books.append(savedBook)
        }
        for index in books.indices {
            books[index].isSaved = savedIDs.contains(books[index].id)
        }
    }

    private func showPersistenceError(_ error: Error) {
        persistenceErrorMessage = error.localizedDescription
        showingPersistenceError = true
    }
}
