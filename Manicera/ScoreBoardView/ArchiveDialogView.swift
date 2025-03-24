//
//  ArchiveDialogView.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI
import SwiftData

enum FocusableField: Hashable {
  case orange
  case white
}

struct ArchiveDialogView: View {
    
    @FocusState var focus: FocusableField?
    @Environment(\.modelContext) var modelContext
    @Query var stats: [PlayerStats]
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @EnvironmentObject var turns: TurnsModel
    @EnvironmentObject var currentBoxScore: CurrentBoxScore
    
    @State private var showingConfirmation = false
    @State var orangePlayerNameDialog = false
    @State var whitePlayerNameDialog = false
    @State var orangePlayerName: String = ""
    @State var whitePlayerName: String = ""
    @Binding var newGameFlash: Bool
    @Binding var archiveDialog: Bool
    
    var body: some View {
        
        let nameList = fetchNames()
        
        GeometryReader {geometry in
            HStack{
                let tall = geometry.size.height
                let wide = geometry.size.width
                
                let wideLeftFactor = verticalSizeClass == .compact ? 0.105 : 0.155 //fine tuning placement orange text input
                
                let wideRightFactor = verticalSizeClass == .compact ? 0.1275 : 0.175 //fine tuning placement white text input
                               
                if (orangePlayerNameDialog == false && whitePlayerNameDialog == false) {
                    Button("Keep Game") {
                    orangePlayerNameDialog = true
                    focus = .orange
                    }// if tapped, show textFields, focus on orange one
                    .buttonStyle(GreenPill())
                    .offset(x: -wide*wideLeftFactor, y: tall*0.055)
                } // if not getting names yet show "keep game"
                else {
                    ZStack (alignment: .leading){
                        TextField("", text: $orangePlayerName)
                            .playerNameStyle(color: Color("OrangeManicera"), width: wide * 0.3)
                            .focused($focus, equals: .orange)
                            .onSubmit {
                               checkForNamesAndSave(playerName: orangePlayerName, otherPlayerName: whitePlayerName, playerNameDialog: $orangePlayerNameDialog, otherPlayerNameDialog: $whitePlayerNameDialog)
                         }
                        
                        if orangePlayerName.isEmpty {
                            Text("Name")
                                .textFieldPromptStyle(color: Color("OrangeManicera"))
                            } //TextField prompt
                        else if focus == .orange
                            {
                            suggestionScroll(playerName: $orangePlayerName, otherPlayerName: whitePlayerName, playerNameDialog: $orangePlayerNameDialog, otherPlayerNameDialog: $whitePlayerNameDialog, nameList: nameList, color: Color("OrangeFeedback"), wide: wide, tall: tall)
                            } //show autosuggest scroll for orange player when orange player starts typing
                    }
                    .offset(x: -wide*0.06, y: -tall*0.25)
                } // if getting names
                
                if (orangePlayerNameDialog == true || whitePlayerNameDialog == true) {
                    Button((orangePlayerName.isEmpty || whitePlayerName.isEmpty) ? "Cancel" : "Save") {
                        if (orangePlayerName.isEmpty || whitePlayerName.isEmpty) {
                            archiveDialog = false //cancel
                        } else {
                            saveAndReset(save: true) // save
                        }
                    } //show cancel unless both names full - save otherwise
                    .buttonStyle(SavePill())
                    .background((orangePlayerName.isEmpty || whitePlayerName.isEmpty) ? Color.red : Color.blue)
                    .foregroundColor((orangePlayerName.isEmpty || whitePlayerName.isEmpty) ? Color("WhiteManicera") : .white)
                    .clipShape(Capsule())
                    .offset(x: -wide*0.0, y: -tall*0.25)
                } // if getting names
                
                if (orangePlayerNameDialog == false && whitePlayerNameDialog == false) { // if not getting names yet
                    Button("Discard") {//show discard button
                        showingConfirmation = true
                    }
                    .buttonStyle(RedPill())
                    .offset(x: wide * wideRightFactor, y: tall*0.055)
                    .alert("You Sure", isPresented: $showingConfirmation) {//double-check user wants to discard
                        Button("Yes, Discard", role: .destructive) {
                            saveAndReset(save: false)
                        }
                        Button("No. Cancel.", role: .cancel) { }
                    } message: { Text("Can't Undo") }
                } else { //if getting names
                    ZStack(alignment: .leading){
                        TextField("", text: $whitePlayerName)
                            .playerNameStyle(color: Color("WhiteScript"), width: wide * 0.3)
                            .focused($focus, equals: .white)
                            .onSubmit{
                                checkForNamesAndSave(playerName: whitePlayerName, otherPlayerName: orangePlayerName, playerNameDialog: $whitePlayerNameDialog, otherPlayerNameDialog: $orangePlayerNameDialog)
                            }
                            
                            
                        if (whitePlayerName.isEmpty) {
                            Text("Name")
                                .textFieldPromptStyle(color: Color("WhiteScript"))//TextField prompt
                        } else if focus == .white {
                            suggestionScroll(playerName: $whitePlayerName, otherPlayerName: orangePlayerName, playerNameDialog: $orangePlayerNameDialog, otherPlayerNameDialog: $whitePlayerNameDialog, nameList: nameList, color: Color("WhiteFeedback"), wide: wide, tall: tall)
                        } //show autosuggest scroll for white player when white player starts typing
                    }
                    .offset(x: wide*0.06, y: -tall*0.25)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.7))
            .onTapGesture{
                if (whitePlayerNameDialog == false &&
                    orangePlayerNameDialog == false) {archiveDialog = false}
            }
        }
    }
    
    func checkForNamesAndSave(playerName: String, otherPlayerName: String?, playerNameDialog: Binding<Bool>, otherPlayerNameDialog: Binding<Bool>) {
        if otherPlayerName!.isEmpty {
            playerNameDialog.wrappedValue = false
            otherPlayerNameDialog.wrappedValue = true
            switchFocus(focus: focus)
        }
        else {
            saveAndReset(save: true)
        }
    }
    
    func switchFocus(focus: FocusableField?) {
        switch focus{
        case .orange: self.focus = .white
        case .white: self.focus = .orange
        case .none: self.focus = .none
        }
    }
    
    func saveAndReset(save: Bool) {
        turns.newGame(currentBoxScore: currentBoxScore) // clear scoreboard
        newGameColorChange() //visual flash
        if save {
            archiveGame(orangePlayerName: orangePlayerName,
                        whitePlayerName: whitePlayerName,
                        firstColor: currentBoxScore.firstColor,
                        firstRuns: currentBoxScore.firstRuns,
                        secondRuns: currentBoxScore.secondRuns
            )
        } //save data to icloud
        currentBoxScore.clearBoxScore()
        archiveDialog = false //get rid of save screen
    }
    
    func suggestionScroll (playerName: Binding<String>, otherPlayerName: String?, playerNameDialog: Binding<Bool>, otherPlayerNameDialog: Binding<Bool>, nameList: [String?], color: Color, wide: CGFloat, tall: CGFloat) -> some View{
        
        ScrollView(.vertical)  {ForEach(nameList.filter{ ($0?.lowercased() ?? "").hasPrefix(playerName.wrappedValue.lowercased()) }, id: \.self)
                { name in
                    Button(name!) {playerName.wrappedValue = name!
                        checkForNamesAndSave(playerName: name!, otherPlayerName: otherPlayerName, playerNameDialog: playerNameDialog, otherPlayerNameDialog: otherPlayerNameDialog)
                    }
                    .font(.largeTitle)
                    .lineLimit(1)
                    .frame(width: wide*0.3, alignment: .leading)
                    .foregroundColor(color)
                }
            }
            .offset(y: tall * 0.60)
    }
    
    func newGameColorChange() { // visually resetting scoreboard
        // first toggle makes it black
        newGameFlash.toggle()
        
        // wait for 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // Back to normal with ease animation
            withAnimation(.easeIn){
                newGameFlash.toggle()
            }
        })
    }
    func fetchNames() -> [String?] {
        
        let descriptor = FetchDescriptor<PlayerStats>(sortBy: [SortDescriptor(\PlayerStats.name)])

        return try! modelContext.fetch(descriptor).map(\PlayerStats.name)
    }
    
    func archiveGame(
        orangePlayerName: String,
        whitePlayerName: String,
        firstColor: playerId?,
        firstRuns: [Int],
        secondRuns:[Int]) {
            
            // set the box score - date and names
            
            let boxScoreRecord = BoxScore(date: Date(), firstColor: firstColor!, firstPlayerName: firstColor == .orange ? orangePlayerName : whitePlayerName, firstRuns: firstRuns, secondPlayerName: firstColor == .white ? orangePlayerName : whitePlayerName, secondRuns: secondRuns)
            
            modelContext.insert(boxScoreRecord)
            
            // Deal with Stats now...
            
            let orangePlayerStats = statsRequestName(name: orangePlayerName) //fetch orange player stats
            
            let whitePlayerStats = statsRequestName(name: whitePlayerName) //fetch white player stats
            
            if (orangePlayerName == whitePlayerName && orangePlayerStats.isEmpty) {
                
                setNewPlayerStats(playerName: orangePlayerName, playerRuns: firstRuns, otherPlayerRuns: secondRuns, self: true)
                
            } //set new player playing against self
            else {
                
                if firstColor == .orange {
                    
                    setOrUpdatePlayerStats(playerStats: orangePlayerStats, playerName: orangePlayerName, playerRuns: firstRuns, otherPlayerRuns: secondRuns)
                    
                    //set or update white player stats (white player is second)
                    
                    setOrUpdatePlayerStats(playerStats: whitePlayerStats, playerName: whitePlayerName, playerRuns: secondRuns, otherPlayerRuns: firstRuns)
                    
                    
                } // if orange player is first
                
                else {
                    
                    setOrUpdatePlayerStats(playerStats: orangePlayerStats, playerName: orangePlayerName, playerRuns: secondRuns, otherPlayerRuns: firstRuns)
                    
                    //set or update white player stats (white player is first)
                    
                    setOrUpdatePlayerStats(playerStats: whitePlayerStats, playerName: whitePlayerName, playerRuns: firstRuns, otherPlayerRuns: secondRuns)
                    
                } // if orange player is second
                
                try? modelContext.save()
            }
        }
    
    func statsRequestName(name: String) -> [PlayerStats] {
        
        var statsRequest = FetchDescriptor<PlayerStats>(predicate:  #Predicate {player in
            player.name == name})
        
        statsRequest.fetchLimit = 1
        
        return try! modelContext.fetch(statsRequest)
    } //fetch individual player stats function
    
    func setNewPlayerStats(playerName: String, playerRuns: [Int], otherPlayerRuns: [Int], self: Bool){
        
        let innings = self ? playerRuns.count + otherPlayerRuns.count : playerRuns.count
        let wins =  ( (playerRuns.reduce(0, +) > otherPlayerRuns.reduce(0, +))  && !self ) ? 1 : 0 // player can't get win vs. self
        let losses = ( (playerRuns.reduce(0, +) < otherPlayerRuns.reduce(0, +))  && !self ) ? 1 : 0
        let points =  self ? playerRuns.reduce(0,+) + otherPlayerRuns.reduce(0,+) : playerRuns.reduce(0, +)
        let longRun = self ? max(playerRuns.max() ?? 0, otherPlayerRuns.max() ?? 0) : playerRuns.max() ?? 0
        let averages = [average(points, innings)]
        let games = self ? 2 : 1
        
        let newPlayer = PlayerStats(averages: averages, games: games, innings: innings, longRun: longRun,  losses: losses, name: playerName,  points: points, wins: wins)
        
        modelContext.insert(newPlayer)
    }
    
    func updatePlayerStats(playerStats: PlayerStats, playerRuns: [Int], otherPlayerRuns: [Int]) {
        playerStats.games += 1
        playerStats.innings += playerRuns.count
        playerStats.points += playerRuns.reduce(0, +)
        playerStats.longRun = playerStats.longRun < (playerRuns.max() ?? 0) ? playerRuns.max()! : playerStats.longRun
        playerStats.wins = playerRuns.reduce(0, +) > otherPlayerRuns.reduce(0, +) ? playerStats.wins + 1 : playerStats.wins + 0
        playerStats.losses = playerRuns.reduce(0, +) < otherPlayerRuns.reduce(0, +) ? playerStats.losses + 1 : playerStats.losses + 0
        if playerStats.innings > 0 {
            playerStats.averages.append(average(playerStats.points, playerStats.innings))
        }
    }
    
    func setOrUpdatePlayerStats(playerStats: [PlayerStats], playerName: String, playerRuns: [Int], otherPlayerRuns: [Int]) {
        if playerStats.isEmpty { //player not in database

           //let newPlayerStats = PlayerStats(context: modelContext) //create new instance

            setNewPlayerStats(playerName: playerName, playerRuns: playerRuns, otherPlayerRuns: otherPlayerRuns,  self: false)
            
        }
        
       else { // player in database
           
           updatePlayerStats(playerStats: playerStats[0], playerRuns: playerRuns, otherPlayerRuns: otherPlayerRuns)

       }
    }

}

struct GreenPill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .padding()
            .background(Color("FeltGreen"))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct RedPill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .padding()
            .background(Color("InningRed"))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SavePill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .padding()
            .frame(width: 200)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        }
}
