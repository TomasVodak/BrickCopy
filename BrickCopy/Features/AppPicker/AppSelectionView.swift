import SwiftUI

// Reusable app-selection list. Moved out of the tab bar — app selection now
// lives inside ProfileEditView. This component accepts an explicit binding so
// it can be dropped into any view that manages a set of blocked bundle IDs.
struct AppSelectionView: View {
    @Binding var selectedBundleIds: Set<String>
    var accentColor: Color = .orange

    var body: some View {
        List {
            Section {
                ForEach(SessionStore.presetApps) { app in
                    Button {
                        if selectedBundleIds.contains(app.bundleId) {
                            selectedBundleIds.remove(app.bundleId)
                        } else {
                            selectedBundleIds.insert(app.bundleId)
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: app.icon)
                                .frame(width: 36, height: 36)
                                .background(accentColor.opacity(0.15))
                                .foregroundStyle(accentColor)
                                .cornerRadius(8)

                            Text(app.name)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: selectedBundleIds.contains(app.bundleId)
                                  ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedBundleIds.contains(app.bundleId)
                                             ? accentColor : .secondary)
                        }
                    }
                }
            } header: {
                Text("Select apps to block")
            } footer: {
                Text("Actual app blocking requires FamilyControls — coming in a future update.")
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: Set<String> = []
    AppSelectionView(selectedBundleIds: $selected)
}
