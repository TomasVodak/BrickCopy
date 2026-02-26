import SwiftUI

@MainActor
class BlockManager: ObservableObject {
    @Published var isSessionActive = false
    @Published var elapsedSeconds = 0
    @Published var selectedApps: Set<String> = []

    private var timer: Timer?

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

    init() {
        if let saved = UserDefaults.standard.array(forKey: "selectedApps") as? [String] {
            selectedApps = Set(saved)
        }
    }

    func startSession() {
        isSessionActive = true
        elapsedSeconds = 0
        startTimer()
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        // TODO: block apps — requires paid developer account (FamilyControls)
    }

    func endSession() {
        isSessionActive = false
        stopTimer()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // TODO: unblock apps — requires paid developer account (FamilyControls)
    }

    func toggleApp(_ bundleId: String) {
        if selectedApps.contains(bundleId) {
            selectedApps.remove(bundleId)
        } else {
            selectedApps.insert(bundleId)
        }
        UserDefaults.standard.set(Array(selectedApps), forKey: "selectedApps")
    }

    var formattedTime: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
