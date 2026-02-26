import SwiftUI

struct AppSelectionView: View {
    @Environment(SessionStore.self) var blockManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(SessionStore.presetApps) { app in
                        Button {
                            blockManager.toggleApp(app.bundleId)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: app.icon)
                                    .frame(width: 36, height: 36)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(8)

                                Text(app.name)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: blockManager.selectedApps.contains(app.bundleId)
                                      ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(blockManager.selectedApps.contains(app.bundleId)
                                                     ? .orange : .secondary)
                            }
                        }
                    }
                } header: {
                    Text("Select apps to block")
                } footer: {
                    Text("Actual app blocking will be enabled in a future update once a developer account is added.")
                }
            }
            .navigationTitle("Block Apps")
        }
    }
}

#Preview {
    AppSelectionView()
        .environment(SessionStore())
}
