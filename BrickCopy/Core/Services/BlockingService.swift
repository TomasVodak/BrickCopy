import Foundation

// Wraps Apple's FamilyControls + ManagedSettings frameworks.
//
// Requirements before this can be implemented:
//   1. Paid Apple Developer account
//   2. FamilyControls entitlement (request at developer.apple.com)
//   3. Add "Family Controls" capability in Xcode → Signing & Capabilities
//   4. Add a DeviceActivityMonitor extension target for background enforcement
//
// Until then, all methods are no-ops and the app operates in "stub" mode.

class BlockingService {

    // Request Screen Time authorization from the user.
    // Must be called once before any blocking can happen.
    func requestAuthorization() async throws {
        // TODO: AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }

    // Apply blocks for the given bundle IDs using ManagedSettingsStore.
    func blockApps(_ bundleIds: Set<String>) {
        // TODO: store.application.blockedApplications = <tokens from FamilyActivitySelection>
    }

    // Remove all active blocks.
    func unblockAll() {
        // TODO: store.clearAllSettings()
    }
}
