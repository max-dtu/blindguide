import BlindGuideCore
import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AssistantModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Ask") {
                    ForEach(PerceptionTask.allCases) { task in
                        Button(task.rawValue) {
                            model.run(task)
                        }
                        .accessibilityHint("Speaks the result aloud")
                    }
                }

                Section("Safety") {
                    Button("Call a human") {
                        // Not implemented yet (story 6.1).
                        model.speaker.speak(
                            SpeechRequest(text: "Calling a person is not set up yet.", priority: .userRequested, category: .answer),
                            verbosity: model.verbosity
                        )
                    }
                }

                Section("Settings") {
                    Picker("Verbosity", selection: $model.verbosity) {
                        Text("Silent").tag(Verbosity.silent)
                        Text("Alerts only").tag(Verbosity.alertsOnly)
                        Text("Normal").tag(Verbosity.normal)
                        Text("Descriptive").tag(Verbosity.descriptive)
                    }
                    Toggle("Allow cloud when needed", isOn: $model.cloudEnabled)
                }
            }
            .navigationTitle("BlindGuide")
        }
    }
}
