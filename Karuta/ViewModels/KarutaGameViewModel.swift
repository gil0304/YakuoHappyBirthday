import SwiftUI
import Combine

final class KarutaGameViewModel: ObservableObject {
    enum Screen {
        case title
        case game
    }

    enum ReadPhase {
        case idle
        case first
        case second
    }

    @Published var screen: Screen = .title
    @Published var phase: ReadPhase = .idle
    @Published var countdownSeconds: Int? = nil
    @Published var currentCard: KarutaCard? = nil
    @Published var currentRound: Int = 0
    @Published var totalCards: Int = 0
    @Published var readTargetCount: Int = 0
    @Published var totalTargets: Int = 0
    @Published var isSpeaking: Bool = false
    @Published var isTargetsComplete: Bool = false

    private let allCards: [KarutaCard]
    private let targetCardIDs: Set<String>
    private var readTargetIDs: Set<String> = []
    private var deck: [KarutaCard] = []
    private var currentIndex = 0
    private var readSessionId = UUID()
    private let audio = AudioManager()

    init(cards: [KarutaCard], targetCardIDs: Set<String>) {
        self.allCards = cards
        self.targetCardIDs = targetCardIDs
        self.totalCards = cards.count
        self.totalTargets = targetCardIDs.count
    }

    var canGoNext: Bool {
        screen == .game && !isSpeaking && countdownSeconds == nil && currentRound > 0
    }

    func startGame() {
        guard !allCards.isEmpty else { return }

        resetSession()
        deck = allCards.shuffled()
        totalCards = deck.count
        currentIndex = 0
        currentCard = deck.first
        currentRound = 1
        readTargetIDs = []
        readTargetCount = 0
        isTargetsComplete = false
        screen = .game

        let sessionId = readSessionId
        startCountdown(seconds: 5, sessionId: sessionId) {
            self.startReading()
        }
    }

    func startReading() {
        guard screen == .game, let card = currentCard, !isTargetsComplete else { return }

        cancelCountdown()
        let sessionId = UUID()
        readSessionId = sessionId
        phase = .first
        isSpeaking = true
        audio.stop()

        audio.playOrSpeak(fileName: card.audioFileName, fallbackText: card.text, localeIdentifier: "ja-JP") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                guard self.readSessionId == sessionId else { return }
                self.phase = .second
                self.audio.playOrSpeak(fileName: card.audioFileName, fallbackText: card.text, localeIdentifier: "ja-JP") {
                    guard self.readSessionId == sessionId else { return }
                    self.isSpeaking = false
                    self.markCurrentCardRead()
                    if self.hasCompletedTargets {
                        self.isTargetsComplete = true
                        self.readSessionId = UUID()
                    }
                }
            }
        }
    }

    func nextCard() {
        guard canGoNext, !isTargetsComplete else { return }
        audio.stop()
        isSpeaking = false
        readSessionId = UUID()
        phase = .idle

        if currentIndex + 1 < deck.count {
            currentIndex += 1
            currentRound = currentIndex + 1
        } else {
            deck = allCards.shuffled()
            currentIndex = 0
            currentRound = 1
        }
        currentCard = deck[safe: currentIndex]

        let sessionId = readSessionId
        startCountdown(seconds: 3, sessionId: sessionId) {
            self.startReading()
        }
    }

    func returnToTitle() {
        resetSession()
        screen = .title
    }

    // MARK: - Helpers

    private var hasCompletedTargets: Bool {
        !targetCardIDs.isEmpty && readTargetIDs.isSuperset(of: targetCardIDs)
    }

    private func markCurrentCardRead() {
        guard let card = currentCard else { return }
        if targetCardIDs.contains(card.id) {
            readTargetIDs.insert(card.id)
            readTargetCount = readTargetIDs.count
        }
    }

    private func resetSession() {
        audio.stop()
        cancelCountdown()
        phase = .idle
        isSpeaking = false
        isTargetsComplete = false
        readSessionId = UUID()
        currentRound = 0
        currentIndex = 0
        currentCard = nil
        deck = []
    }

    private func startCountdown(seconds: Int, sessionId: UUID, onFinish: @escaping () -> Void) {
        cancelCountdown()
        countdownSeconds = seconds

        func tick(_ remaining: Int) {
            guard self.readSessionId == sessionId else { return }
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
