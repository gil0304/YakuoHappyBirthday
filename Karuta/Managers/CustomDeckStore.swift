import Combine
import Foundation
import UIKit

final class CustomDeckStore: ObservableObject {
    @Published private(set) var decks: [CustomDeck] = []

    private let fileName = "custom_decks.json"
    private let deckFolderName = "CustomDecks"

    init() {
        load()
    }

    func add(deck: CustomDeck) {
        decks.insert(deck, at: 0)
        save()
    }

    func delete(deck: CustomDeck) {
        decks.removeAll { $0.id == deck.id }
        removeDeckFolder(deckID: deck.id)
        save()
    }

    func update(deck: CustomDeck) {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
            save()
        }
    }

    func makeDeckFolder(deckID: UUID) -> URL? {
        let folder = decksDirectory().appendingPathComponent(deckID.uuidString, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            return folder
        } catch {
            return nil
        }
    }

    func saveImage(_ image: UIImage, to url: URL) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return false }
        do {
            try data.write(to: url, options: [.atomic])
            return true
        } catch {
            return false
        }
    }

    func imageURL(deckID: UUID, fileName: String) -> URL {
        decksDirectory()
            .appendingPathComponent(deckID.uuidString, isDirectory: true)
            .appendingPathComponent(fileName)
    }

    private func decksDirectory() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(deckFolderName, isDirectory: true)
    }

    private func load() {
        let url = decksFileURL()
        guard let data = try? Data(contentsOf: url) else {
            decks = []
            return
        }
        decks = (try? JSONDecoder().decode([CustomDeck].self, from: data)) ?? []
    }

    private func save() {
        let url = decksFileURL()
        do {
            let data = try JSONEncoder().encode(decks)
            try data.write(to: url, options: [.atomic])
        } catch {
            return
        }
    }

    private func decksFileURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }

    private func removeDeckFolder(deckID: UUID) {
        let folder = decksDirectory().appendingPathComponent(deckID.uuidString, isDirectory: true)
        try? FileManager.default.removeItem(at: folder)
    }
}
