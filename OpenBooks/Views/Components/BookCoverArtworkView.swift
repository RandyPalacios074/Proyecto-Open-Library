import SwiftUI
import UIKit

@MainActor
private final class BookCoverCache {
    static let shared = BookCoverCache()

    private let memory = NSCache<NSNumber, UIImage>()
    private var pending: [Int: Task<UIImage?, Never>] = [:]
    private let directory: URL?

    private init() {
        memory.countLimit = 60
        directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("OpenBooksCovers", isDirectory: true)
    }

    func image(for coverID: Int) async -> UIImage? {
        guard coverID > 0 else { return nil }
        let key = NSNumber(value: coverID)
        if let image = memory.object(forKey: key) { return image }
        if let pending = pending[coverID] { return await pending.value }

        let task = Task { [self] () -> UIImage? in
            if let directory {
                let fileURL = directory.appendingPathComponent("\(coverID).jpg")
                if let data = try? Data(contentsOf: fileURL),
                   let image = UIImage(data: data) {
                    memory.setObject(image, forKey: key)
                    pending[coverID] = nil
                    return image
                }
            }

            guard let url = URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-M.jpg?default=false") else {
                pending[coverID] = nil
                return nil
            }

            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            request.setValue("OpenBooks/1.0 (educational iOS application)", forHTTPHeaderField: "User-Agent")

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse,
                      (200...299).contains(http.statusCode),
                      let image = UIImage(data: data) else {
                    pending[coverID] = nil
                    return nil
                }
                memory.setObject(image, forKey: key)
                if let directory {
                    try? FileManager.default.createDirectory(at: directory,
                                                              withIntermediateDirectories: true)
                    try? data.write(to: directory.appendingPathComponent("\(coverID).jpg"),
                                    options: .atomic)
                }
                pending[coverID] = nil
                return image
            } catch {
                pending[coverID] = nil
                return nil
            }
        }
        pending[coverID] = task
        return await task.value
    }
}

struct BookCoverArtworkView: View {
    let book: Book
    @State private var remoteImage: UIImage?
    @State private var coverLoading = false
    @State private var attempted = false

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
                    Text(book.coverID != nil ? "Portada no disponible" : "Sin portada")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(Color.appMuted)
                .padding(6)
            }
    }

    var body: some View {
        Group {
            if book.coverID != nil {
                if let remoteImage {
                    Image(uiImage: remoteImage)
                        .resizable()
                        .scaledToFit()
                } else if coverLoading || !attempted {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appNavSurface)
                        .overlay { ProgressView() }
                } else {
                    missingCover
                }
            } else if book.hasCover, let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                missingCover
            }
        }
        .accessibilityLabel(book.coverID != nil ? "Portada del libro \(book.title)" :
                            (book.hasCover && imageName != nil
                             ? "Ilustración del libro \(book.title)" : "Sin portada"))
        .task(id: book.coverID) {
            remoteImage = nil
            attempted = false
            guard let coverID = book.coverID else { return }
            coverLoading = true
            let loaded = await BookCoverCache.shared.image(for: coverID)
            guard !Task.isCancelled else { return }
            remoteImage = loaded
            coverLoading = false
            attempted = true
        }
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
