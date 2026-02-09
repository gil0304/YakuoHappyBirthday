import SwiftUI

enum KarutaTheme {
    static let background = Color(red: 0.33, green: 0.70, blue: 0.78)
    static let ink = Color(red: 0.18, green: 0.14, blue: 0.12)
    static let card = Color.white
    static let accent = Color(red: 0.97, green: 0.84, blue: 0.50)
    static let accentText = Color(red: 0.25, green: 0.20, blue: 0.16)
    static let softText = Color(red: 0.25, green: 0.30, blue: 0.34)
}

struct KarutaBackgroundView: View {
    var body: some View {
        KarutaTheme.background
            .ignoresSafeArea()
    }
}

struct CardBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(KarutaTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(KarutaTheme.ink, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 6)
    }
}

struct ReadingPanelBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(KarutaTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(KarutaTheme.ink, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Hiragino Maru Gothic ProN", size: 16))
            .foregroundColor(KarutaTheme.accentText)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(KarutaTheme.ink, lineWidth: 2)
                    )
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Hiragino Maru Gothic ProN", size: 16))
            .foregroundColor(KarutaTheme.ink)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(KarutaTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(KarutaTheme.ink, lineWidth: 2)
                    )
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
