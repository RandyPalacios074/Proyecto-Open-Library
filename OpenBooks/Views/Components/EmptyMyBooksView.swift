import SwiftUI

struct EmptyMyBooksView: View {
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Spacer()

                Image(systemName: "book")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.appMuted)

                Spacer()
            }

            HStack {
                Spacer()

                Text("Todavía no tienes favoritos")
                    .foregroundStyle(Color.appInk)
                    .font(.system(size: 20))
                    .bold()

                Spacer()
            }

            HStack {
                Spacer()

                Text("Busca un libro y agrégalo a tus favoritos.")
                    .foregroundStyle(Color.appMuted)

                Spacer()
            }

            Button(action: onSearch) {
                Text("Buscar libros")
                    .font(.headline)
                    .foregroundStyle(Color.appCanvas)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
                    .background(Color.appAccent, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }
}
