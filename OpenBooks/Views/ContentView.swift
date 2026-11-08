import SwiftUI

struct ContentView: View {
    let booksState: BooksState
    @State var path: [Int] = []
    @State var showingMyBooks: Bool = false
    @State var searchViewModel = SearchViewModel()

    let resultsRoute: Int = -1
    let searchRoute: Int = -2

    var body: some View {
        @Bindable var search = searchViewModel
        @Bindable var favorites = booksState

        NavigationStack(path: $path) {
            ZStack {
                if showingMyBooks {
                    MyBooksView(
                        books: booksState.books,
                        onHome: {
                            showingMyBooks = false
                        },
                        onSearch: {
                            showingMyBooks = false
                            path.append(searchRoute)
                        }
                    )
                } else {
                    HomeView(
                        books: booksState.books,
                        onOpenSearch: {
                            path.append(searchRoute)
                        },
                        onMyBooks: {
                            showingMyBooks = true
                        }
                    )
                }
            }
            .navigationDestination(for: Int.self) { route in
                if route == searchRoute {
                    SearchView(
                        searchText: $search.searchText,
                        onSearch: {
                            searchBooks()
                        }
                    )
                } else if route == resultsRoute {
                    SearchResultsView(
                        resultIndices: searchViewModel.resultIndices,
                        books: booksState.books,
                        state: searchViewModel.state,
                        onOpenSearch: {
                            path.append(searchRoute)
                        },
                        onRetry: {
                            searchBooks()
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
                } else {
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
        }
        .alert("No se pudieron actualizar los favoritos", isPresented: $favorites.showingPersistenceError) {
            Button("Aceptar", role: .cancel) {
                booksState.clearPersistenceError()
            }
        } message: {
            Text(booksState.persistenceErrorMessage)
        }
    }

    func searchBooks() {
        searchViewModel.searchBooks()
        path = [resultsRoute]
    }
}
