import SwiftUI

@main
struct KarutaApp: App {
    @StateObject private var appMode = AppMode()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appMode)
        }
    }
}
