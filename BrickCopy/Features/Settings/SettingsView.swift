import SwiftUI

// User-configurable preferences.
// Planned settings:
//   - Default session duration (open-ended vs fixed timer)
//   - Daily reminder notification toggle + time picker
//   - Haptic feedback toggle
//   - Streak goal

struct SettingsView: View {
    var body: some View {
        NavigationView {
            // TODO
            List {
                Section("Session") {
                    // TODO: default duration picker
                    Text("Default duration — coming soon")
                        .foregroundColor(.secondary)
                }
                Section("Notifications") {
                    // TODO: daily reminder toggle
                    Text("Daily reminder — coming soon")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
