import SwiftUI
import SwiftData

// List of all completed focus sessions, newest first.
// Uses SwiftData @Query for automatic persistence and live updates.

struct HistoryView: View {
    @Query(sort: \FocusSession.startedAt, order: .reverse)
    private var sessions: [FocusSession]

    var body: some View {
        NavigationView {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No sessions yet",
                        systemImage: "clock.badge.checkmark",
                        description: Text("Complete a focus session to see it here.")
                    )
                } else {
                    List(sessions) { session in
                        SessionRowView(session: session)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: FocusSession.self, inMemory: true)
}
