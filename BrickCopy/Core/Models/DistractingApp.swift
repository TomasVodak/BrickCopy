import Foundation

struct DistractingApp: Identifiable {
    let id = UUID()
    let name: String
    let bundleId: String
    let icon: String // SF Symbol name
}
