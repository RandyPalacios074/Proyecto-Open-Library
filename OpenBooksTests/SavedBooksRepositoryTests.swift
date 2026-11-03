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

        let state = BooksState()
        try state.loadFavorites(using: second)
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

    func testInvalidIndexDoesNotChangeSavedBooks() throws {
        let container = try makeContainer()
        let repository = SavedBooksRepository(context: ModelContext(container))
        let state = BooksState()
        try state.toggleSaved(at: -1, using: repository)
        XCTAssertTrue(try repository.savedBooks().isEmpty)
    }
}
