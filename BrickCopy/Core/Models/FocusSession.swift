import Foundation
import SwiftData

// Persisted record of a completed focus session.
// Snapshot values are copied at session end so history stays accurate
// even if the profile is later edited or deleted.
@Model
class FocusSession {
    var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var profileName: String           // snapshot of profile name at session end
    var blockedAppBundleIds: [String] // snapshot of blocked apps at session end

    var duration: TimeInterval {
        (endedAt ?? .now).timeIntervalSince(startedAt)
    }

    init(startedAt: Date, profileName: String, blockedAppBundleIds: [String]) {
        self.id = UUID()
        self.startedAt = startedAt
        self.profileName = profileName
        self.blockedAppBundleIds = blockedAppBundleIds
    }
}
