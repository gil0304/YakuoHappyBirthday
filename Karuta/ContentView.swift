import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = KarutaGameViewModel(
        cards: KarutaDeck.cards,
        targetCardIDs: KarutaDeck.targetCardIDs
    )

    var body: some View {
        ZStack {
            KarutaBackgroundView()

            switch viewModel.screen {
            case .title:
                TitleView {
                    viewModel.startGame()
                }
            case .game:
                GameView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
