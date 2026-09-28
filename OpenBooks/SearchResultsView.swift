import SwiftUI

struct SearchResultsView: View {
    @Binding var searchText: String
    let books: [Book]
    let state: ResultsState

    let onBack: () -> Void
    let onSearch: () -> Void
    let onBookSelected: (Int) -> Void
    let onRetry: () -> Void
    let onHome: () -> Void
    let onMyBooks: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24))
                        .foregroundStyle(.black)
                }

                Text("Resultados")
                    .font(.largeTitle)
                    .bold()

                SearchFieldView(
                    text: $searchText,
                    onSearch: onSearch
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 12)

            switch state {
            case .loading:
                VStack(spacing: 0) {
                    Spacer()

                    LoadingResultsView()
                        .padding(.horizontal, 20)

                    Spacer()
                }

            case .content:
                ScrollView {
                    if searchText == "Orgullo y prejuicio" {
                        VStack(spacing: 0) {
                            ForEach(7..<10) { index in
                                BookRowView(
                                    book: books[index]
                                ) {
                                    onBookSelected(index)
                                }

                                if index < 9 {
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 1)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(3..<7) { index in
                                BookRowView(
                                    book: books[index]
                                ) {
                                    onBookSelected(index)
                                }

                                if index < 6 {
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 1)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

            case .noResults:
                VStack(spacing: 0) {
                    Spacer()

                    NoResultsView()
                        .padding(.horizontal, 20)

                    Spacer()
                }

            case .error:
                VStack(spacing: 0) {
                    Spacer()

                    SearchErrorView(
                        onRetry: onRetry
                    )
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }

            BottomNavigationView(
                homeActive: true,
                onHome: onHome,
                onMyBooks: onMyBooks
            )
        }
    }
}

struct LoadingResultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()

                Image(systemName: "hourglass")
                    .font(.system(size: 50))
                    .foregroundStyle(.gray)

                Spacer()
            }

            HStack {
                Spacer()

                Text("Buscando libros...")
                    .font(.system(size: 20))

                Spacer()
            }

            HStack {
                Spacer()

                Text("Esto puede tardar unos segundos.")
                    .foregroundStyle(.gray)

                Spacer()
            }
        }
    }
}

struct NoResultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundStyle(.gray)

                Spacer()
            }

            HStack {
                Spacer()

                Text("No se encontraron libros")
                    .font(.system(size: 20))
                    .bold()

                Spacer()
            }

            HStack {
                Spacer()

                Text("Intenta realizar otra búsqueda.")
                    .foregroundStyle(.gray)

                Spacer()
            }
        }
    }
}

struct SearchErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()

                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 50))
                    .foregroundStyle(.gray)

                Spacer()
            }

            HStack {
                Spacer()

                Text("No se pudieron cargar los libros")
                    .font(.system(size: 20))
                    .bold()

                Spacer()
            }

            HStack {
                Spacer()

                Text("Ocurrió un error al obtener los resultados.")
                    .foregroundStyle(.gray)

                Spacer()
            }

            HStack {
                Spacer()

                Text("Intenta nuevamente.")
                    .foregroundStyle(.gray)

                Spacer()
            }

            Button {
                onRetry()
            } label: {
                HStack {
                    Spacer()

                    Text("Intentar nuevamente")
                        .foregroundStyle(.white)

                    Spacer()
                }
                .padding(.vertical, 14)
                .background(.black)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
        }
    }
}
