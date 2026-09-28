import SwiftUI

struct HomeView: View {
    @Binding var searchText: String
    let books: [Book]
    let onSearch: () -> Void
    let onBookSelected: (Int) -> Void
    let onMyBooks: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("OpenBooks")
                        .font(.largeTitle)
                        .bold()

                    SearchFieldView(
                        text: $searchText,
                        onSearch: onSearch
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Libros")
                            .font(.system(size: 24))
                            .bold()

                        VStack(spacing: 0) {
                            ForEach(0..<3) { index in
                                BookRowView(
                                    book: books[index]
                                ) {
                                    onBookSelected(index)
                                }

                                if index < 2 {
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 1)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }

            BottomNavigationView(
                homeActive: true,
                onHome: {},
                onMyBooks: onMyBooks
            )
        }
    }
}

struct SearchFieldView: View {
    @Binding var text: String
    let onSearch: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(.gray)

            HStack(spacing: 12) {
                Button {
                    onSearch()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }

                TextField(text: $text) {
                    Text("Buscar libros")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 13)
            )
            .padding(1)
        }
        .frame(height: 50)
    }
}

struct BookRowView: View {
    let book: Book
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {
                SmallBookCoverView(
                    hasCover: book.hasCover
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(book.title)
                        .font(.system(size: 18))
                        .bold()
                        .foregroundStyle(.black)

                    Text(book.author)
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 18))
                    .foregroundStyle(.black)
            }
            .padding(.vertical, 10)
        }
    }
}

struct SmallBookCoverView: View {
    let hasCover: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .foregroundStyle(.gray)

            RoundedRectangle(cornerRadius: 3)
                .foregroundStyle(.white)
                .padding(1)

            if hasCover {
                Image(systemName: "xmark")
                    .font(.system(size: 24))
                    .foregroundStyle(.gray)
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "book")
                        .font(.system(size: 20))

                    Text("Sin portada")
                        .font(.system(size: 13))
                }
                .foregroundStyle(.gray)
            }
        }
        .frame(width: 84, height: 108)
    }
}

struct BottomNavigationView: View {
    let homeActive: Bool
    let onHome: () -> Void
    let onMyBooks: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 0)
                .frame(height: 1)
                .foregroundStyle(.gray)

            HStack {
                Spacer()

                Button {
                    onHome()
                } label: {
                    if homeActive {
                        VStack(spacing: 4) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 24))

                            Text("Inicio")
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.black)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "house")
                                .font(.system(size: 24))

                            Text("Inicio")
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.gray)
                    }
                }

                Spacer()
                Spacer()

                Button {
                    onMyBooks()
                } label: {
                    if homeActive {
                        VStack(spacing: 4) {
                            Image(systemName: "book")
                                .font(.system(size: 24))

                            Text("Mis libros")
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.gray)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 24))

                            Text("Mis libros")
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.black)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 10)
        }
    }
}
