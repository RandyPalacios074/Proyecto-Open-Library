import SwiftUI
struct BookCoverArtworkView: View {
    let book: Book

    private var imageName: String? {
        switch book.title {
        case "Harry Potter y la piedra filosofal": return "EditorialHarry"
        case "Orgullo y prejuicio": return "EditorialPride"
        case "1984": return "Editorial1984"
        default: return nil
        }
    }

    private var missingCover: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.appNavSurface)
            .overlay {
                VStack(spacing: 7) {
                    Image(systemName: "book")
                        .font(.title2)
                    Text("Sin portada")
                        .font(.caption2)
                }
                .foregroundStyle(Color.appMuted)
            }
    }

    var body: some View {
        Group {
            if let coverID = book.coverID,
               let url = URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-M.jpg") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appNavSurface)
                            .overlay { ProgressView() }
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        missingCover
                    @unknown default:
                        missingCover
                    }
                }
            } else if book.hasCover, let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appNavSurface)
                    .overlay {
                        VStack(spacing: 7) {
                            Image(systemName: book.hasCover ? "book.closed" : "book")
                                .font(.title2)
                            Text(book.hasCover ? "Portada pendiente" : "Sin portada")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(Color.appMuted)
                        .padding(6)
                    }
            }
        }
        .accessibilityLabel(book.coverID != nil ? "Portada del libro \(book.title)" : (book.hasCover && imageName != nil ? "Ilustración del libro \(book.title)" : (book.hasCover ? "Portada pendiente" : "Sin portada")))
    }
}

struct SmallBookCoverView: View {
    let book: Book

    var body: some View {
        BookCoverArtworkView(book: book)
            .frame(width: 96, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}


struct LargeBookCoverView: View {
    let book: Book

    var body: some View {
        BookCoverArtworkView(book: book)
            .frame(width: 210, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
