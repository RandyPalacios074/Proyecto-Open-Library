import SwiftUI

struct BookRowView: View {
    let book: Book
    let destination: Int

    var body: some View {
        NavigationLink(value: destination) {
            HStack(spacing: 16) {
                SmallBookCoverView(book: book)
                VStack(alignment: .leading, spacing: 6) {
                    Text(book.title)
                        .font(.headline)
                        .foregroundStyle(Color.appInk)
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundStyle(Color.appMuted)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appMuted)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 17)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}
