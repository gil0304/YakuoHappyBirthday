import SwiftUI

enum MonoTheme {
    static let backgroundTop = Color(red: 0.04, green: 0.06, blue: 0.12)
    static let backgroundBottom = Color(red: 0.02, green: 0.03, blue: 0.07)
    static let surface = Color(red: 0.08, green: 0.11, blue: 0.18)
    static let surfaceAlt = Color(red: 0.06, green: 0.09, blue: 0.14)
    static let border = Color(red: 0.20, green: 0.90, blue: 0.78).opacity(0.5)
    static let glow = Color(red: 0.20, green: 0.90, blue: 0.78).opacity(0.35)
    static let text = Color(red: 0.94, green: 0.97, blue: 1.0)
    static let subtleText = Color.white.opacity(0.6)
    static let accent = Color(red: 0.28, green: 0.96, blue: 0.83)
}

struct DigitalBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [MonoTheme.backgroundTop, MonoTheme.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [MonoTheme.glow.opacity(0.4), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 260
            )
            DigitalGridOverlay()
        }
        .ignoresSafeArea()
    }
}

struct DigitalGridOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            let step: CGFloat = 36
            let size = proxy.size
            Path { path in
                var x: CGFloat = 0
                while x <= size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    x += step
                }
                var y: CGFloat = 0
                while y <= size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    y += step
                }
            }
            .stroke(Color.white.opacity(0.04), lineWidth: 1)
        }
    }
}

struct DigitalPanelBackground: View {
    var cornerRadius: CGFloat = 14

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [MonoTheme.surface, MonoTheme.surfaceAlt],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(MonoTheme.border, lineWidth: 1)
            )
            .shadow(color: MonoTheme.glow, radius: 12, x: 0, y: 0)
    }
}

struct DigitalFieldBackground: View {
    var cornerRadius: CGFloat = 10

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(MonoTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(MonoTheme.border.opacity(0.6), lineWidth: 1)
            )
    }
}
