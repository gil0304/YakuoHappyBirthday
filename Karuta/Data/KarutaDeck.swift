import Foundation

enum KarutaDeck {
    static let cards: [KarutaCard] = [
        KarutaCard(text: "あかねきりしま　たくさん飲もう！", description: "茜霧島を飲んだことある人が飲む", imageName: "あ_絵札", audioFileName: "あ_音声.m4a"),
        KarutaCard(text: "いつでも　でてくる　関西弁", description: "関西に住んだことがある人が飲む", imageName: "い_絵札", audioFileName: "い_音声.m4a"),
        KarutaCard(text: "うわさの　絶えない　14期", description: "14期が全員飲む", imageName: "う_絵札", audioFileName: "う_音声.m4a"),
        KarutaCard(text: "えー　まだ　免許持ってないの", description: "免許持ってない人が飲む", imageName: "え_絵札", audioFileName: "え_音声.m4a"),
        KarutaCard(text: "遅れんなよ ダース", description: "遅刻したことある人が飲む", imageName: "お_絵札", audioFileName: "お_音声.m4a"),
        KarutaCard(text: "かるたサークルに 女を作りに行った やくお", description: "恋人がいない人が飲む", imageName: "か_絵札", audioFileName: "か_音声.m4a"),
        KarutaCard(text: "休憩！！　な訳ないですよね。全員飲みます。", description: "全員飲む", imageName: "き_絵札", audioFileName: "き_音声.m4a"),
        KarutaCard(text: "くろすぎだろ！", description: "多様性認めてないやつが飲む", imageName: "く_絵札", audioFileName: "く_音声.m4a"),
        KarutaCard(text: "けいたん　１７１ｃｍ笑", description: "170cmない人が飲む", imageName: "け_絵札", audioFileName: "け_音声.m4a"),
        KarutaCard(text: "こたは頼れる　お兄ちゃん", description: "こたが1回肩代わりしてくれる", imageName: "こ_絵札", audioFileName: "こ_音声.m4a"),
        KarutaCard(text: "さけを飲むと　全部脱ぐ ねぎさん", description: "ねぎさんが飲む", imageName: "さ_絵札", audioFileName: "さ_音声.m4a"),
        KarutaCard(text: "しょうがないから　俺が飲む", description: "ねぎさんor引いた人が飲む", imageName: "し_絵札", audioFileName: "し_音声.m4a"),
        KarutaCard(text: "せいっ！", description: "せいが飲む", imageName: "せ_絵札", audioFileName: "せ_音声.m4a"),
        KarutaCard(text: "そんなに　乾杯足りないの？？", description: "みんなで乾杯", imageName: "そ_絵札", audioFileName: "そ_音声.m4a"),
        KarutaCard(text: "たぎってるね　せい！", description: "せいが飲む", imageName: "た_絵札", audioFileName: "た_音声.m4a"),
        KarutaCard(text: "ちょっと待って！？やくお飲み足りてなくない？", description: "やくおが飲む", imageName: "ち_絵札", audioFileName: "ち_音声.m4a"),
        KarutaCard(text: "手のひら　大っきな　あいうえお", description: "あいうえおが飲む", imageName: "て_絵札", audioFileName: "て_音声.m4a"),
        KarutaCard(text: "どんどんの　いつもの", description: "かまが好きな人全員飲む", imageName: "と_絵札", audioFileName: "と_音声.m4a"),
        KarutaCard(text: "鳴らせ！　クラッカー！", description: "にゃんにゃんにきたことがある人が飲む", imageName: "な_絵札", audioFileName: "な_音声.m4a"),
        KarutaCard(text: "に期目もスクール続けよう！やくお", description: "やくおが飲む", imageName: "に_絵札", audioFileName: "に_音声.m4a"),
        KarutaCard(text: "ノースはちゃおが大好き", description: "恋人がいる人は飲む", imageName: "の_絵札", audioFileName: "の_音声.m4a"),
        KarutaCard(text: "はやく 飲みたい", description: "今日最初にお店に入った人が飲む", imageName: "は_絵札", audioFileName: "は_音声.m4a"),
        KarutaCard(text: "ひとりじゃ　なくてみんな　で飲もう！", description: "みんなで飲む", imageName: "ひ_絵札", audioFileName: "ひ_音声.m4a"),
        KarutaCard(text: "ふっ　かわいいお酒が　好きなんだね", description: "その場で一番度数の低いものを飲んでる人が飲む", imageName: "ふ_絵札", audioFileName: "ふ_音声.m4a"),
        KarutaCard(text: "偏食なのかな 黒人さんbyやくお", description: "やくおが飲む", imageName: "へ_絵札", audioFileName: "へ_音声.m4a"),
        KarutaCard(text: "ホンマかいな　やくお！", description: "やくおが飲む", imageName: "ほ_絵札", audioFileName: "ほ_音声.m4a"),
        KarutaCard(text: "みんな大好き 金曜スクール！", description: "金曜スクールが飲む", imageName: "み_絵札", audioFileName: "み_音声.m4a"),
        KarutaCard(text: "もっとやくおの パッション見たい", description: "やくおが飲む", imageName: "も_絵札", audioFileName: "も_音声.m4a"),
        KarutaCard(text: "やっぱり みんなで乾杯！", description: "みんなで飲む", imageName: "や_絵札", audioFileName: "や_音声.m4a"),
        KarutaCard(text: "ようこそやくお　金曜スクールへ", description: "やくおが飲む", imageName: "よ_絵札", audioFileName: "よ_音声.m4a"),
        KarutaCard(text: "ライバルと　やくおが飲む", description: "やくおがパッションの分だけ飲む", imageName: "ら_絵札", audioFileName: "ら_音声.m4a"),
        KarutaCard(text: "理科大　ストレートで　卒業したい", description: "高校卒業後4年で卒業できない人が飲む", imageName: "り_絵札", audioFileName: "り_音声.m4a"),
        KarutaCard(text: "るーるを破った人が飲む", description: "取った人がルールを決めて、破ったら飲む", imageName: "る_絵札", audioFileName: "る_音声.m4a"),
    ]

    static let targetCardIDs: Set<String> = [
        "や_絵札",
        "く_絵札",
        "お_絵札"
    ]
}
