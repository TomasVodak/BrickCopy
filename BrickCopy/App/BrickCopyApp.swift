//
//  BrickCopyApp.swift
//  BrickCopy
//
//  Created by Tomas Vodak on 2/26/26.
//

import SwiftUI
import SwiftData

@main
struct BrickCopyApp: App {
    @State private var sessionStore = SessionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionStore)
        }
        .modelContainer(for: [BlockProfile.self, FocusSession.self])
    }
}
