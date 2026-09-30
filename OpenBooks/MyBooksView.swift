import SwiftUI

struct MyBooksView: View {
    let books: [Book]

    let onBookSelected: (Int) -> Void
    let onHome: () -> Void
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Mis libros")
                    .font(.largeTitle)
                    .bold()

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 12)

            if hasSavedBooks() {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<books.count) { index in
                            if books[index].isSaved {
                                BookRowView(
                                    book: books[index]
                                ) {
                                    onBookSelected(index)
                                }

                                if hasSavedBookAfter(index: index) {
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 1)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                VStack(spacing: 0) {
                    Spacer()

                    EmptyMyBooksView(
                        onSearch: onSearch
                    )
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }

            BottomNavigationView(
                homeActive: false,
                onHome: onHome,
                onMyBooks: {}
            )
        }
    }

    func hasSavedBooks() -> Bool {
        for index in 0..<books.count {
            if books[index].isSaved {
                return true
            }
        }

        return false
    }

    func hasSavedBookAfter(index: Int) -> Bool {
        for nextIndex in 0..<books.count {
            if nextIndex > index && books[nextIndex].isSaved {
                return true
            }
        }

        return false
    }
}

struct EmptyMyBooksView: View {
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Spacer()

                Image(systemName: "book")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)

                Spacer()
            }

            HStack {
                Spacer()

                Text("Todavía no tienes libros guardados")
                    .font(.system(size: 20))
                    .bold()

                Spacer()
            }

            HStack {
                Spacer()

                Text("Busca un libro y guárdalo para verlo aquí.")
                    .foregroundStyle(.gray)

                Spacer()
            }

            Button {
                onSearch()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .foregroundStyle(.black)

                    HStack {
                        Spacer()

                        Text("Buscar libros")
                            .font(.system(size: 18))
                            .foregroundStyle(.black)

                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 13)
                    )
                    .padding(1)
                }
                .frame(height: 52)
            }
        }
    }
}
