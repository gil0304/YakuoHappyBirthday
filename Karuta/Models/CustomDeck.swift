import Foundation

struct CustomDeck: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var createdAt: Date
    var cards: [CustomDeckCard]
}

struct CustomDeckCard: Identifiable, Codable, Hashable {
    let id: UUID
    let readingImagePath: String
    let pictureImagePath: String
    let readingText: String

    enum CodingKeys: String, CodingKey {
        case id
        case readingImagePath
        case pictureImagePath
        case readingText
    }

    init(id: UUID, readingImagePath: String, pictureImagePath: String, readingText: String) {
        self.id = id
        self.readingImagePath = readingImagePath
        self.pictureImagePath = pictureImagePath
        self.readingText = readingText
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        readingImagePath = try container.decode(String.self, forKey: .readingImagePath)
        pictureImagePath = try container.decode(String.self, forKey: .pictureImagePath)
        readingText = try container.decodeIfPresent(String.self, forKey: .readingText) ?? ""
    }
}
