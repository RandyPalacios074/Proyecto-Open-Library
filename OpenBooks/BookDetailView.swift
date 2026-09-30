import SwiftUI

struct BookDetailView: View {
    let book: Book
    let homeActive: Bool

    let onBack: () -> Void
    let onSaveOrDelete: () -> Void
    let onHome: () -> Void
    let onMyBooks: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundStyle(.black)
                    }

                    Text("Detalle del libro")
                        .font(.largeTitle)
                        .bold()

                    HStack {
                        Spacer()

                        LargeBookCoverView(
                            hasCover: book.hasCover
                        )

                        Spacer()
                    }

                    HStack {
                        Spacer()

                        VStack(spacing: 10) {
                            Text(book.title)
                                .font(.system(size: 24))
                                .bold()

                            Text(book.author)
                                .font(.system(size: 20))
                                .foregroundStyle(.gray)

                            if let year = book.year {
                                Text("Año: \(year)")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.gray)
                            }
                        }

                        Spacer()
                    }

                    Button {
                        onSaveOrDelete()
                    } label: {
                        HStack {
                            Spacer()

                            if book.isSaved {
                                Text("Eliminar de Mis libros")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                            } else {
                                Text("Guardar libro")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(.black)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }

            BottomNavigationView(
                homeActive: homeActive,
                onHome: onHome,
                onMyBooks: onMyBooks
            )
        }
    }
}

struct LargeBookCoverView: View {
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
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "book")
                        .font(.system(size: 50))

                    Text("Sin portada")
                        .font(.system(size: 18))
                }
                .foregroundStyle(.gray)
            }
        }
        .frame(width: 220, height: 280)
    }
}
