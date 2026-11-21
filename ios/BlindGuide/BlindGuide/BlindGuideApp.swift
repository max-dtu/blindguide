import SwiftUI

@main
struct BlindGuideApp: App {
    @StateObject private var model = AssistantModel()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
