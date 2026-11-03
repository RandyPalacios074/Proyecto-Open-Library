import SwiftUI

struct MyBooksView: View {
    let books: [Book]

    let onHome: () -> Void
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Mis favoritos")
                    .foregroundStyle(Color("Ink"))
                    .font(.largeTitle)
                    .bold()

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 12)

            if hasSavedBooks() {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<books.count) { index in
                            if books[index].isSaved {
                                BookRowView(
                                    book: books[index],
                                    destination: index
                                )

                                if hasSavedBookAfter(index: index) {
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 1)
                                        .foregroundStyle(Color("Muted"))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                VStack(spacing: 0) {
                    Spacer()

                    EmptyMyBooksView(
                        onSearch: onSearch
                    )
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }

            BottomNavigationView(
                homeActive: false,
                onHome: onHome,
                onMyBooks: {}
            )
        }
        .background(Color("Canvas").ignoresSafeArea())
    }

    func hasSavedBooks() -> Bool {
        for index in 0..<books.count {
            if books[index].isSaved {
                return true
            }
        }

        return false
    }

    func hasSavedBookAfter(index: Int) -> Bool {
        for nextIndex in 0..<books.count {
            if nextIndex > index && books[nextIndex].isSaved {
                return true
            }
        }

        return false
    }
}
