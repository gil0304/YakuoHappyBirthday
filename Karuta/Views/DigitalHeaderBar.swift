import SwiftUI

struct DigitalHeaderBar: View {
    let title: String
    var showsBack: Bool = true
    var onBack: (() -> Void)? = nil
    var trailingTitle: String? = nil
    var onTrailing: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if showsBack {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(MonoTheme.text)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(MonoTheme.surface)
                                .overlay(
                                    Circle()
                                        .stroke(MonoTheme.border, lineWidth: 1)
                                )
                        )
                }
            } else {
                Color.clear.frame(width: 36, height: 36)
            }

            Spacer()

            Text(title)
                .font(.custom("AvenirNext-DemiBold", size: 16))
                .foregroundColor(MonoTheme.text)
                .kerning(1)

            Spacer()

            if let trailingTitle, let onTrailing {
                Button(trailingTitle) {
                    onTrailing()
                }
                .font(.custom("AvenirNext-DemiBold", size: 14))
                .foregroundColor(MonoTheme.text)
                .frame(width: 64, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(MonoTheme.border, lineWidth: 1)
                )
            } else {
                Color.clear.frame(width: 64, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [MonoTheme.surface, MonoTheme.surfaceAlt],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(MonoTheme.border),
                alignment: .bottom
            )
        )
    }
}

#Preview {
    DigitalHeaderBar(title: "デッキ")
        .background(DigitalBackgroundView())
}
