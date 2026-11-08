import Foundation
import Observation

@MainActor
@Observable
final class BooksState {
    private let store: any FavoriteBooksStore
    var books: [Book]
    var showingPersistenceError = false
    var persistenceErrorMessage = ""

    init(store: any FavoriteBooksStore, books: [Book] = mockBooks) {
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
        let savedIDs = try store.savedBookIDs()
        for index in books.indices {
            books[index].isSaved = savedIDs.contains(books[index].id)
        }
    }

    private func showPersistenceError(_ error: Error) {
        persistenceErrorMessage = error.localizedDescription
        showingPersistenceError = true
    }
}
