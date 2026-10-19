import SwiftUI

struct SearchResultsView: View {
    let resultIndices: [Int]
    let books: [Book]
    let state: SearchViewState


    let onOpenSearch: () -> Void
    let onRetry: () -> Void
    let onHome: () -> Void
    let onMyBooks: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {


                HStack {
                    Text("Resultados")
                        .font(.largeTitle)
                        .bold()

                    Spacer()

                    Button {
                        onOpenSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 24))
                            .foregroundStyle(.black)
                    }
                    .accessibilityLabel("Buscar libros")
                }
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
                    VStack(spacing: 0) {
                        ForEach(resultIndices, id: \.self) { index in
                            BookRowView(
                                book: books[index],
                                destination: index
                            )

                            if index != resultIndices.last {
                                RoundedRectangle(cornerRadius: 0)
                                    .frame(height: 1)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
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
