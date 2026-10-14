import SwiftUI

struct ContentView: View {
    @State var path: [Int] = []
    @State var showingMyBooks: Bool = false
    @State var searchText: String = ""
    @State var searchViewState: SearchViewState = .content
    @State var booksState = BooksState()

    let resultsRoute: Int = -1

    var body: some View {
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
                        }
                    )
                } else {
                    HomeView(
                        searchText: $searchText,
                        books: booksState.books,
                        onSearch: {
                            searchBooks()
                        },
                        onMyBooks: {
                            showingMyBooks = true
                        }
                    )
                }
            }
            .navigationDestination(for: Int.self) { route in
                if route == resultsRoute {
                    SearchResultsView(
                        searchText: $searchText,
                        books: booksState.books,
                        state: searchViewState,
                        onSearch: {
                            searchBooks()
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
                            booksState.books[route].isSaved.toggle()
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
        if searchText == "Harry Potter" {
            searchViewState = .content
        } else if searchText == "Orgullo y prejuicio" {
            searchViewState = .content
        } else {
            searchViewState = .noResults
        }

        if path.isEmpty {
            path.append(resultsRoute)
        }
    }
}
