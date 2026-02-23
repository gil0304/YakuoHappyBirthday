import Combine

final class AppMode: ObservableObject {
    @Published var showClassic = false

    func toggle() {
        showClassic.toggle()
    }
}
