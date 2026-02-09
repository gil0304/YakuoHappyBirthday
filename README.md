## セットアップ
### APIキー作成
このプロジェクトでは`Google Cloud`の`Text-to-Speech AI`を用いているため、Google Cloud上でAPIを有効にして、APIキーを発行してください

### コード
`GoogleTTSConfig.swift`を作成してそこに以下のコードを記載
```Swift
import Foundation

enum GoogleTTSConfig {
    static let apiKey: String = "Your_API_Key"

    static let languageCode: String = "ja-JP"
    static let ssmlGender: String = "FEMALE"
    static let audioEncoding: String = "MP3"
}
```
