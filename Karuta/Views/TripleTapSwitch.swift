import SwiftUI

struct TripleTapSwitchModifier: ViewModifier {
    @EnvironmentObject private var appMode: AppMode
    let size: CGFloat

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .simultaneousGesture(
                SpatialTapGesture(count: 3)
                    .onEnded { value in
                        if value.location.x <= size && value.location.y <= size {
                            appMode.toggle()
                        }
                    }
            )
    }
}

extension View {
    func enableTripleTapSwitch(size: CGFloat = 90) -> some View {
        modifier(TripleTapSwitchModifier(size: size))
    }
}
