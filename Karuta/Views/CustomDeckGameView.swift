import SwiftUI

struct CustomDeckGameView: View {
    let deck: CustomDeck
    @StateObject private var viewModel: CustomDeckGameViewModel
    @StateObject private var store = CustomDeckStore()
    @Environment(\.dismiss) private var dismiss

    init(deck: CustomDeck) {
        self.deck = deck
        _viewModel = StateObject(wrappedValue: CustomDeckGameViewModel(deck: deck))
    }

    var body: some View {
        ZStack {
            DigitalBackgroundView()

            VStack(spacing: 16) {
                headerView
                readingCardView
                pictureCardView
                controlView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("戻る") {
                    dismiss()
                }
                .foregroundColor(MonoTheme.text)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(deck.name.uppercased())
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundColor(MonoTheme.text)
                .kerning(2)
            Text("\(viewModel.currentRound)/\(viewModel.totalCards)")
                .font(.custom("AvenirNext-Regular", size: 14))
                .foregroundColor(MonoTheme.subtleText)
                .monospacedDigit()
        }
    }

    private var readingCardView: some View {
        VStack(spacing: 10) {
            Text("READING")
                .font(.custom("AvenirNext-Medium", size: 12))
                .foregroundColor(MonoTheme.subtleText)

            if let seconds = viewModel.countdownSeconds {
                Text("\(seconds)")
                    .font(.custom("AvenirNext-Bold", size: 56))
                    .monospacedDigit()
                    .foregroundColor(MonoTheme.text)
            } else if viewModel.phase == .idle {
                Text("READY")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundColor(MonoTheme.subtleText)
            } else if let card = viewModel.currentCard {
                deckImage(for: card.readingImagePath)
            } else {
                Text("...")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundColor(MonoTheme.subtleText)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .padding(.vertical, 12)
        .background(DigitalPanelBackground(cornerRadius: 16))
    }

    private var pictureCardView: some View {
        VStack(spacing: 10) {
            Text("PICTURE")
                .font(.custom("AvenirNext-Medium", size: 12))
                .foregroundColor(MonoTheme.subtleText)

            if viewModel.phase == .picture, let card = viewModel.currentCard {
                deckImage(for: card.pictureImagePath)
            } else {
                Text("WAIT")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundColor(MonoTheme.subtleText)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.vertical, 12)
        .background(DigitalPanelBackground(cornerRadius: 16))
    }

    private var controlView: some View {
        Group {
            if viewModel.isCompleted {
                Button("ゲーム終了") {
                    dismiss()
                }
                .foregroundColor(MonoTheme.text)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MonoTheme.text, lineWidth: 1)
                )
            } else {
                HStack(spacing: 12) {
                    Button("もう一度") {
                        viewModel.startReading()
                    }
                    .disabled(viewModel.isPlaying || viewModel.countdownSeconds != nil)
                    .foregroundColor(MonoTheme.text)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MonoTheme.text, lineWidth: 1)
                    )
                    .opacity(viewModel.isPlaying || viewModel.countdownSeconds != nil ? 0.5 : 1)

                    Button("次へ") {
                        viewModel.nextCard()
                    }
                    .disabled(!viewModel.canGoNext)
                    .foregroundColor(MonoTheme.text)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MonoTheme.text, lineWidth: 1)
                    )
                    .opacity(viewModel.canGoNext ? 1 : 0.5)
                }
            }
        }
    }

    @ViewBuilder
    private func deckImage(for fileName: String) -> some View {
        let url = store.imageURL(deckID: deck.id, fileName: fileName)
        if let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundColor(MonoTheme.subtleText)
                .padding(24)
        }
    }
}

#Preview {
    CustomDeckGameView(deck: CustomDeck(id: UUID(), name: "SAMPLE", createdAt: Date(), cards: []))
}
