import Foundation
import SwiftUI
import SwiftData

@main
@MainActor
struct OpenBooksApp: App {
    private let container: ModelContainer
    private let searchService: BookSearchService
    @State private var booksState: BooksState

    init() {
        do {
            let modelContainer = try ModelContainer(for: SavedBook.self)
            container = modelContainer
            _booksState = State(initialValue: BooksState(
                store: SavedBooksRepository(context: modelContainer.mainContext)
            ))
            searchService = OpenLibraryBookSearchService()
        } catch {
            fatalError("No se pudo iniciar el almacenamiento: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(booksState: booksState, searchService: searchService)
        }
        .modelContainer(container)
    }
}
