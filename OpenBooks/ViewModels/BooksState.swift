import Foundation
import Observation

@MainActor
@Observable
final class BooksState {
    private let store: any FavoriteBooksStore
    var books: [Book]
    var showingPersistenceError = false
    var persistenceErrorMessage = ""

    init(store: any FavoriteBooksStore, books: [Book] = []) {
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
                var updated = book
                updated.isSaved = books[index].isSaved
                books[index] = updated
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

    @discardableResult
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
