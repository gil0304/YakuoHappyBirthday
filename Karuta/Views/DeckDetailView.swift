import SwiftUI

struct DeckDetailView: View {
    let deckID: UUID
    @ObservedObject var store: CustomDeckStore
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var isStarting = false
    @State private var isConfirmingDelete = false

    private var deck: CustomDeck? {
        store.decks.first { $0.id == deckID }
    }

    var body: some View {
        ZStack {
            DigitalBackgroundView()

            if let deck {
                VStack(alignment: .leading, spacing: 16) {
                    Text(deck.name.uppercased())
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(MonoTheme.text)
                        .kerning(2)

                    Text("\(deck.cards.count) 枚")
                        .font(.custom("AvenirNext-Regular", size: 14))
                        .foregroundColor(MonoTheme.subtleText)

                    VStack(spacing: 12) {
                        actionButton(title: "スタート") {
                            isStarting = true
                        }
                        actionButton(title: "編集") {
                            isEditing = true
                        }
                        actionButton(title: "削除", isDestructive: true) {
                            isConfirmingDelete = true
                        }
                    }
                    .padding(.top, 12)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            } else {
                Text("デッキが見つかりません")
                    .font(.custom("AvenirNext-Medium", size: 16))
                    .foregroundColor(MonoTheme.subtleText)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            DigitalHeaderBar(title: "デッキ", onBack: { dismiss() })
        }
        .navigationDestination(isPresented: $isStarting) {
            if let deck {
                CustomDeckGameView(deck: deck)
            }
        }
        .navigationDestination(isPresented: $isEditing) {
            if let deck {
                DeckEditView(deck: deck, store: store)
            }
        }
        .alert("削除しますか？", isPresented: $isConfirmingDelete) {
            Button("削除", role: .destructive) {
                if let deck {
                    store.delete(deck: deck)
                }
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("このデッキは元に戻せません。")
        }
    }

    private func actionButton(title: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("AvenirNext-DemiBold", size: 16))
                .foregroundColor(isDestructive ? MonoTheme.accent : MonoTheme.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(DigitalPanelBackground(cornerRadius: 12))
        }
    }
}

#Preview {
    DeckDetailView(deckID: UUID(), store: CustomDeckStore())
}
