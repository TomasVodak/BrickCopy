import SwiftUI

// Circular progress ring with the elapsed time displayed in the center.
// Used on HomeView during an active session.
//
// `progress` is 0.0–1.0. Pass 0 for an open-ended (spinning) session.

struct RingTimerView: View {
    let elapsed: Int
    let progress: Double // 0.0 = empty, 1.0 = full; use 0 for open-ended

    var body: some View {
        // TODO: full design pass with ZStack + Circle trim animation
        ZStack {
            Circle()
                .stroke(Color.orange.opacity(0.2), lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress > 0 ? progress : 1)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            Text(formattedTime)
                .font(.system(size: 48, weight: .thin, design: .monospaced))
        }
        .frame(width: 220, height: 220)
    }

    private var formattedTime: String {
        let h = elapsed / 3600
        let m = (elapsed % 3600) / 60
        let s = elapsed % 60
        if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    RingTimerView(elapsed: 754, progress: 0.4)
}
