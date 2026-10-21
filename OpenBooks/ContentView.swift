import SwiftUI

struct ContentView: View {
    @State var path: [Int] = []
    @State var showingMyBooks: Bool = false
    @State var searchViewModel = SearchViewModel()
    @State var booksState = BooksState()

    let resultsRoute: Int = -1
    let searchRoute: Int = -2

    var body: some View {
        @Bindable var search = searchViewModel

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
                            booksState.toggleSaved(at: route)
                            path = []
                            showingMyBooks = true
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
    }

    func searchBooks() {
        searchViewModel.searchBooks()
        path = [resultsRoute]
    }
}
