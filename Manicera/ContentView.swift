//
//  ContentView.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var selectedTab = "Middle"
    @State private var hideStatusBar = true
    
    @AppStorage("wasSwipingUsed") var wasSwipingUsed: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            statsView()
                .tabItem{Image(systemName:"number")}
                .tag("Left")
                .onAppear{hideStatusBar = false}
            
            scoreboardView()
                .tabItem{Image(systemName:"timelapse")}
                .tag("Middle")
                .onAppear{hideStatusBar = true}
            
            boxScoreView()
                .tabItem{Image(systemName:"table")}
                .tag("Right")
                .onAppear{hideStatusBar = false}
            
        }
        .tabViewStyle(.page(indexDisplayMode: .always)) //sets indicator/control of tabs at bottom
        .indexViewStyle(.page(backgroundDisplayMode: .always)) //puts clipped shape around indicator/control
        .statusBar(hidden: hideStatusBar)
        .ignoresSafeArea()
        .onChange(of: selectedTab) {
            wasSwipingUsed = true
        }
    }
}

