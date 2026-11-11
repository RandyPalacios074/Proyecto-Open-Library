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
                        .foregroundStyle(Color.appInk)
                        .font(.largeTitle)
                        .bold()

                    Spacer()

                    Button {
                        onOpenSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.appInk)
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
                                    .foregroundStyle(Color.appMuted)
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

            case .error(let message):
                VStack(spacing: 0) {
                    Spacer()

                    SearchErrorView(
                        message: message,
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
        .background(Color.appCanvas.ignoresSafeArea())
    }
}

struct LoadingResultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()

                Image(systemName: "hourglass")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.appMuted)

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
                    .foregroundStyle(Color.appMuted)

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
                    .foregroundStyle(Color.appMuted)

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
                    .foregroundStyle(Color.appMuted)

                Spacer()
            }
        }
    }
}

struct SearchErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()

                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.appMuted)

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

                Text(message)
                    .foregroundStyle(Color.appMuted)

                Spacer()
            }

            HStack {
                Spacer()

                Text("Intenta nuevamente.")
                    .foregroundStyle(Color.appMuted)

                Spacer()
            }

            Button {
                onRetry()
            } label: {
                HStack {
                    Spacer()

                    Text("Intentar nuevamente")
                        .foregroundStyle(Color.appCanvas)

                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color.appAccent)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
        }
    }
}
