import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: KarutaGameViewModel

    var body: some View {
        VStack(spacing: 16) {
            headerView
            statusView
            readingTextView
            readingCardView
            imageCardView
            controlView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }

    private var headerView: some View {
        VStack(spacing: 6) {
            Text("かるた よみあげ")
                .font(.custom("Hiragino Maru Gothic ProN", size: 22))
                .foregroundColor(KarutaTheme.ink)

            HStack(spacing: 8) {
                badgeText("札 \(viewModel.currentRound)/\(viewModel.totalCards)")
                badgeText("指定 \(viewModel.readTargetCount)/\(viewModel.totalTargets)")
            }
        }
    }

    private var statusView: some View {
        Group {
            if viewModel.isTargetsComplete {
                Text("指定の札がそろいました")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 14))
                    .foregroundColor(KarutaTheme.softText)
            } else if viewModel.isSpeaking || viewModel.countdownSeconds != nil {
                Text("読み上げ中")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 14))
                    .foregroundColor(KarutaTheme.softText)
            } else {
                Text("次へで次の札")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 14))
                    .foregroundColor(KarutaTheme.softText)
            }
        }
    }

    private var readingCardView: some View {
        VStack(spacing: 10) {
            Text(chipTitle)
                .font(.custom("Hiragino Maru Gothic ProN", size: 12))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(KarutaTheme.card))
                .overlay(
                    Capsule()
                        .stroke(KarutaTheme.ink, lineWidth: 1.5)
                )

            if let seconds = viewModel.countdownSeconds {
                Text("\(seconds)")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 64))
                    .monospacedDigit()
                    .foregroundColor(KarutaTheme.ink)
            } else if viewModel.phase == .idle {
                Text("準備中")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 18))
                    .foregroundColor(KarutaTheme.softText)
            } else if let card = viewModel.currentCard {
                Text(card.text)
                    .font(.custom("Hiragino Maru Gothic ProN", size: 22))
                    .multilineTextAlignment(.center)
                    .foregroundColor(KarutaTheme.ink)
                    .padding(.horizontal, 8)
            } else {
                Text("読み上げ中")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 18))
                    .foregroundColor(KarutaTheme.softText)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 140)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(CardBackgroundView())
    }

    private var chipTitle: String {
        if viewModel.countdownSeconds != nil {
            return "カウント"
        }
        if viewModel.phase == .idle {
            return "待機中"
        }
        return "読み上げ中"
    }

    private var readingTextView: some View {
        Group {
            if viewModel.phase != .idle,
               viewModel.countdownSeconds == nil,
               let card = viewModel.currentCard,
               !card.description.isEmpty {
                Text(card.description)
                    .font(.custom("Hiragino Maru Gothic ProN", size: 22))
                    .multilineTextAlignment(.center)
                    .foregroundColor(KarutaTheme.accentText)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(ReadingPanelBackgroundView())
            }
        }
    }

    private var imageCardView: some View {
        ZStack {
            if viewModel.phase == .second, let card = viewModel.currentCard {
                Image(card.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(KarutaTheme.ink, lineWidth: 2)
                    )
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 28))
                        .foregroundColor(KarutaTheme.softText)
                    Text("2回目で絵札を表示")
                        .font(.custom("Hiragino Maru Gothic ProN", size: 14))
                        .foregroundColor(KarutaTheme.softText)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(12)
        .background(CardBackgroundView())
        .animation(.easeInOut(duration: 0.3), value: viewModel.phase)
    }

    private var controlView: some View {
        HStack(spacing: 12) {
            Button("もう一度読む") {
                viewModel.startReading()
            }
            .buttonStyle(PrimaryButtonStyle(color: KarutaTheme.accent))
            .disabled(viewModel.isSpeaking || viewModel.countdownSeconds != nil || viewModel.isTargetsComplete)

            Button(viewModel.isTargetsComplete ? "ゲーム終了" : "次へ") {
                if viewModel.isTargetsComplete {
                    viewModel.returnToTitle()
                } else {
                    viewModel.nextCard()
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(viewModel.isTargetsComplete ? (viewModel.isSpeaking || viewModel.countdownSeconds != nil) : !viewModel.canGoNext)
        }
    }

    private func badgeText(_ text: String) -> some View {
        Text(text)
            .font(.custom("Hiragino Maru Gothic ProN", size: 12))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(KarutaTheme.card))
            .overlay(
                Capsule()
                    .stroke(KarutaTheme.ink, lineWidth: 1.5)
            )
    }
}

#Preview {
    ZStack {
        KarutaBackgroundView()
        GameView(viewModel: KarutaGameViewModel(cards: KarutaDeck.cards, targetCardIDs: KarutaDeck.targetCardIDs))
    }
}
