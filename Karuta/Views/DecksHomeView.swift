import SwiftUI

struct DecksHomeView: View {
    @StateObject private var store = CustomDeckStore()
    @State private var isPresentingCreate = false
    @State private var selectedDeckID: UUID? = nil
    @EnvironmentObject private var appMode: AppMode

    var body: some View {
        NavigationStack {
            ZStack {
                DigitalBackgroundView()

                VStack(alignment: .leading, spacing: 16) {
                    Text("DECKS")
                        .font(.custom("AvenirNext-Bold", size: 28))
                        .foregroundColor(MonoTheme.text)
                        .kerning(3)

                    if store.decks.isEmpty {
                        emptyView
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(store.decks) { deck in
                                    Button {
                                        selectedDeckID = deck.id
                                    } label: {
                                        deckRow(deck)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    Button {
                        isPresentingCreate = true
                    } label: {
                        Text("新しいデッキを作る")
                            .font(.custom("AvenirNext-Medium", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(MonoTheme.text, lineWidth: 1)
                            )
                    }
                    .foregroundColor(MonoTheme.text)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .overlay(alignment: .topLeading) {
                Color.clear
                    .frame(width: 90, height: 90)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 3) {
                        appMode.toggle()
                    }
            }
            .navigationDestination(item: $selectedDeckID) { deckID in
                DeckDetailView(deckID: deckID, store: store)
            }
            .sheet(isPresented: $isPresentingCreate) {
                DeckCreateView(store: store)
            }
        }
    }

    private var emptyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("まだデッキがありません")
                .font(.custom("AvenirNext-Medium", size: 16))
                .foregroundColor(MonoTheme.subtleText)
            Text("読み札と絵札の画像を読み込んで作成します。")
                .font(.custom("AvenirNext-Regular", size: 14))
                .foregroundColor(MonoTheme.subtleText)
        }
        .padding(.vertical, 8)
    }

    private func deckRow(_ deck: CustomDeck) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(deck.name)
                    .font(.custom("AvenirNext-DemiBold", size: 16))
                    .foregroundColor(MonoTheme.text)
                Text("\(deck.cards.count) 枚")
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .foregroundColor(MonoTheme.subtleText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(MonoTheme.subtleText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(DigitalPanelBackground(cornerRadius: 12))
    }
}

#Preview {
    DecksHomeView()
        .environmentObject(AppMode())
}
