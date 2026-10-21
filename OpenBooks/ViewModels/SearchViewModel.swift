
import Observation

@Observable
final class SearchViewModel {
    var searchText: String = ""
    var state: SearchViewState = .content
    var resultIndices: [Int] = []

    func searchBooks() {
        if searchText == "Harry Potter" {
            resultIndices = Array(3..<7)
            state = .content
        } else if searchText == "Orgullo y prejuicio" {
            resultIndices = Array(7..<10)
            state = .content
        } else {
            resultIndices = []
            state = .noResults
        }
    }
}
