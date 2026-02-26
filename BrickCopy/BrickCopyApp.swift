//
//  BrickCopyApp.swift
//  BrickCopy
//
//  Created by Tomas Vodak on 2/26/26.
//

import SwiftUI

@main
struct BrickCopyApp: App {
    @State private var blockManager = BlockManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(blockManager)
        }
    }
}
