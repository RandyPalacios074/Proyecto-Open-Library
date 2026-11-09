import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    var searchText = ""
    private(set) var state: SearchViewState = .noResults
    private(set) var resultIndices: [Int] = []

    private let service: any BookSearchService
    private let booksState: BooksState

    init(service: any BookSearchService, booksState: BooksState) {
        self.service = service
        self.booksState = booksState
    }

    func searchBooks() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        resultIndices = []

        guard !query.isEmpty else {
            state = .noResults
            return
        }

        state = .loading
        do {
            let results = try await service.searchBooks(query: query)
            try Task.checkCancellation()
            resultIndices = booksState.addSearchResults(results)
            state = resultIndices.isEmpty ? .noResults : .content
        } catch {
            if Task.isCancelled { return }
            state = .error(error.localizedDescription)
        }
    }
}
