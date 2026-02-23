import Foundation

extension CharacterSet {
    static let hiragana = CharacterSet(charactersIn: UnicodeScalar(0x3040)!...UnicodeScalar(0x309F)!)
    static let katakana = CharacterSet(charactersIn: UnicodeScalar(0x30A0)!...UnicodeScalar(0x30FF)!)
}
