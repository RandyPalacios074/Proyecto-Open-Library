import XCTest
import SwiftData
@testable import OpenBooks

@MainActor
final class SavedBooksRepositoryTests: XCTestCase {
    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: SavedBook.self, configurations: configuration)
    }

    func testSavingBookMakesItAvailableInAnotherContext() throws {
        let container = try makeContainer()
        let first = SavedBooksRepository(context: ModelContext(container))
        XCTAssertTrue(try first.save(mockBooks[2]))

        let second = SavedBooksRepository(context: ModelContext(container))
        XCTAssertEqual(try second.savedBooks().map(\.bookID), [mockBooks[2].id])

        let state = BooksState(store: second)
        state.loadFavorites()
        XCTAssertTrue(state.books[2].isSaved)
    }

    func testSavingTheSameBookTwiceDoesNotDuplicateIt() throws {
        let container = try makeContainer()
        let repository = SavedBooksRepository(context: ModelContext(container))
        XCTAssertTrue(try repository.save(mockBooks[2]))
        XCTAssertFalse(try repository.save(mockBooks[2]))
        XCTAssertEqual(try repository.savedBooks().count, 1)
    }

    func testRemovingBookLeavesAnEmptyCollection() throws {
        let container = try makeContainer()
        let repository = SavedBooksRepository(context: ModelContext(container))
        try repository.save(mockBooks[2])
        XCTAssertTrue(try repository.delete(mockBooks[2]))
        XCTAssertTrue(try repository.savedBooks().isEmpty)
        XCTAssertFalse(try repository.delete(mockBooks[2]))
    }

    func testTogglingBookUpdatesFavorites() throws {
        let container = try makeContainer()
        let repository = SavedBooksRepository(context: ModelContext(container))
        let state = BooksState(store: repository)

        state.loadFavorites()
        XCTAssertTrue(state.toggleSaved(at: 2))
        XCTAssertTrue(state.books[2].isSaved)
        XCTAssertEqual(try repository.savedBooks().count, 1)

        XCTAssertTrue(state.toggleSaved(at: 2))
        XCTAssertFalse(state.books[2].isSaved)
        XCTAssertTrue(try repository.savedBooks().isEmpty)
    }

    func testUnavailableStoreShowsAnError() {
        let state = BooksState(store: UnavailableFavoritesStore())
        state.loadFavorites()
        XCTAssertTrue(state.showingPersistenceError)
        XCTAssertFalse(state.persistenceErrorMessage.isEmpty)
    }

    func testFailedSaveDoesNotChangeFavoriteState() {
        let state = BooksState(store: UnavailableFavoritesStore())
        XCTAssertFalse(state.toggleSaved(at: 2))
        XCTAssertFalse(state.books[2].isSaved)
        XCTAssertTrue(state.showingPersistenceError)
    }

    func testInvalidIndexDoesNotChangeSavedBooks() throws {
        let container = try makeContainer()
        let repository = SavedBooksRepository(context: ModelContext(container))
        let state = BooksState(store: repository)
        XCTAssertFalse(state.toggleSaved(at: -1))
        XCTAssertTrue(try repository.savedBooks().isEmpty)
    }
}

@MainActor
private struct UnavailableFavoritesStore: FavoriteBooksStore {
    func savedBookIDs() throws -> Set<String> {
        throw TestStorageError.unavailable
    }

    func save(_ book: Book) throws -> Bool {
        throw TestStorageError.unavailable
    }

    func delete(_ book: Book) throws -> Bool {
        throw TestStorageError.unavailable
    }
}

private enum TestStorageError: Error {
    case unavailable
}
