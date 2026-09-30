import SwiftUI

struct Book {
    let title: String
    let author: String
    let year: String?
    let hasCover: Bool
    var isSaved: Bool
}

enum AppScreen {
    case home
    case results
    case detail
    case myBooks
}

enum ResultsState {
    case loading
    case content
    case noResults
    case error
}
