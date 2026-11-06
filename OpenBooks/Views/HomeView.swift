import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showingAllSuggestions = false

    let books: [Book]
    let onOpenSearch: () -> Void
    let onMyBooks: () -> Void

    private var featuredIndices: [Int] { [3, 2, 7] }

    private var visibleIndices: [Int] {
        let main = featuredIndices.filter { books.indices.contains($0) }
        if showingAllSuggestions {
            return main + books.indices.filter { !main.contains($0) }
        }
        return main
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
                        .foregroundStyle(Color("Ink"))
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
                        .foregroundStyle(Color("Ink"))
                        .padding(.horizontal, 20)
                        .frame(minHeight: 54)
                        .background(Color("SearchSurface"), in: Capsule())
                        .overlay(Capsule().stroke(Color("Border"), lineWidth: 0.8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Buscar libros")
                    .accessibilityHint("Abre la pantalla de búsqueda")

                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Sugerencias")
                                .font(.system(.title2, design: .serif, weight: .semibold))
                                .foregroundStyle(Color("Ink"))
                                .accessibilityAddTraits(.isHeader)
                            Spacer()
                            Button {
                                showingAllSuggestions.toggle()
                            } label: {
                                HStack(spacing: 3) {
                                    Text(showingAllSuggestions ? "Ver menos" : "Ver todo")
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color("Accent"))
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Muestra u oculta los demás libros de prueba")
                        }

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 20) {
                            ForEach(visibleIndices, id: \.self) { index in
                                NavigationLink(value: index) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        editorialCover(for: index)
                                            .aspectRatio(138.0 / 178.0, contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 11))

                                        Text(shortTitle(for: index))
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(Color("Ink"))
                                            .lineLimit(3)
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: .infinity, alignment: .top)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .top)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(books[index].title)
                                .accessibilityHint("Abre el detalle del libro")
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
        .background(Color("Canvas").ignoresSafeArea())
    }

    private func shortTitle(for index: Int) -> String {
        if index == 3 { return "Harry Potter" }
        return books[index].title
    }

    @ViewBuilder
    private func editorialCover(for index: Int) -> some View {
        if index == 3 {
            Image("EditorialHarry").resizable().scaledToFit()
        } else if index == 2 {
            Image("Editorial1984").resizable().scaledToFit()
        } else if index == 7 {
            Image("EditorialPride").resizable().scaledToFit()
        } else {
            BookCoverArtworkView(book: books[index])
        }
    }
}
