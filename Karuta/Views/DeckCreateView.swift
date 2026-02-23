import PhotosUI
import SwiftUI
import UIKit

struct DeckCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: CustomDeckStore

    @State private var deckName: String = ""
    @State private var readingItems: [PhotosPickerItem] = []
    @State private var pictureItems: [PhotosPickerItem] = []
    @State private var readingImages: [UIImage] = []
    @State private var readingTexts: [String] = []
    @State private var readingOverrides: [String] = []
    @State private var pictureImages: [UIImage] = []
    @State private var pictureTexts: [String] = []
    @State private var pictureOverrides: [String] = []
    @State private var isLoading: Bool = false
    @State private var errorText: String? = nil

    private var canCreate: Bool {
        !deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        pairCount > 0
    }

    private var pairCount: Int {
        makePairs().count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DigitalBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("NEW DECK")
                            .font(.custom("AvenirNext-Bold", size: 24))
                            .foregroundColor(MonoTheme.text)
                            .kerning(2)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("デッキ名")
                                .font(.custom("AvenirNext-Medium", size: 14))
                                .foregroundColor(MonoTheme.subtleText)
                            TextField("例: しぜん", text: $deckName)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(DigitalFieldBackground(cornerRadius: 10))
                                .foregroundColor(MonoTheme.text)
                        }

                        deckSection(
                            title: "読み札 (画像)",
                            selection: $readingItems,
                            count: readingImages.count
                        )
                        .onChange(of: readingItems) { newItems in
                            loadImagesAndTexts(from: newItems) { images, texts in
                                readingImages = images
                                readingTexts = texts
                                readingOverrides = texts
                            }
                        }

                        deckSection(
                            title: "絵札 (画像)",
                            selection: $pictureItems,
                            count: pictureImages.count
                        )
                        .onChange(of: pictureItems) { newItems in
                            loadImagesAndTexts(from: newItems) { images, texts in
                                pictureImages = images
                                pictureTexts = texts
                                pictureOverrides = texts
                            }
                        }

                        if !readingImages.isEmpty {
                            editSection(
                                title: "読み札テキスト (編集可)",
                                images: readingImages,
                                placeholder: "読み上げテキスト",
                                bindingForIndex: bindingForReadingText
                            )
                        }

                        if !pictureImages.isEmpty {
                            editSection(
                                title: "絵札の先頭文字 (編集可)",
                                images: pictureImages,
                                placeholder: "例: あ",
                                bindingForIndex: bindingForPictureText
                            )
                        }

                        if let errorText {
                            Text(errorText)
                                .font(.custom("AvenirNext-Regular", size: 12))
                                .foregroundColor(MonoTheme.accent)
                        }

                        if isLoading {
                            Text("読み取り中...")
                                .font(.custom("AvenirNext-Regular", size: 12))
                                .foregroundColor(MonoTheme.subtleText)
                        }

                        if pairCount > 0 {
                            Text("一致したペア: \(pairCount) 組")
                                .font(.custom("AvenirNext-Regular", size: 12))
                                .foregroundColor(MonoTheme.subtleText)
                        }

                        Button {
                            createDeck()
                        } label: {
                            Text(isLoading ? "作成中..." : "デッキを作成")
                                .font(.custom("AvenirNext-DemiBold", size: 16))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(MonoTheme.text, lineWidth: 1)
                                )
                        }
                        .disabled(!canCreate || isLoading)
                        .foregroundColor(MonoTheme.text)
                        .opacity(!canCreate || isLoading ? 0.5 : 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            DigitalHeaderBar(title: "デッキ作成", onBack: { dismiss() })
        }
    }

    private func deckSection(
        title: String,
        selection: Binding<[PhotosPickerItem]>,
        count: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("AvenirNext-Medium", size: 14))
                .foregroundColor(MonoTheme.subtleText)
            PhotosPicker(selection: selection, maxSelectionCount: 60, matching: .images) {
                HStack {
                    Text("画像を選ぶ")
                        .font(.custom("AvenirNext-Medium", size: 14))
                    Spacer()
                    Text("\(count) 枚")
                        .font(.custom("AvenirNext-Regular", size: 12))
                        .foregroundColor(MonoTheme.subtleText)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(DigitalFieldBackground(cornerRadius: 10))
            }
            .foregroundColor(MonoTheme.text)
        }
    }

    private func editSection(
        title: String,
        images: [UIImage],
        placeholder: String,
        bindingForIndex: @escaping (Int) -> Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("AvenirNext-Medium", size: 14))
                .foregroundColor(MonoTheme.subtleText)
            ForEach(images.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    TextField(placeholder, text: bindingForIndex(index))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(MonoTheme.surface)
                        )
                        .foregroundColor(MonoTheme.text)
                }
            }
        }
    }

    private func loadImagesAndTexts(
        from items: [PhotosPickerItem],
        onFinish: @escaping ([UIImage], [String]) -> Void
    ) {
        guard !items.isEmpty else {
            onFinish([], [])
            return
        }

        isLoading = true
        errorText = nil
        var results = Array<UIImage?>(repeating: nil, count: items.count)
        let group = DispatchGroup()

        for (index, item) in items.enumerated() {
            group.enter()
            item.loadTransferable(type: Data.self) { result in
                defer { group.leave() }
                if case .success(let data?) = result, let image = UIImage(data: data) {
                    results[index] = image
                }
            }
        }

        group.notify(queue: .main) {
            let images = results.compactMap { $0 }
            if images.isEmpty {
                isLoading = false
                errorText = "画像の読み込みに失敗しました。"
                onFinish([], [])
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let texts = images.map { OCRManager.recognizeText(from: $0) }
                DispatchQueue.main.async {
                    isLoading = false
                    if texts.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                        errorText = "文字認識に失敗しました。"
                    }
                    onFinish(images, texts)
                }
            }
        }
    }

    private func createDeck() {
        let pairs = makePairs()
        guard !pairs.isEmpty else {
            errorText = "文字の一致するペアが見つかりませんでした。"
            return
        }

        let deckID = UUID()
        guard let folder = store.makeDeckFolder(deckID: deckID) else {
            errorText = "保存先の作成に失敗しました。"
            return
        }

        var cards: [CustomDeckCard] = []
        for (index, pair) in pairs.enumerated() {
            let readingName = "reading_\(index).jpg"
            let pictureName = "picture_\(index).jpg"
            let readingURL = folder.appendingPathComponent(readingName)
            let pictureURL = folder.appendingPathComponent(pictureName)

            let readingImage = readingImages[pair.readingIndex]
            let pictureImage = pictureImages[pair.pictureIndex]
            let readingSaved = store.saveImage(readingImage, to: readingURL)
            let pictureSaved = store.saveImage(pictureImage, to: pictureURL)

            if readingSaved && pictureSaved {
                let readingText = readingOverrides[safe: pair.readingIndex] ??
                    readingTexts[safe: pair.readingIndex] ?? ""
                let card = CustomDeckCard(
                    id: UUID(),
                    readingImagePath: readingName,
                    pictureImagePath: pictureName,
                    readingText: readingText
                )
                cards.append(card)
            }
        }

        let deck = CustomDeck(
            id: deckID,
            name: deckName.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date(),
            cards: cards
        )
        store.add(deck: deck)
        dismiss()
    }

    private func makePairs() -> [(readingIndex: Int, pictureIndex: Int)] {
        let readingKeys = readingOverrides.map { initialKey(from: $0) }
        let pictureKeys = pictureOverrides.map { initialKey(from: $0) }
        var usedPictures = Set<Int>()
        var pairs: [(Int, Int)] = []

        for (readingIndex, key) in readingKeys.enumerated() {
            guard let key else { continue }
            if let matchIndex = pictureKeys.enumerated().first(where: { offset, value in
                guard !usedPictures.contains(offset) else { return false }
                return value == key
            })?.offset {
                usedPictures.insert(matchIndex)
                pairs.append((readingIndex, matchIndex))
            }
        }
        return pairs
    }

    private func bindingForReadingText(_ index: Int) -> Binding<String> {
        Binding(
            get: { readingOverrides[safe: index] ?? "" },
            set: { newValue in
                guard readingOverrides.indices.contains(index) else { return }
                readingOverrides[index] = newValue
            }
        )
    }

    private func bindingForPictureText(_ index: Int) -> Binding<String> {
        Binding(
            get: { pictureOverrides[safe: index] ?? "" },
            set: { newValue in
                guard pictureOverrides.indices.contains(index) else { return }
                pictureOverrides[index] = newValue
            }
        )
    }

    private func initialKey(from text: String) -> String? {
        let scalars = text.unicodeScalars.filter { scalar in
            if CharacterSet.whitespacesAndNewlines.contains(scalar) { return false }
            if CharacterSet.punctuationCharacters.contains(scalar) { return false }
            if CharacterSet.symbols.contains(scalar) { return false }
            return true
        }

        if let hiragana = scalars.first(where: { CharacterSet.hiragana.contains($0) }) {
            return String(hiragana)
        }
        if let katakana = scalars.first(where: { CharacterSet.katakana.contains($0) }) {
            return String(katakana)
        }
        if let first = scalars.first {
            return String(first)
        }
        return nil
    }
}

#Preview {
    DeckCreateView(store: CustomDeckStore())
        .environmentObject(AppMode())
}
