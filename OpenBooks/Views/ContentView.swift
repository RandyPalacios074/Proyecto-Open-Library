import SwiftUI

struct ContentView: View {
    let booksState: BooksState
    @State var path: [Int] = []
    @State var showingMyBooks = false
    @State private var searchViewModel: SearchViewModel
    @State private var suggestionsViewModel: SearchViewModel
    @State private var suggestionsStarted = false
    @State private var activeSearch: Task<Void, Never>?

    let resultsRoute = -1
    let searchRoute = -2

    init(booksState: BooksState, searchService: any BookSearchService) {
        self.booksState = booksState
        _searchViewModel = State(initialValue: SearchViewModel(
            service: searchService,
            booksState: booksState
        ))
        let suggestions = SearchViewModel(service: searchService, booksState: booksState)
        suggestions.searchText = "subject:fiction"
        _suggestionsViewModel = State(initialValue: suggestions)
    }

    var body: some View {
        @Bindable var search = searchViewModel
        @Bindable var favorites = booksState

        NavigationStack(path: $path) {
            ZStack {
                if showingMyBooks {
                    MyBooksView(
                        books: booksState.books,
                        onHome: { showingMyBooks = false },
                        onSearch: {
                            showingMyBooks = false
                            path.append(searchRoute)
                        }
                    )
                } else {
                    HomeView(
                        books: booksState.books,
                        suggestionIndices: suggestionsViewModel.resultIndices,
                        suggestionsState: suggestionsStarted ? suggestionsViewModel.state : .loading,
                        onRetrySuggestions: {
                            Task { await suggestionsViewModel.searchBooks() }
                        },
                        onOpenSearch: { path.append(searchRoute) },
                        onMyBooks: { showingMyBooks = true }
                    )
                }
            }
            .navigationDestination(for: Int.self) { route in
                if route == searchRoute {
                    SearchView(
                        searchText: $search.searchText,
                        onSearch: { searchBooks() }
                    )
                } else if route == resultsRoute {
                    SearchResultsView(
                        resultIndices: searchViewModel.resultIndices,
                        books: booksState.books,
                        state: searchViewModel.state,
                        onOpenSearch: { path.append(searchRoute) },
                        onRetry: { searchBooks() },
                        onHome: {
                            path = []
                            showingMyBooks = false
                        },
                        onMyBooks: {
                            path = []
                            showingMyBooks = true
                        }
                    )
                } else if booksState.books.indices.contains(route) {
                    BookDetailView(
                        book: booksState.books[route],
                        homeActive: !showingMyBooks,
                        onSaveOrDelete: {
                            if booksState.toggleSaved(at: route) {
                                path = []
                                showingMyBooks = true
                            }
                        },
                        onHome: {
                            path = []
                            showingMyBooks = false
                        },
                        onMyBooks: {
                            path = []
                            showingMyBooks = true
                        }
                    )
                }
            }
        }
        .onAppear {
            booksState.loadFavorites()
            if !suggestionsStarted {
                suggestionsStarted = true
                Task { await suggestionsViewModel.searchBooks() }
            }
        }
        .alert("No se pudieron actualizar los favoritos", isPresented: $favorites.showingPersistenceError) {
            Button("Aceptar", role: .cancel) { booksState.clearPersistenceError() }
        } message: {
            Text(booksState.persistenceErrorMessage)
        }
    }

    private func searchBooks() {
        activeSearch?.cancel()
        path = [resultsRoute]
        activeSearch = Task {
            await searchViewModel.searchBooks()
        }
    }
}
