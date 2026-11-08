import SwiftUI

struct BookDetailView: View {
    let book: Book
    let homeActive: Bool
    let onSaveOrDelete: () -> Void
    let onHome: () -> Void
    let onMyBooks: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Detalle del libro")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.appInk)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.bottom, 20)

                    LargeBookCoverView(book: book)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                    Text(book.title)
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .foregroundStyle(Color.appInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.bottom, 22)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Información")
                            .font(.headline)
                            .foregroundStyle(Color.appInk)
                            .accessibilityAddTraits(.isHeader)
                            .padding(.bottom, 2)

                        DetailInformationRow(label: "Autor", value: book.author)

                        if let year = book.year {
                            DetailInformationRow(label: "Año de publicación", value: year)
                        }

                        if let genre = book.genre {
                            DetailInformationRow(label: "Género", value: genre)
                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.appCard, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.bottom, 28)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sobre este libro")
                            .font(.headline)
                            .foregroundStyle(Color.appInk)
                            .accessibilityAddTraits(.isHeader)

                        Text(book.synopsis ?? "Todavía no hay una descripción disponible para este libro.")
                            .font(.body)
                            .foregroundStyle(Color.appMuted)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 26)

                    if !book.themes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Temas principales")
                                .font(.headline)
                                .foregroundStyle(Color.appInk)
                                .accessibilityAddTraits(.isHeader)

                            Text(book.themes.joined(separator: " · "))
                                .font(.subheadline)
                                .foregroundStyle(Color.appMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 36)
            }

            Button(action: onSaveOrDelete) {
                Text(book.isSaved ? "Quitar de favoritos" : "Agregar a favoritos")
                    .font(.headline)
                    .foregroundStyle(Color.appCanvas)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
                    .background(Color.appAccent, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            BottomNavigationView(
                homeActive: homeActive,
                onHome: onHome,
                onMyBooks: onMyBooks
            )
        }
        .background(Color.appCanvas.ignoresSafeArea())
    }
}

private struct DetailInformationRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .foregroundStyle(Color.appMuted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Text(value)
                .foregroundStyle(Color.appInk)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.subheadline)
    }
}
