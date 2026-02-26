import Foundation
import SwiftData

// Persisted record of a completed focus session.
// Stored via SwiftData — every call to SessionStore.endSession() creates one.
@Model
class FocusSession {
    var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var blockedAppBundleIds: [String]

    var duration: TimeInterval {
        (endedAt ?? .now).timeIntervalSince(startedAt)
    }

    init(startedAt: Date, blockedAppBundleIds: [String]) {
        self.id = UUID()
        self.startedAt = startedAt
        self.blockedAppBundleIds = blockedAppBundleIds
    }
}
