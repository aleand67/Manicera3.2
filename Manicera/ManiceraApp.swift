//
//  ManiceraApp.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI
import SwiftData

@main
struct ManiceraApp: App {

    let turns = TurnsModel()
    let currentBoxScore = CurrentBoxScore()
    
    var body: some Scene {
        WindowGroup{
            ContentView()
                .environmentObject(turns)
                .environmentObject(currentBoxScore)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true}
        }
        .modelContainer(for: [BoxScore.self, PlayerStats.self])
        .environment(turns)
        .environment(currentBoxScore)
    }
}
