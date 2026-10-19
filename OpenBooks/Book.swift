import SwiftUI
import Observation

struct Book {
    let title: String
    let author: String
    let year: String?
    let hasCover: Bool
    var isSaved: Bool
}

@Observable
class BooksState {
    var books: [Book] = mockBooks

    func toggleSaved(at index: Int) {
        books[index].isSaved.toggle()
    }
}

enum SearchViewState {
    case loading
    case content
    case noResults
    case error
}
