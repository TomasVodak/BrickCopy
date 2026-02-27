import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(SessionStore.self) var store
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BlockProfile.createdAt) private var profiles: [BlockProfile]

    @State private var nfcService = NFCService()
    @State private var showEndConfirmation = false
    @State private var showNFCError = false
    @State private var wrongTagMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if store.isSessionActive {
                    activeView
                } else {
                    idleView
                }
                Spacer()
            }
            .navigationTitle("BrickCopy")
            .onAppear { store.modelContext = modelContext }
            .alert("NFC Error", isPresented: $showNFCError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(nfcService.errorMessage ?? "Unknown error")
            }
            .alert("Wrong Tag", isPresented: Binding(
                get: { wrongTagMessage != nil },
                set: { if !$0 { wrongTagMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(wrongTagMessage ?? "")
            }
            .onChange(of: nfcService.errorMessage) { _, msg in
                showNFCError = msg != nil
            }
        }
    }

    // MARK: - Idle view

    private var idleView: some View {
        VStack(spacing: 32) {
            // NFC scan button (primary action)
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.12))
                        .frame(width: 120, height: 120)
                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.orange)
                }

                Text("Tap your tag to start")
                    .font(.title3.weight(.medium))

                if NFCService.isAvailable {
                    Button {
                        scanTag()
                    } label: {
                        Label("Scan Tag", systemImage: "tag.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 180, height: 50)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                    .disabled(nfcService.isScanning)
                }
            }

            // Manual profile list
            if !profiles.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Or start manually")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ForEach(profiles) { profile in
                        Button {
                            store.startSession(with: profile)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: profile.colorHex).opacity(0.15))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: profile.symbolName)
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color(hex: profile.colorHex))
                                }
                                Text(profile.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if profile.lockMode {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                Text("Create a profile to get started")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Active session view

    private var activeView: some View {
        VStack(spacing: 32) {
            // Profile badge
            if let profile = store.currentProfile {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: profile.colorHex).opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: profile.symbolName)
                            .font(.system(size: 36))
                            .foregroundStyle(Color(hex: profile.colorHex))
                    }
                    Text(profile.name)
                        .font(.title3.weight(.semibold))
                    Text("\(profile.blockedBundleIds.count) app\(profile.blockedBundleIds.count == 1 ? "" : "s") blocked")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Timer ring
            RingTimerView(elapsed: store.elapsedSeconds, progress: 0)

            // Lock mode indicator
            if store.isLocked {
                Label("Session locked — tap your tag to end", systemImage: "lock.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            }

            // Action buttons
            VStack(spacing: 12) {
                if NFCService.isAvailable && store.isLocked {
                    // When locked, the primary way to end is NFC
                    Button {
                        scanTagToEnd()
                    } label: {
                        Label("Scan Tag to End", systemImage: "tag.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 220, height: 56)
                            .background(Color(hex: store.currentProfile?.colorHex ?? "FF6B35"))
                            .clipShape(Capsule())
                    }
                    .disabled(nfcService.isScanning)
                } else if !store.isLocked {
                    Button {
                        showEndConfirmation = true
                    } label: {
                        Text("End Session")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .frame(width: 220, height: 56)
                            .background(Color.red.opacity(0.85))
                            .clipShape(Capsule())
                    }
                    .confirmationDialog(
                        "End your focus session?",
                        isPresented: $showEndConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("End Session", role: .destructive) { store.endSession() }
                        Button("Keep Going", role: .cancel) {}
                    }
                }
            }
        }
    }

    // MARK: - NFC

    private func scanTag() {
        nfcService.read { profileId in
            store.handleTagScan(profileId: profileId, allProfiles: profiles)
        }
    }

    private func scanTagToEnd() {
        nfcService.read { profileId in
            if store.currentProfile?.id.uuidString == profileId {
                store.endSession()
            } else {
                let name = store.currentProfile?.name ?? "this profile"
                wrongTagMessage = "Wrong tag. Scan the "\(name)" tag to end this session."
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(SessionStore())
        .modelContainer(for: [BlockProfile.self, FocusSession.self], inMemory: true)
}
