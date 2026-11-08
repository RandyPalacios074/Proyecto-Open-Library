import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SearchFieldView(text: $searchText, onSearch: onSearch)
                .padding(.horizontal, 20)
                .padding(.top, 24)
            Spacer()
        }
        .background(Color.appCanvas.ignoresSafeArea())
    }
}

struct SearchFieldView: View {
    @Binding var text: String
    let onSearch: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.appMuted)
                .accessibilityHidden(true)

            TextField("Buscar libros", text: $text)
                .foregroundStyle(Color.appInk)
                .tint(Color.appAccent)
                .submitLabel(.search)
                .accessibilityLabel("Buscar libros")
                .onSubmit {
                    onSearch()
                }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .background(Color.appSearchSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
    }
}
