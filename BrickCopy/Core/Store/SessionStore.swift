import Foundation
import Observation
import UIKit
import SwiftData

@Observable
class SessionStore {

    // MARK: - Live session state

    var isSessionActive = false
    var elapsedSeconds = 0
    var currentProfile: BlockProfile?

    // When lockMode is on and the profile has a linked tag, the session can
    // only be ended by scanning that tag — not by tapping a button.
    var isLocked: Bool {
        guard let profile = currentProfile else { return false }
        return profile.lockMode && profile.nfcTagId != nil
    }

    // Injected from the view layer so the store can persist sessions without
    // importing SwiftUI or being a View itself.
    var modelContext: ModelContext?

    // MARK: - Private

    private var timer: Timer?
    private var sessionStartedAt: Date = .now

    // MARK: - Preset apps (used by ProfileEditView for app selection)

    static let presetApps: [DistractingApp] = [
        DistractingApp(name: "Instagram",   bundleId: "com.burbn.instagram",         icon: "camera"),
        DistractingApp(name: "TikTok",      bundleId: "com.zhiliaoapp.musically",    icon: "music.note"),
        DistractingApp(name: "Twitter / X", bundleId: "com.atebits.Tweetie2",        icon: "bubble.left"),
        DistractingApp(name: "YouTube",     bundleId: "com.google.ios.youtube",      icon: "play.rectangle.fill"),
        DistractingApp(name: "Reddit",      bundleId: "com.reddit.Reddit",           icon: "text.bubble.fill"),
        DistractingApp(name: "Snapchat",    bundleId: "com.toyopagroup.picaboo",     icon: "face.smiling"),
        DistractingApp(name: "Facebook",    bundleId: "com.facebook.Facebook",       icon: "person.2.fill"),
        DistractingApp(name: "WhatsApp",    bundleId: "net.whatsapp.WhatsApp",       icon: "message.fill"),
        DistractingApp(name: "Discord",     bundleId: "com.hammerandchisel.discord", icon: "headphones"),
        DistractingApp(name: "Telegram",    bundleId: "ph.telegra.Telegraph",        icon: "paperplane.fill"),
        DistractingApp(name: "LinkedIn",    bundleId: "com.linkedin.LinkedIn",       icon: "briefcase.fill"),
        DistractingApp(name: "Pinterest",   bundleId: "pinterest",                   icon: "mappin"),
    ]

    // MARK: - Session lifecycle

    func startSession(with profile: BlockProfile) {
        currentProfile = profile
        sessionStartedAt = .now
        isSessionActive = true
        elapsedSeconds = 0
        startTimer()
        // TODO: BlockingService.shared.blockApps(profile.blockedBundleIds)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    // Ends the session and saves a FocusSession record.
    // Call only when the session is legitimately allowed to end
    // (i.e. either not locked, or called after a successful NFC scan).
    func endSession() {
        guard let profile = currentProfile else { return }
        saveSession(profile: profile)
        isSessionActive = false
        currentProfile = nil
        stopTimer()
        // TODO: BlockingService.shared.unblockAll()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // Returns false and does nothing when the session is locked.
    // Use this for the manual "End Session" button path.
    @discardableResult
    func tryEndManually() -> Bool {
        guard !isLocked else { return false }
        endSession()
        return true
    }

    // Called by NFCService after a successful tag read.
    // Starts a session if idle, ends it if the correct tag is scanned.
    func handleTagScan(profileId: String, allProfiles: [BlockProfile]) {
        if isSessionActive {
            if currentProfile?.id.uuidString == profileId {
                endSession() // correct tag — end even if locked
            }
            // Wrong tag during a locked session: ignore (UI shows feedback)
        } else {
            if let profile = allProfiles.first(where: { $0.id.uuidString == profileId }) {
                startSession(with: profile)
            }
        }
    }

    // MARK: - Display

    var formattedTime: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Private helpers

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func saveSession(profile: BlockProfile) {
        guard let context = modelContext else { return }
        let session = FocusSession(
            startedAt: sessionStartedAt,
            profileName: profile.name,
            blockedAppBundleIds: profile.blockedBundleIds
        )
        session.endedAt = .now
        context.insert(session)
        try? context.save()
    }
}
