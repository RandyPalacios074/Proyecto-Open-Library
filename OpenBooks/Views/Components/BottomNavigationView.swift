import SwiftUI

struct BottomNavigationView: View {
    let homeActive: Bool
    let onHome: () -> Void
    let onMyBooks: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            BottomTabButton(
                title: "Inicio",
                symbol: homeActive ? "house.fill" : "house",
                selected: homeActive,
                action: onHome
            )
            BottomTabButton(
                title: "Mis favoritos",
                symbol: homeActive ? "bookmark" : "bookmark.fill",
                selected: !homeActive,
                action: onMyBooks
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color.appNavSurface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.appBorder, lineWidth: 0.7))
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

private struct BottomTabButton: View {
    let title: String
    let symbol: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if title == "Mis favoritos" {
                    WideBookmarkShape()
                        .fill(selected ? Color.appAccent : Color.clear)
                        .overlay {
                            WideBookmarkShape()
                                .stroke(selected ? Color.appAccent : Color.appMuted,
                                        style: StrokeStyle(lineWidth: 1.9, lineJoin: .round))
                        }
                        .frame(width: 25, height: 27)
                        .frame(width: 28, height: 28)
                        .accessibilityHidden(true)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: 25, weight: .regular))
                        .frame(width: 28, height: 28)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.caption.weight(selected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(selected ? Color.appAccent : Color.appMuted)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

private struct WideBookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let x = rect.width / 28
        let y = rect.height / 32
        var path = Path()

        path.move(to: CGPoint(x: 5 * x, y: 2 * y))
        path.addLine(to: CGPoint(x: 23 * x, y: 2 * y))
        path.addQuadCurve(to: CGPoint(x: 26 * x, y: 5 * y),
                          control: CGPoint(x: 26 * x, y: 2 * y))
        path.addLine(to: CGPoint(x: 26 * x, y: 30 * y))
        path.addLine(to: CGPoint(x: 14 * x, y: 22 * y))
        path.addLine(to: CGPoint(x: 2 * x, y: 30 * y))
        path.addLine(to: CGPoint(x: 2 * x, y: 5 * y))
        path.addQuadCurve(to: CGPoint(x: 5 * x, y: 2 * y),
                          control: CGPoint(x: 2 * x, y: 2 * y))
        path.closeSubpath()
        return path
    }
}
