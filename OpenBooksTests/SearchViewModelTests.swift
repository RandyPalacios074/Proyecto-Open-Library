import XCTest
@testable import OpenBooks

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testSuccessfulSearchShowsRemoteResults() async {
        let book = Book(title: "El hobbit", author: "J. R. R. Tolkien", year: "1937",
                        hasCover: true, isSaved: false, id: "/works/OL100W", coverID: 25)
        let state = makeBooksState()
        let viewModel = SearchViewModel(service: TestSearchService(books: [book]), booksState: state)
        viewModel.searchText = "El hobbit"

        await viewModel.searchBooks()

        XCTAssertEqual(viewModel.state, .content)
        XCTAssertEqual(viewModel.resultIndices.count, 1)
        XCTAssertEqual(state.books[viewModel.resultIndices[0]].id, "/works/OL100W")
        XCTAssertEqual(state.books[viewModel.resultIndices[0]].title, "El hobbit")
    }

    func testSearchShowsLoadingBeforeNavigationAndEmptyOnlyAfterResponse() async {
        let viewModel = SearchViewModel(
            service: TestSearchService(books: []), booksState: makeBooksState()
        )
        viewModel.searchText = "Libro inexistente"

        viewModel.prepareForSearch()

        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertTrue(viewModel.resultIndices.isEmpty)

        await viewModel.searchBooks()

        XCTAssertEqual(viewModel.state, .noResults)
    }

    func testSuccessfulSearchWithoutBooksShowsEmptyState() async {
        let viewModel = SearchViewModel(service: TestSearchService(books: []), booksState: makeBooksState())
        viewModel.searchText = "Libro que no existe"

        await viewModel.searchBooks()

        XCTAssertEqual(viewModel.state, .noResults)
        XCTAssertTrue(viewModel.resultIndices.isEmpty)
    }

    func testFailedRequestShowsError() async {
        let viewModel = SearchViewModel(service: TestSearchService(error: .unavailable), booksState: makeBooksState())
        viewModel.searchText = "Harry Potter"

        await viewModel.searchBooks()

        guard case .error(let message) = viewModel.state else {
            XCTFail("Se esperaba el estado de error")
            return
        }
        XCTAssertFalse(message.isEmpty)
        XCTAssertTrue(viewModel.resultIndices.isEmpty)
    }

    func testEmptyInputDoesNotReturnBooks() async {
        let viewModel = SearchViewModel(service: TestSearchService(books: [mockBooks[2]]), booksState: makeBooksState())
        viewModel.searchText = "   "

        await viewModel.searchBooks()

        XCTAssertEqual(viewModel.state, .noResults)
        XCTAssertTrue(viewModel.resultIndices.isEmpty)
    }

    func testSecondSearchReplacesPreviousResults() async {
        let state = makeBooksState()
        let viewModel = SearchViewModel(service: TestSearchService(books: [mockBooks[2]]), booksState: state)
        viewModel.searchText = "1984"
        await viewModel.searchBooks()
        XCTAssertEqual(viewModel.resultIndices.count, 1)

        viewModel.searchText = "   "
        await viewModel.searchBooks()

        XCTAssertEqual(viewModel.state, .noResults)
        XCTAssertTrue(viewModel.resultIndices.isEmpty)
    }

    func testSameRemoteBookDoesNotDuplicateSharedCollection() async {
        let book = Book(title: "El hobbit", author: "J. R. R. Tolkien", year: "1937",
                        hasCover: false, isSaved: false, id: "/works/OL100W")
        let state = makeBooksState()
        let viewModel = SearchViewModel(service: TestSearchService(books: [book, book]), booksState: state)
        viewModel.searchText = "El hobbit"
        await viewModel.searchBooks()
        let count = state.books.count
        await viewModel.searchBooks()

        XCTAssertEqual(state.books.count, count)
        XCTAssertEqual(viewModel.resultIndices.count, 1)
    }

    func testSearchDoesNotEraseExistingCoverOrDescription() async {
        let first = Book(title: "El hobbit", author: "Tolkien", year: "1937",
                         hasCover: true, isSaved: false,
                         synopsis: "Una aventura.", id: "/works/OL100W", coverID: 25)
        let incomplete = Book(title: "El hobbit", author: "Tolkien", year: nil,
                              hasCover: false, isSaved: false,
                              id: "/works/OL100W")
        let state = makeBooksState()
        let original = SearchViewModel(service: TestSearchService(books: [first]), booksState: state)
        original.searchText = "El hobbit"
        await original.searchBooks()

        let second = SearchViewModel(service: TestSearchService(books: [incomplete]), booksState: state)
        second.searchText = "El hobbit"
        await second.searchBooks()

        let book = state.books[second.resultIndices[0]]
        XCTAssertEqual(book.coverID, 25)
        XCTAssertEqual(book.year, "1937")
        XCTAssertEqual(book.synopsis, "Una aventura.")
        XCTAssertTrue(book.hasCover)
    }

    private func makeBooksState() -> BooksState {
        BooksState(store: SearchTestFavoritesStore())
    }
}

private enum SearchTestError: Error {
    case unavailable
}

private struct TestSearchService: BookSearchService {
    var books: [Book] = []
    var error: SearchTestError?

    func searchBooks(query: String) async throws -> [Book] {
        if let error { throw error }
        return books
    }
}

@MainActor
private struct SearchTestFavoritesStore: FavoriteBooksStore {
    func savedBookIDs() throws -> Set<String> { [] }
    func savedBookSummaries() throws -> [Book] { [] }
    func save(_ book: Book) throws -> Bool { true }
    func delete(_ book: Book) throws -> Bool { true }
}
