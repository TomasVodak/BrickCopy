import Foundation
import SwiftData

// A named, reusable set of apps to block.
// One profile maps to one NFC tag. Tapping the tag activates/deactivates this profile's session.
@Model
class BlockProfile {
    var id: UUID
    var name: String
    var colorHex: String   // hex string, e.g. "FF6B35"
    var symbolName: String // SF Symbol name
    var blockedBundleIds: [String]
    var nfcTagId: String?  // the profile UUID string written to the linked tag; nil = no tag linked
    var lockMode: Bool     // when true, only an NFC tap can end the session
    var createdAt: Date

    init(name: String, colorHex: String = "FF6B35", symbolName: String = "lock.fill") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.blockedBundleIds = []
        self.nfcTagId = nil
        self.lockMode = false
        self.createdAt = .now
    }

    // Palette offered in the UI
    static let colorOptions: [(hex: String, label: String)] = [
        ("FF6B35", "Orange"),
        ("007AFF", "Blue"),
        ("34C759", "Green"),
        ("AF52DE", "Purple"),
        ("FF3B30", "Red"),
        ("5AC8FA", "Teal"),
    ]

    // Icons offered in the UI
    static let symbolOptions: [String] = [
        "lock.fill",
        "brain.head.profile",
        "briefcase.fill",
        "moon.fill",
        "book.fill",
        "dumbbell.fill",
        "music.note",
        "gamecontroller.fill",
    ]
}
