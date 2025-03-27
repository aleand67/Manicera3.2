//
//  ContentView.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.modelContext) var modelContext
//    @Query var stats: [PlayerStats]
//    @Query var boxScores: [BoxScore]
    
    @EnvironmentObject var turns: TurnsModel
    @EnvironmentObject var game: CurrentBoxScore
    
    @State private var selectedTab = "Middle"
    @State var hideStatusBar = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            StatsView()
                .tabItem{Image(systemName:"number")}
                .tag("Left")
                .onAppear{hideStatusBar = false}
            
            ScoreboardView()
                .tabItem{Image(systemName:"timelapse")}
                .tag("Middle")
                .onAppear{hideStatusBar = true}
            
            BoxScoreView()
                .tabItem{Image(systemName:"table")}
                .tag("Right")
                .onAppear{hideStatusBar = false}
            
        }
        .tabViewStyle(.page(indexDisplayMode: .always)) //sets indicator/control of tabs at bottom
        .indexViewStyle(.page(backgroundDisplayMode: .always)) //puts clipped shape around indicator/control
        .statusBar(hidden: hideStatusBar)
        .ignoresSafeArea()
        .onChange(of: selectedTab) {
            UserDefaults.standard.wasSwipingUsed = true
        }
    }
}

