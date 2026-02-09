import SwiftUI

struct SimpleSpeakView: View {
    let onOpenKaruta: () -> Void

    @State private var text: String = ""
    @State private var isSpeaking: Bool = false
    @State private var audio = AudioManager()
    @FocusState private var isInputFocused: Bool

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(white: 0.96)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("読み上げ")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 28))
                    .foregroundColor(.black)

                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("ここに読み上げる文字を入力")
                            .font(.custom("Hiragino Maru Gothic ProN", size: 16))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                    }

                    TextEditor(text: $text)
                        .font(.custom("Hiragino Maru Gothic ProN", size: 18))
                        .foregroundColor(.black)
                        .focused($isInputFocused)
                        .padding(8)
                        .frame(minHeight: 160)
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.15), lineWidth: 1)
                        )
                )

                Button {
                    speak()
                } label: {
                    Text(isSpeaking ? "読み上げ中..." : "読み上げ")
                        .font(.custom("Hiragino Maru Gothic ProN", size: 18))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                                )
                        )
                }
                .disabled(trimmedText.isEmpty || isSpeaking)
                .opacity(trimmedText.isEmpty || isSpeaking ? 0.6 : 1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .onTapGesture {
                isInputFocused = false
            }

            Color.clear
                .frame(width: 90, height: 90)
                .contentShape(Rectangle())
                .onTapGesture(count: 3) {
                    onOpenKaruta()
                }
        }
        .onDisappear {
            audio.stop()
            isSpeaking = false
        }
    }

    private func speak() {
        let value = trimmedText
        guard !value.isEmpty else { return }
        isInputFocused = false
        isSpeaking = true
        audio.speak(text: value, localeIdentifier: "ja-JP") {
            isSpeaking = false
        }
    }
}

#Preview {
    SimpleSpeakView(onOpenKaruta: {})
}
