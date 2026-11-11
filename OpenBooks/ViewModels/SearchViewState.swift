enum SearchViewState: Equatable {
    case loading
    case content
    case noResults
    case error(String)
}
