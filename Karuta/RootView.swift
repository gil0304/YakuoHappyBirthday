import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appMode: AppMode

    var body: some View {
        ZStack {
            if appMode.showClassic {
                ContentView()
            } else {
                DecksHomeView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppMode())
}
