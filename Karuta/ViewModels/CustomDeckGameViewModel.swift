import Combine
import Foundation
import SwiftUI

final class CustomDeckGameViewModel: ObservableObject {
    enum ReadPhase {
        case idle
        case reading
        case picture
    }

    @Published var phase: ReadPhase = .idle
    @Published var countdownSeconds: Int? = nil
    @Published var currentCard: CustomDeckCard? = nil
    @Published var currentRound: Int = 0
    @Published var totalCards: Int = 0
    @Published var isPlaying: Bool = false
    @Published var isCompleted: Bool = false

    private let deck: CustomDeck
    private var cards: [CustomDeckCard]
    private var currentIndex: Int = 0
    private var sessionId = UUID()
    private let audio = AudioManager()

    init(deck: CustomDeck) {
        self.deck = deck
        self.cards = deck.cards
        self.totalCards = deck.cards.count
    }

    var canGoNext: Bool {
        !isPlaying && countdownSeconds == nil && currentRound > 0 && !isCompleted
    }

    func startGame() {
        guard !cards.isEmpty else { return }
        cards.shuffle()
        currentIndex = 0
        currentCard = cards.first
        currentRound = 1
        phase = .idle
        isCompleted = false
        startCountdown(seconds: 3, sessionId: sessionId) {
            self.startReading()
        }
    }

    func startReading() {
        guard currentCard != nil else { return }
        cancelCountdown()
        sessionId = UUID()
        let currentSession = sessionId
        isPlaying = true
        phase = .reading
        audio.stop()

        let text = currentCard?.readingText.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            finishFirstReading(sessionId: currentSession, text: text)
            return
        }

        audio.speak(text: text, localeIdentifier: "ja-JP") {
            self.finishFirstReading(sessionId: currentSession, text: text)
        }
    }

    func nextCard() {
        guard canGoNext else { return }
        sessionId = UUID()
        phase = .idle
        isPlaying = false

        if currentIndex + 1 < cards.count {
            currentIndex += 1
        } else {
            isCompleted = true
            return
        }
        currentRound = currentIndex + 1
        currentCard = cards[safe: currentIndex]

        let currentSession = sessionId
        startCountdown(seconds: 3, sessionId: currentSession) {
            self.startReading()
        }
    }

    func stop() {
        sessionId = UUID()
        audio.stop()
        cancelCountdown()
        isPlaying = false
        phase = .idle
    }

    private func showPicture(after delay: TimeInterval, sessionId: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard self.sessionId == sessionId else { return }
            self.phase = .picture

            let text = self.currentCard?.readingText.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if text.isEmpty {
                self.finishSecondReading(sessionId: sessionId)
                return
            }
            self.audio.speak(text: text, localeIdentifier: "ja-JP") {
                self.finishSecondReading(sessionId: sessionId)
            }
        }
    }

    private func finishFirstReading(sessionId: UUID, text: String) {
        guard self.sessionId == sessionId else { return }
        showPicture(after: 3.0, sessionId: sessionId)
    }

    private func finishSecondReading(sessionId: UUID) {
        guard self.sessionId == sessionId else { return }
        isPlaying = false
        if currentRound >= totalCards {
            isCompleted = true
        }
    }

    private func startCountdown(seconds: Int, sessionId: UUID, onFinish: @escaping () -> Void) {
        cancelCountdown()
        countdownSeconds = seconds

        func tick(_ remaining: Int) {
            guard self.sessionId == sessionId else { return }
            self.countdownSeconds = remaining
            if remaining <= 1 {
                self.countdownSeconds = nil
                onFinish()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    tick(remaining - 1)
                }
            }
        }

        tick(seconds)
    }

    private func cancelCountdown() {
        countdownSeconds = nil
    }
}
