import SwiftUI
import SwiftData

@main
struct OpenBooksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedBook.self)
    }
}
