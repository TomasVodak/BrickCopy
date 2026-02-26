import UserNotifications

// Schedules and cancels local notifications tied to focus sessions.
// Planned notifications:
//   - Session end summary ("You focused for 45 min")
//   - Daily reminder nudge (configurable time in Settings)
//   - Streak milestone ("3 days in a row!")

class NotificationService {

    // Request notification permission. Call once at app launch.
    func requestAuthorization() async {
        // TODO: UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    // Fire a "session complete" notification after `seconds` have elapsed.
    func scheduleSessionEndNotification(after seconds: Int) {
        // TODO
    }

    // Schedule a daily nudge at the given hour/minute.
    func scheduleDailyReminder(hour: Int, minute: Int) {
        // TODO
    }

    // Cancel all pending notifications (e.g. when session is ended early).
    func cancelAll() {
        // TODO: UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
