import SwiftUI

struct RootView: View {
    enum Screen {
        case simple
        case karuta
    }

    @State private var screen: Screen = .simple

    var body: some View {
        switch screen {
        case .simple:
            SimpleSpeakView {
                screen = .karuta
            }
        case .karuta:
            ContentView()
        }
    }
}

#Preview {
    RootView()
}
