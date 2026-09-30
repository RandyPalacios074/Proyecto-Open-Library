import SwiftUI

struct ContentView: View {
    @State var screen: AppScreen = .home
    @State var previousScreen: AppScreen = .home
    @State var selectedBookIndex: Int? = nil
    @State var searchText: String = ""
    @State var resultsState: ResultsState = .content
    @State var detailHomeActive: Bool = true

    @State var books: [Book] = [
        Book(
            title: "Cien años de soledad",
            author: "Gabriel García Márquez",
            year: "1967",
            hasCover: true,
            isSaved: false
        ),
        Book(
            title: "El principito",
            author: "Antoine de Saint-Exupéry",
            year: nil,
            hasCover: true,
            isSaved: false
        ),
        Book(
            title: "1984",
            author: "George Orwell",
            year: nil,
            hasCover: true,
            isSaved: false
        ),
        Book(
            title: "Harry Potter y la piedra filosofal",
            author: "J. K. Rowling",
            year: "1997",
            hasCover: true,
            isSaved: false
        ),
        Book(
            title: "Harry Potter y la cámara secreta",
            author: "J. K. Rowling",
            year: nil,
            hasCover: true,
            isSaved: false
        ),
        Book(
            title: "Harry Potter y el prisionero de Azkaban",
            author: "J. K. Rowling",
            year: nil,
            hasCover: true,
            isSaved: false
        ),
        Book(
            title: "Harry Potter y el cáliz de fuego",
            author: "J. K. Rowling",
            year: nil,
            hasCover: true,
            isSaved: false
        ),
        Book(
            title: "Orgullo y prejuicio",
            author: "Jane Austen",
            year: nil,
            hasCover: false,
            isSaved: false
        ),
        Book(
            title: "Emma",
            author: "Jane Austen",
            year: nil,
            hasCover: false,
            isSaved: false
        ),
        Book(
            title: "Persuasión",
            author: "Jane Austen",
            year: nil,
            hasCover: false,
            isSaved: false
        )
    ]

    var body: some View {
        switch screen {

        case .home:
            HomeView(
                searchText: $searchText,
                books: books,
                onSearch: {
                    searchBooks()
                },
                onBookSelected: { index in
                    selectedBookIndex = index
                    previousScreen = .home
                    detailHomeActive = true
                    screen = .detail
                },
                onMyBooks: {
                    screen = .myBooks
                }
            )

        case .results:
            SearchResultsView(
                searchText: $searchText,
                books: books,
                state: resultsState,
                onBack: {
                    screen = .home
                },
                onSearch: {
                    searchBooks()
                },
                onBookSelected: { index in
                    selectedBookIndex = index
                    previousScreen = .results
                    detailHomeActive = true
                    screen = .detail
                },
                onRetry: {
                    searchBooks()
                },
                onHome: {
                    screen = .home
                },
                onMyBooks: {
                    screen = .myBooks
                }
            )

        case .detail:
            if let index = selectedBookIndex {
                BookDetailView(
                    book: books[index],
                    homeActive: detailHomeActive,
                    onBack: {
                        screen = previousScreen
                    },
                    onSaveOrDelete: {
                        books[index].isSaved.toggle()
                        screen = .myBooks
                    },
                    onHome: {
                        screen = .home
                    },
                    onMyBooks: {
                        screen = .myBooks
                    }
                )
            } else {
                HomeView(
                    searchText: $searchText,
                    books: books,
                    onSearch: {
                        searchBooks()
                    },
                    onBookSelected: { index in
                        selectedBookIndex = index
                        previousScreen = .home
                        detailHomeActive = true
                        screen = .detail
                    },
                    onMyBooks: {
                        screen = .myBooks
                    }
                )
            }

        case .myBooks:
            MyBooksView(
                books: books,
                onBookSelected: { index in
                    selectedBookIndex = index
                    previousScreen = .myBooks
                    detailHomeActive = false
                    screen = .detail
                },
                onHome: {
                    screen = .home
                },
                onSearch: {
                    screen = .home
                }
            )
        }
    }

    func searchBooks() {
        if searchText == "Harry Potter" {
            resultsState = .content
        } else if searchText == "Orgullo y prejuicio" {
            resultsState = .content
        } else {
            resultsState = .noResults
        }

        screen = .results
    }
}
