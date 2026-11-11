import SwiftUI
import SwiftData

@main
@MainActor
struct OpenBooksApp: App {
    private let container: ModelContainer
    private let searchService: any BookSearchService
    @State private var booksState: BooksState

    init() {
        do {
            let modelContainer = try ModelContainer(for: SavedBook.self)
            container = modelContainer
            searchService = OpenLibraryBookSearchService()
            _booksState = State(initialValue: BooksState(
                store: SavedBooksRepository(context: modelContainer.mainContext)
            ))
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
