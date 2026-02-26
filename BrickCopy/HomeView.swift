import SwiftUI

struct HomeView: View {
    @Environment(BlockManager.self) var blockManager
    @State private var showEndConfirmation = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if blockManager.isSessionActive {
                    activeView
                } else {
                    idleView
                }
                Spacer()
            }
            .navigationTitle("BrickCopy")
        }
    }

    private var idleView: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 72))
                    .foregroundColor(.orange)

                Text("Ready to focus?")
                    .font(.title2)
                    .foregroundColor(.secondary)

                if blockManager.selectedApps.isEmpty {
                    Text("No apps selected — go to the Apps tab")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(blockManager.selectedApps.count) app\(blockManager.selectedApps.count == 1 ? "" : "s") selected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Button {
                blockManager.startSession()
            } label: {
                Text("Start Focus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 220, height: 60)
                    .background(Color.orange)
                    .cornerRadius(30)
            }
        }
    }

    private var activeView: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text("Focusing")
                    .font(.title.bold())

                Text(blockManager.formattedTime)
                    .font(.system(size: 72, weight: .thin, design: .monospaced))
                    .foregroundColor(.orange)

                Text("\(blockManager.selectedApps.count) app\(blockManager.selectedApps.count == 1 ? "" : "s") blocked")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Button {
                showEndConfirmation = true
            } label: {
                Text("End Session")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(width: 220, height: 60)
                    .background(Color.red.opacity(0.85))
                    .cornerRadius(30)
            }
            .confirmationDialog("End your focus session?", isPresented: $showEndConfirmation, titleVisibility: .visible) {
                Button("End Session", role: .destructive) { blockManager.endSession() }
                Button("Keep Going", role: .cancel) {}
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(BlockManager())
}
