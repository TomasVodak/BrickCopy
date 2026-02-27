import SwiftUI
import SwiftData

// A single row in the History list.
// Shows: date, duration, number of apps blocked.

struct SessionRowView: View {
    let session: FocusSession

    var body: some View {
        // TODO: full design pass
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                Text(durationString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(session.blockedAppBundleIds.count) apps")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 4)
    }

    private var durationString: String {
        let total = Int(session.duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return String(format: "%dh %02dm", h, m) }
        if m > 0 { return String(format: "%dm %02ds", m, s) }
        return String(format: "%ds", s)
    }
}
