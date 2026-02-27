//
//  ContentView.swift
//  BrickCopy
//
//  Created by Tomas Vodak on 2/26/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Focus", systemImage: "lock.fill") }

            ProfileListView()
                .tabItem { Label("Profiles", systemImage: "person.crop.square.stack.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        .environment(SessionStore())
        .modelContainer(for: [BlockProfile.self, FocusSession.self], inMemory: true)
}
