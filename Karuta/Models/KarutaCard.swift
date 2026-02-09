import Foundation

struct KarutaCard: Identifiable, Hashable {
    let id: String
    let text: String
    let description: String
    let imageName: String
    let audioFileName: String

    init(text: String, description: String, imageName: String, audioFileName: String) {
        self.id = imageName
        self.text = text
        self.description = description
        self.imageName = imageName
        self.audioFileName = audioFileName
    }
}
