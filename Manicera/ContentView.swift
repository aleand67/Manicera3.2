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
    //@State private var hideStatusBar = true
    @State var archiveDialog: Bool = false
    
    @AppStorage("wasSwipingUsed") var wasSwipingUsed: Bool = false
    @AppStorage("tabsAvailable") var tabsAvailable: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            statsView()
                .tabItem{Image(systemName:"number")}
                .tag("Left")
                .showView(!archiveDialog) // hack so that you can't swipe when saving games
                //.onAppear{hideStatusBar = false} //this doesn't work consistently
            
            scoreboardView(archiveDialog: $archiveDialog)
                .tabItem{Image(systemName:"timelapse")}
                .tag("Middle")
                //.onAppear{hideStatusBar = true} //this doesn't work consistently
            
            boxScoreView()
                .tabItem{Image(systemName:"table")}
                .tag("Right")
                .showView(!archiveDialog) // hack so that you can't swipe when saving games
                //.onAppear{hideStatusBar = false} //this doesn't work consistently
            
        }
        .tabViewStyle(.page(indexDisplayMode: tabsAvailable && !archiveDialog ? .always : .never)) //sets indicator/control of tabs at bottom
        .indexViewStyle(.page(backgroundDisplayMode: .always)) //puts clipped shape around indicator/control
        .statusBar(hidden: true) //because it doesn't work too well 
        .ignoresSafeArea()
        .onChange(of: selectedTab) {
            wasSwipingUsed = true
        }
    }
}

