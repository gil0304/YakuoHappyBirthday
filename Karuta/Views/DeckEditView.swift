import PhotosUI
import SwiftUI
import UIKit

struct DeckEditView: View {
    let deck: CustomDeck
    @ObservedObject var store: CustomDeckStore
    @Environment(\.dismiss) private var dismiss

    @State private var deckName: String
    @State private var cards: [CustomDeckCard]
    @State private var cardTexts: [String]
    @State private var deleteIndex: Int? = nil
    @State private var addReadingItem: PhotosPickerItem? = nil
    @State private var addPictureItem: PhotosPickerItem? = nil
    @State private var addReadingImage: UIImage? = nil
    @State private var addPictureImage: UIImage? = nil
    @State private var addReadingText: String = ""
    @State private var addErrorText: String? = nil
    @State private var isSavingPair: Bool = false
    @State private var isLoadingReading: Bool = false
    @State private var isLoadingPicture: Bool = false

    init(deck: CustomDeck, store: CustomDeckStore) {
        self.deck = deck
        self.store = store
        _deckName = State(initialValue: deck.name)
        _cards = State(initialValue: deck.cards)
        _cardTexts = State(initialValue: deck.cards.map { $0.readingText })
    }

    var body: some View {
        ZStack {
            DigitalBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("EDIT DECK")
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(MonoTheme.text)
                        .kerning(2)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("デッキ名")
                            .font(.custom("AvenirNext-Medium", size: 14))
                            .foregroundColor(MonoTheme.subtleText)
                        TextField("デッキ名", text: $deckName)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(DigitalFieldBackground(cornerRadius: 10))
                            .foregroundColor(MonoTheme.text)
                    }

                    ForEach(cards.indices, id: \.self) { index in
                        cardEditor(index: index)
                    }

                    addSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            DigitalHeaderBar(
                title: "編集",
                onBack: { dismiss() },
                trailingTitle: "保存",
                onTrailing: { save() }
            )
        }
        .alert("このペアを削除しますか？", isPresented: Binding(
            get: { deleteIndex != nil },
            set: { if !$0 { deleteIndex = nil } }
        )) {
            Button("削除", role: .destructive) {
                if let index = deleteIndex {
                    removePair(at: index)
                }
                deleteIndex = nil
            }
            Button("キャンセル", role: .cancel) {
                deleteIndex = nil
            }
        } message: {
            Text("削除したペアは元に戻せません。")
        }
    }

    private func cardEditor(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                deckImage(for: cards[index].readingImagePath)
                deckImage(for: cards[index].pictureImagePath)
                Spacer()
                Button("削除") {
                    deleteIndex = index
                }
                .font(.custom("AvenirNext-Medium", size: 12))
                .foregroundColor(MonoTheme.accent)
            }

            TextEditor(text: bindingForText(index))
                .frame(minHeight: 70)
                .padding(8)
                .background(DigitalFieldBackground(cornerRadius: 10))
                .foregroundColor(MonoTheme.text)
                .scrollContentBackground(.hidden)
        }
    }

    private var addSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("新しいペアを追加")
                .font(.custom("AvenirNext-Medium", size: 14))
                .foregroundColor(MonoTheme.subtleText)

            HStack(spacing: 12) {
                addImagePanel(
                    title: "読み札",
                    image: addReadingImage,
                    isLoading: isLoadingReading
                )
                addImagePanel(
                    title: "絵札",
                    image: addPictureImage,
                    isLoading: isLoadingPicture
                )
            }

            HStack(spacing: 12) {
                PhotosPicker(selection: $addReadingItem, matching: .images) {
                    addPickerLabel(title: "読み札を選ぶ")
                }
                .onChange(of: addReadingItem) { newItem in
                    loadAddImage(item: newItem, isReading: true)
                }

                PhotosPicker(selection: $addPictureItem, matching: .images) {
                    addPickerLabel(title: "絵札を選ぶ")
                }
                .onChange(of: addPictureItem) { newItem in
                    loadAddImage(item: newItem, isReading: false)
                }
            }

            TextField("読み札の文字（OCRが入らない場合に入力）", text: $addReadingText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(DigitalFieldBackground(cornerRadius: 10))
                .foregroundColor(MonoTheme.text)

            if !canAddPair {
                Text("読み札と絵札をそれぞれ選ぶと追加できます。")
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .foregroundColor(MonoTheme.subtleText)
            }

            Button(isSavingPair ? "追加中..." : "このペアを追加") {
                addPair()
            }
            .disabled(!canAddPair || isSavingPair)
            .foregroundColor(MonoTheme.text)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(MonoTheme.text, lineWidth: 1)
            )
            .opacity(!canAddPair || isSavingPair ? 0.5 : 1)

            if let addErrorText {
                Text(addErrorText)
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .foregroundColor(MonoTheme.accent)
            }
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private func deckImage(for fileName: String) -> some View {
        let url = store.imageURL(deckID: deck.id, fileName: fileName)
        if let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .foregroundColor(MonoTheme.subtleText)
        }
    }

    private func bindingForText(_ index: Int) -> Binding<String> {
        Binding(
            get: { cardTexts[safe: index] ?? "" },
            set: { newValue in
                guard cardTexts.indices.contains(index) else { return }
                cardTexts[index] = newValue
            }
        )
    }

    private func save() {
        let trimmedName = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedCards = cards.enumerated().map { offset, card -> CustomDeckCard in
            let text = cardTexts[safe: offset] ?? card.readingText
            return CustomDeckCard(
                id: card.id,
                readingImagePath: card.readingImagePath,
                pictureImagePath: card.pictureImagePath,
                readingText: text
            )
        }
        let updatedDeck = CustomDeck(
            id: deck.id,
            name: trimmedName.isEmpty ? deck.name : trimmedName,
            createdAt: deck.createdAt,
            cards: updatedCards
        )
        store.update(deck: updatedDeck)
        dismiss()
    }

    private func removePair(at index: Int) {
        guard cards.indices.contains(index) else { return }
        cards.remove(at: index)
        if cardTexts.indices.contains(index) {
            cardTexts.remove(at: index)
        }
    }

    private func addPickerLabel(title: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.custom("AvenirNext-Medium", size: 12))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(DigitalFieldBackground(cornerRadius: 10))
        .foregroundColor(MonoTheme.text)
    }

    private func addImagePanel(title: String, image: UIImage?, isLoading: Bool) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.custom("AvenirNext-Medium", size: 12))
                .foregroundColor(MonoTheme.subtleText)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(MonoTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MonoTheme.border, lineWidth: 1)
                    )
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if isLoading {
                    Text("読み込み中...")
                        .font(.custom("AvenirNext-Regular", size: 12))
                        .foregroundColor(MonoTheme.subtleText)
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundColor(MonoTheme.subtleText)
                }
            }
            .frame(height: 120)
        }
        .frame(maxWidth: .infinity)
    }

    private func loadAddImage(item: PhotosPickerItem?, isReading: Bool) {
        guard let item else { return }
        addErrorText = nil
        if isReading {
            isLoadingReading = true
        } else {
            isLoadingPicture = true
        }
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                if isReading {
                    self.isLoadingReading = false
                } else {
                    self.isLoadingPicture = false
                }
                if case .success(let data?) = result, let image = UIImage(data: data) {
                    if isReading {
                        self.addReadingImage = image
                        DispatchQueue.global(qos: .userInitiated).async {
                            let text = OCRManager.recognizeText(from: image)
                            DispatchQueue.main.async {
                                if !text.isEmpty {
                                    self.addReadingText = text
                                }
                            }
                        }
                    } else {
                        self.addPictureImage = image
                    }
                } else {
                    self.addErrorText = "画像の読み込みに失敗しました。"
                }
            }
        }
    }

    private func addPair() {
        guard let reading = addReadingImage, let picture = addPictureImage else { return }
        isSavingPair = true
        addErrorText = nil

        _ = store.makeDeckFolder(deckID: deck.id)
        let token = UUID().uuidString
        let readingName = "reading_\(token).jpg"
        let pictureName = "picture_\(token).jpg"
        let readingURL = store.imageURL(deckID: deck.id, fileName: readingName)
        let pictureURL = store.imageURL(deckID: deck.id, fileName: pictureName)

        let readingSaved = store.saveImage(reading, to: readingURL)
        let pictureSaved = store.saveImage(picture, to: pictureURL)

        if readingSaved && pictureSaved {
            let text = addReadingText.trimmingCharacters(in: .whitespacesAndNewlines)
            let newCard = CustomDeckCard(
                id: UUID(),
                readingImagePath: readingName,
                pictureImagePath: pictureName,
                readingText: text
            )
            cards.append(newCard)
            cardTexts.append(text)
            clearAddState()
        } else {
            addErrorText = "保存に失敗しました。"
        }
        isSavingPair = false
    }

    private func clearAddState() {
        addReadingItem = nil
        addPictureItem = nil
        addReadingImage = nil
        addPictureImage = nil
        addReadingText = ""
    }

    private var canAddPair: Bool {
        addReadingImage != nil && addPictureImage != nil
    }
}

#Preview {
    DeckEditView(deck: CustomDeck(id: UUID(), name: "Sample", createdAt: Date(), cards: []), store: CustomDeckStore())
}
