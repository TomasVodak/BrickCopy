import SwiftUI

// Presents Apple's system FamilyActivityPicker sheet.
//
// FamilyActivityPicker is the *only* Apple-approved way to let users pick apps
// for Screen Time restrictions. It returns a FamilyActivitySelection (opaque
// token set), NOT bundle ID strings — so AppSelectionView will need to be
// updated to store FamilyActivitySelection instead of [String] once
// BlockingService is wired up.
//
// Requires: FamilyControls entitlement.

struct AppPickerButton: View {
    var body: some View {
        // TODO: present FamilyActivityPicker via .familyActivityPicker(isPresented:selection:)
        Text("Pick apps (requires FamilyControls entitlement)")
            .foregroundColor(.secondary)
            .font(.caption)
    }
}

#Preview {
    AppPickerButton()
}
