import SwiftUI

struct ProfileRowView: View {
    let profile: BlockProfile

    var body: some View {
        HStack(spacing: 14) {
            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: profile.colorHex).opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: profile.symbolName)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: profile.colorHex))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(profile.name)
                    .font(.body.weight(.medium))

                HStack(spacing: 8) {
                    Label(
                        "\(profile.blockedBundleIds.count) app\(profile.blockedBundleIds.count == 1 ? "" : "s")",
                        systemImage: "square.grid.2x2"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if profile.lockMode {
                        Label("Lock", systemImage: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(Color(hex: profile.colorHex))
                    }

                    if profile.nfcTagId != nil {
                        Label("Tag linked", systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}
