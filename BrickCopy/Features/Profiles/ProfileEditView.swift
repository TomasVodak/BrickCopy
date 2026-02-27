import SwiftUI
import SwiftData

// Edits an existing BlockProfile or creates a new one.
// Pass `profile: nil` from ProfileListView to create; a non-nil value to edit.
struct ProfileEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // nil → "Add Profile" mode with local state, inserted on Save
    var existingProfile: BlockProfile?

    // Local state (used for both new and edit to keep the form consistent)
    @State private var name: String
    @State private var colorHex: String
    @State private var symbolName: String
    @State private var blockedBundleIds: Set<String>
    @State private var lockMode: Bool

    @State private var nfcService = NFCService()
    @State private var showNFCError = false
    @State private var nfcSuccessMessage: String?
    @State private var linkedTagId: String?  // mirrors profile.nfcTagId locally

    init(existingProfile: BlockProfile? = nil) {
        self.existingProfile = existingProfile
        _name             = State(initialValue: existingProfile?.name ?? "")
        _colorHex         = State(initialValue: existingProfile?.colorHex ?? "FF6B35")
        _symbolName       = State(initialValue: existingProfile?.symbolName ?? "lock.fill")
        _blockedBundleIds = State(initialValue: Set(existingProfile?.blockedBundleIds ?? []))
        _lockMode         = State(initialValue: existingProfile?.lockMode ?? false)
        _linkedTagId      = State(initialValue: existingProfile?.nfcTagId)
    }

    private var isNew: Bool { existingProfile == nil }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationView {
            Form {
                nameSection
                appearanceSection
                appsSection
                nfcSection
                if !isNew {
                    deleteSection
                }
            }
            .navigationTitle(isNew ? "New Profile" : "Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
            .alert("NFC Error", isPresented: $showNFCError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(nfcService.errorMessage ?? "Unknown error")
            }
            .onChange(of: nfcService.errorMessage) { _, msg in
                showNFCError = msg != nil
            }
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        Section("Profile Name") {
            TextField("e.g. Deep Work", text: $name)
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            // Color picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Color").font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    ForEach(BlockProfile.colorOptions, id: \.hex) { option in
                        Circle()
                            .fill(Color(hex: option.hex))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: colorHex == option.hex ? 3 : 0)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(Color(hex: option.hex), lineWidth: colorHex == option.hex ? 2 : 0)
                                    .scaleEffect(1.2)
                            )
                            .onTapGesture { colorHex = option.hex }
                    }
                }
            }
            .padding(.vertical, 4)

            // Icon picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Icon").font(.subheadline).foregroundStyle(.secondary)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                    ForEach(BlockProfile.symbolOptions, id: \.self) { symbol in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(symbolName == symbol
                                      ? Color(hex: colorHex).opacity(0.2)
                                      : Color(.systemGray5))
                                .frame(width: 36, height: 36)
                            Image(systemName: symbol)
                                .font(.system(size: 16))
                                .foregroundStyle(symbolName == symbol ? Color(hex: colorHex) : .secondary)
                        }
                        .onTapGesture { symbolName = symbol }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var appsSection: some View {
        Section {
            ForEach(SessionStore.presetApps) { app in
                Button {
                    if blockedBundleIds.contains(app.bundleId) {
                        blockedBundleIds.remove(app.bundleId)
                    } else {
                        blockedBundleIds.insert(app.bundleId)
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: app.icon)
                            .frame(width: 36, height: 36)
                            .background(Color(hex: colorHex).opacity(0.15))
                            .foregroundStyle(Color(hex: colorHex))
                            .cornerRadius(8)

                        Text(app.name)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: blockedBundleIds.contains(app.bundleId)
                              ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(blockedBundleIds.contains(app.bundleId)
                                         ? Color(hex: colorHex) : .secondary)
                    }
                }
            }
        } header: {
            Text("Apps to Block")
        } footer: {
            Text("Actual app blocking requires FamilyControls — coming in a future update.")
        }
    }

    private var nfcSection: some View {
        Section {
            Toggle(isOn: $lockMode) {
                Label("Lock Mode", systemImage: "lock.shield.fill")
            }
            .tint(Color(hex: colorHex))

            if NFCService.isAvailable {
                Button {
                    linkNFCTag()
                } label: {
                    HStack {
                        Label(
                            linkedTagId == nil ? "Link NFC Tag" : "Re-link NFC Tag",
                            systemImage: "tag.fill"
                        )
                        Spacer()
                        if linkedTagId != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .disabled(nfcService.isScanning)
            } else {
                Label("NFC not available on this device", systemImage: "tag.slash")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }

            if lockMode && linkedTagId == nil {
                Label("Link a tag so Lock Mode can be unlocked", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            if let msg = nfcSuccessMessage {
                Label(msg, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        } header: {
            Text("NFC Tag")
        } footer: {
            Text("Lock Mode prevents ending a session from the app — only a physical tag tap can stop it.")
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                if let p = existingProfile {
                    modelContext.delete(p)
                    try? modelContext.save()
                }
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Delete Profile")
                    Spacer()
                }
            }
        }
    }

    // MARK: - Actions

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let profile = existingProfile {
            profile.name = trimmedName
            profile.colorHex = colorHex
            profile.symbolName = symbolName
            profile.blockedBundleIds = Array(blockedBundleIds)
            profile.lockMode = lockMode
            profile.nfcTagId = linkedTagId
        } else {
            let profile = BlockProfile(name: trimmedName, colorHex: colorHex, symbolName: symbolName)
            profile.blockedBundleIds = Array(blockedBundleIds)
            profile.lockMode = lockMode
            profile.nfcTagId = linkedTagId
            modelContext.insert(profile)
        }
        try? modelContext.save()
        dismiss()
    }

    private func linkNFCTag() {
        // We need a stable ID to write to the tag.
        // Use the existing profile's UUID, or generate a temporary one for new profiles
        // (the real UUID will be assigned in save(), so we pre-generate it).
        let profileId: String
        if let p = existingProfile {
            profileId = p.id.uuidString
        } else {
            // For a new profile we create a placeholder UUID that will be stored in linkedTagId
            // and later compared when the tag is scanned.
            profileId = UUID().uuidString
        }

        nfcService.write(profileId: profileId) {
            linkedTagId = profileId
            nfcSuccessMessage = "Tag linked! Tap Save to confirm."
        }
    }
}

#Preview {
    ProfileEditView()
        .modelContainer(for: BlockProfile.self, inMemory: true)
}
