import SwiftUI
import SwiftData

struct ProfileListView: View {
    @Query(sort: \BlockProfile.createdAt) private var profiles: [BlockProfile]
    @State private var showAddSheet = false

    var body: some View {
        NavigationView {
            Group {
                if profiles.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Profiles")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ProfileEditView()
            }
        }
    }

    private var list: some View {
        List {
            ForEach(profiles) { profile in
                NavigationLink {
                    ProfileEditView(existingProfile: profile)
                        .navigationBarBackButtonHidden()
                } label: {
                    ProfileRowView(profile: profile)
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Profiles", systemImage: "person.crop.square.badge.plus")
        } description: {
            Text("Tap + to create your first focus profile.")
        } actions: {
            Button("Create Profile") { showAddSheet = true }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
        }
    }
}

#Preview {
    ProfileListView()
        .modelContainer(for: BlockProfile.self, inMemory: true)
}
