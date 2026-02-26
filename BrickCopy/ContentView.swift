//
//  ContentView.swift
//  BrickCopy
//
//  Created by Tomas Vodak on 2/26/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Focus", systemImage: "lock.fill") }

            AppSelectionView()
                .tabItem { Label("Apps", systemImage: "square.grid.2x2") }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        .environmentObject(BlockManager())
}
