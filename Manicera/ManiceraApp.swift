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
    
    @ObservedObject var turns = TurnsModel()
    @ObservedObject var currentBoxScore = CurrentBoxScore()
    
    var body: some Scene {
        WindowGroup{
            ContentView()
                .environmentObject(turns)
                .environmentObject(currentBoxScore)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true}
        }
        .modelContainer(for: [BoxScore.self, PlayerStats.self])
    }
}
