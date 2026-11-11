import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let books: [Book]
    let suggestionIndices: [Int]
    let suggestionsState: SearchViewState
    let onRetrySuggestions: () -> Void
    let onOpenSearch: () -> Void
    let onMyBooks: () -> Void

    private var visibleIndices: [Int] {
        suggestionIndices.filter { books.indices.contains($0) }
    }

    private var suggestionColumns: [GridItem] {
        [GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 220 : 145,
                            maximum: dynamicTypeSize.isAccessibilitySize ? 360 : 180), spacing: 16)]
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 19) {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("OpenBooks")
                                .font(.system(.title, design: .serif, weight: .semibold))
                            Text("Encuentra tu próximo libro")
                                .font(.system(.title, design: .serif, weight: .semibold))
                        }
                        .foregroundStyle(Color.appInk)
                        .padding(.top, 12)
                    } else {
                        Image(colorScheme == .dark ? "HeroReferenceNight" : "HeroReferenceDay")
                            .resizable()
                            .aspectRatio(494.0 / 341.0, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel("OpenBooks")
                            .accessibilityValue("Encuentra tu próximo libro")
                            .accessibilityAddTraits(.isHeader)
                    }

                    Button(action: onOpenSearch) {
                        HStack(spacing: 15) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3.weight(.regular))
                            Text("Buscar libros")
                                .font(.body)
                            Spacer()
                        }
                        .foregroundStyle(Color.appInk)
                        .padding(.horizontal, 20)
                        .frame(minHeight: 54)
                        .background(Color.appSearchSurface, in: Capsule())
                        .overlay(Capsule().stroke(Color.appBorder, lineWidth: 0.8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Buscar libros")
                    .accessibilityHint("Abre la pantalla de búsqueda")

                    VStack(alignment: .leading, spacing: 18) {
                        Text("Sugerencias")
                            .font(.system(.title2, design: .serif, weight: .semibold))
                            .foregroundStyle(Color.appInk)
                            .accessibilityAddTraits(.isHeader)

                        if suggestionsState == .content {
                            Text("De Open Library")
                                .font(.caption)
                                .foregroundStyle(Color.appMuted)
                        }

                        if suggestionsState == .content {
                            LazyVGrid(columns: suggestionColumns, alignment: .center, spacing: 24) {
                                ForEach(visibleIndices, id: \.self) { index in
                                    NavigationLink(value: index) {
                                        VStack(spacing: 9) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 11)
                                                    .fill(Color.appNavSurface)
                                                editorialCover(for: index)
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity,
                                                           alignment: .center)
                                                    .padding(3)
                                            }
                                            .aspectRatio(2.0 / 3.0, contentMode: .fit)
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 11))

                                            Text(shortTitle(for: index))
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(Color.appInk)
                                                .lineLimit(3)
                                                .multilineTextAlignment(.center)
                                                .frame(maxWidth: .infinity, minHeight: 60,
                                                       alignment: .top)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .top)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(books[index].title)
                                    .accessibilityIdentifier("sugerencia-\(index)")
                                    .accessibilityHint("Abre el detalle del libro")
                                }
                            }
                        } else {
                            switch suggestionsState {
                            case .loading:
                                ProgressView("Buscando sugerencias...")
                                    .frame(maxWidth: .infinity, minHeight: 120)
                            case .noResults:
                                Text("No hay sugerencias disponibles.")
                                    .foregroundStyle(Color.appMuted)
                                    .frame(maxWidth: .infinity, minHeight: 120)
                            case .error(let message):
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("No se pudieron cargar las sugerencias")
                                        .font(.headline)
                                        .foregroundStyle(Color.appInk)
                                    Text(message)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appMuted)
                                    Button("Intentar nuevamente", action: onRetrySuggestions)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.appAccent)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            case .content:
                                EmptyView()
                            }
                        }
                    }
                    .padding(.top, 9)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            BottomNavigationView(homeActive: true, onHome: {}, onMyBooks: onMyBooks)
        }
        .background(Color.appCanvas.ignoresSafeArea())
    }

    private func shortTitle(for index: Int) -> String {
        books[index].title
    }

    private func editorialCover(for index: Int) -> some View {
        BookCoverArtworkView(book: books[index])
    }
}
