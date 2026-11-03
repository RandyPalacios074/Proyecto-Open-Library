import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingPersistenceError = false
    @State private var persistenceErrorMessage = ""

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
                            do {
                                let repository = SavedBooksRepository(context: modelContext)
                                try booksState.toggleSaved(at: route, using: repository)
                                path = []
                                showingMyBooks = true
                            } catch {
                                showPersistenceError(error)
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
            do {
                let repository = SavedBooksRepository(context: modelContext)
                try booksState.loadFavorites(using: repository)
            } catch {
                showPersistenceError(error)
            }
        }
        .alert("No se pudieron actualizar los favoritos", isPresented: $showingPersistenceError) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(persistenceErrorMessage)
        }
    }

    private func showPersistenceError(_ error: Error) {
        persistenceErrorMessage = error.localizedDescription
        showingPersistenceError = true
    }

    func searchBooks() {
        searchViewModel.searchBooks()
        path = [resultsRoute]
    }
}
