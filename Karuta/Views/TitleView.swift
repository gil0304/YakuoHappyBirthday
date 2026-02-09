import SwiftUI

struct TitleView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 10) {
                Text("かるた")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 42))
                    .foregroundColor(KarutaTheme.ink)

                Text("よみあげゲーム")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 18))
                    .foregroundColor(KarutaTheme.softText)
            }

            VStack(spacing: 6) {
                Text("シャッフルして読み上げます")
                Text("指定の3枚が出たら終了")
                Text("ゲームスタート後、5秒で開始")
            }
            .font(.custom("Hiragino Maru Gothic ProN", size: 15))
            .foregroundColor(KarutaTheme.softText)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(ReadingPanelBackgroundView())

            Button("ゲームスタート") {
                onStart()
            }
            .buttonStyle(PrimaryButtonStyle(color: KarutaTheme.accent))
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        KarutaBackgroundView()
        TitleView(onStart: {})
    }
}
