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
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @EnvironmentObject var turns: TurnsModel
    @EnvironmentObject var currentBoxScore: CurrentBoxScore
    
    @State private var showingConfirmation = false
    @State private var textFieldsShown = false
    @State private var orangePlayerName: String = ""
    @State private var whitePlayerName: String = ""
    @Binding var newGameFlash: Bool
    @Binding var archiveDialog: Bool
    @State private var offset: CGFloat = 1200
    
    @AppStorage("tabsAvailable") var tabsAvailable = false
    
    var body: some View {
        
        let nameList = fetchNames()
        
        GeometryReader {geometry in
            HStack{
                let tall = geometry.size.height
                let wide = geometry.size.width
                
                let wideLeftFactor = verticalSizeClass == .compact ? 0.105 : 0.157 //fine tuning placement Keep Game button
                
                let wideRightFactor = verticalSizeClass == .compact ? 0.1275 : 0.165 //fine tuning placement Discard Game button
                  
                Spacer()
                
                Button("Keep Game") {
                    textFieldsShown = true
                    focus = .orange
                    }// if tapped, show textFields, focus on orange one
                    .buttonStyle(AnimatePill(color: Color("FeltGreen")))
                    .offset(x: -wide*wideLeftFactor, y: tall*0.055)
                    .showView(!textFieldsShown)//Show if not getting games yet
                
                ZStack (alignment: .leading){
                    TextField("", text: $orangePlayerName)
                        .playerNameStyle(color: Color("OrangeManicera"), width: wide * 0.3)
                        .focused($focus, equals: .orange)
                        .onSubmit {
                            checkForNamesAndSave(playerName: orangePlayerName, otherPlayerName: whitePlayerName)
                        }
                    
                    Text("Name")
                        .textFieldPromptStyle(color: Color("OrangeManicera"))
                        .showView(orangePlayerName.isEmpty)
                   
                    suggestionScroll(playerName: $orangePlayerName, otherPlayerName: whitePlayerName, textFieldsShown: $textFieldsShown, nameList: nameList, color: Color("OrangeFeedback"), wide: wide, tall: tall)
                        .showView(!orangePlayerName.isEmpty && focus == .orange) //show autosuggest scroll for orange player when orange player starts typing
                }
                .offset(y: -tall*0.25)
                .showView(textFieldsShown)//show left TextField when getting names
                
                Spacer()
                    .showView(textFieldsShown && verticalSizeClass != .compact)
                
                Button("Cancel") {
                    orangePlayerName = ""
                    whitePlayerName = ""
                    textFieldsShown = false
                }
                .buttonStyle(AnimatePill(color: .red))
                .offset(y: -tall*0.25)
                .showView(textFieldsShown && (orangePlayerName.isEmpty || whitePlayerName.isEmpty))// if getting names but not both full
                
                Button("Save") {
                        saveAndOrReset(save: true) // save
                    }
                .buttonStyle(AnimatePill(color: .blue))
                .offset(y: -tall*0.25)
                .showView(textFieldsShown && !orangePlayerName.isEmpty && !whitePlayerName.isEmpty)// if getting names and both full
                    
               
                
                Spacer()
                    .showView(textFieldsShown && verticalSizeClass != .compact)
                
                ZStack(alignment: .leading){
                    TextField("", text: $whitePlayerName)
                        .playerNameStyle(color: Color("WhiteScript"), width: wide * 0.3)
                        .focused($focus, equals: .white)
                        .onSubmit{
                            checkForNamesAndSave(playerName: whitePlayerName, otherPlayerName: orangePlayerName)
                        }
                        
                    
                    Text("Name")
                        .textFieldPromptStyle(color: Color("WhiteScript"))
                        .showView(whitePlayerName.isEmpty)//TextField prompt
                    
                    suggestionScroll(playerName: $whitePlayerName, otherPlayerName: orangePlayerName, textFieldsShown: $textFieldsShown, nameList: nameList, color: Color("WhiteFeedback"), wide: wide, tall: tall)
                        .showView(!whitePlayerName.isEmpty && focus == .white) //show autosuggest scroll for white player when white player starts typing
                }
                .offset(y: -tall*0.25)
                .showView(textFieldsShown)// show right TextField
                
                Button("Discard") {//show discard button
                        showingConfirmation = true
                    }
                    .buttonStyle(AnimatePill(color: Color("InningRed")))
                    .offset(x: wide * wideRightFactor, y: tall*0.055)
                    .showView(!textFieldsShown)
                    .alert("You Sure", isPresented: $showingConfirmation) {//double-check user wants to discard
                        Button("Yes, Discard", role: .destructive) {
                            saveAndOrReset(save: false)
                            close()
                        }
                        Button("No. Cancel.", role: .cancel) { }
                    } message: { Text("Can't Undo") }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .onTapGesture{
                if !textFieldsShown {
                    close()
                } //cancel everything and go back to game if tap anywhere else but buttons
            }
            .offset(y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
    }
    
    func checkForNamesAndSave(playerName: String, otherPlayerName: String?) {
        if otherPlayerName!.isEmpty {
            switchFocus(focus: focus)
        } else if playerName.isEmpty {
            focus = focus.self
        } else {
            saveAndOrReset(save: true)
        }
    }
    
    func switchFocus(focus: FocusableField?) {
        switch focus{
        case .orange: self.focus = .white
        case .white: self.focus = .orange
        case .none: self.focus = .none
        }
    }
    
    func saveAndOrReset(save: Bool) {
        turns.newGame(currentBoxScore: currentBoxScore) // clear scoreboard
        newGameColorChange() //visual flash
        if save {
            archiveGame(orangePlayerName: orangePlayerName,
                        whitePlayerName: whitePlayerName,
                        firstColor: currentBoxScore.firstColor,
                        firstRuns: currentBoxScore.firstRuns,
                        secondRuns: currentBoxScore.secondRuns
            )
            
            tabsAvailable = true //turn tabs on
        } //save data to icloud
        close() //get rid of save screen
        currentBoxScore.clearBoxScore()
    }
    
    func suggestionScroll (playerName: Binding<String>, otherPlayerName: String?, textFieldsShown: Binding<Bool>, nameList: [String?], color: Color, wide: CGFloat, tall: CGFloat) -> some View{
        
        ScrollView(.vertical)  {ForEach(nameList.filter{ ($0?.lowercased() ?? "").hasPrefix(playerName.wrappedValue.lowercased()) }, id: \.self)
                { name in
                    Button(name!) {playerName.wrappedValue = name!
                        checkForNamesAndSave(playerName: name!, otherPlayerName: otherPlayerName)
                    }
                    .font(.largeTitle)
                    .lineLimit(1)
                    .frame(width: wide*0.3, alignment: .leading)
                    .foregroundStyle(verticalSizeClass == .compact ? .black : color)
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
            let practiceGame: Bool = orangePlayerName == whitePlayerName //if playing against self -> practice
            let orangePlayerStats = statsRequestName(name: orangePlayerName) //fetch orange player stats
            
            let whitePlayerStats = statsRequestName(name: whitePlayerName) //fetch white player stats
            
            if (practiceGame && orangePlayerStats.isEmpty) {
                
                setNewPlayerStats(playerName: orangePlayerName, playerRuns: firstRuns, otherPlayerRuns: secondRuns, practiceGame: practiceGame)
                
            } //set new player playing against self
            else {
                
                if firstColor == .orange {
                    
                    setOrUpdatePlayerStats(playerStats: orangePlayerStats, playerName: orangePlayerName, playerRuns: firstRuns, otherPlayerRuns: secondRuns, practiceGame: practiceGame)
                    
                    //set or update white player stats (white player is second)
                    
                    setOrUpdatePlayerStats(playerStats: whitePlayerStats, playerName: whitePlayerName, playerRuns: secondRuns, otherPlayerRuns: firstRuns, practiceGame: practiceGame)
                    
                    
                } // if orange player is first
                
                else {
                    
                    setOrUpdatePlayerStats(playerStats: orangePlayerStats, playerName: orangePlayerName, playerRuns: secondRuns, otherPlayerRuns: firstRuns, practiceGame: practiceGame)
                    
                    //set or update white player stats (white player is first)
                    
                    setOrUpdatePlayerStats(playerStats: whitePlayerStats, playerName: whitePlayerName, playerRuns: firstRuns, otherPlayerRuns: secondRuns, practiceGame: practiceGame)
                    
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
    
    func setNewPlayerStats(playerName: String, playerRuns: [Int], otherPlayerRuns: [Int], practiceGame: Bool){
        let innings = practiceGame ? playerRuns.count + otherPlayerRuns.count : playerRuns.count
        let wins =  ( (playerRuns.reduce(0, +) > otherPlayerRuns.reduce(0, +))  && !practiceGame ) ? 1 : 0 // player can't get win vs. self
        let losses = ( (playerRuns.reduce(0, +) < otherPlayerRuns.reduce(0, +))  && !practiceGame ) ? 1 : 0
        let points =  practiceGame ? playerRuns.reduce(0,+) + otherPlayerRuns.reduce(0,+) : playerRuns.reduce(0, +)
        let longRun = practiceGame ? max(playerRuns.max() ?? 0, otherPlayerRuns.max() ?? 0) : playerRuns.max() ?? 0
        let lastAverage = average(points, innings)
        let averages = [lastAverage]
        let games = practiceGame ? 2 : 1
        
        let newPlayer = PlayerStats(averages: averages, lastAverage: lastAverage, games: games, innings: innings, longRun: longRun,  losses: losses, name: playerName,  points: points, wins: wins)
        
        modelContext.insert(newPlayer)
    }
    
    func updatePlayerStats(playerStats: PlayerStats, playerRuns: [Int], otherPlayerRuns: [Int], practiceGame: Bool) {
        playerStats.games += 1
        playerStats.innings += playerRuns.count
        playerStats.points += playerRuns.reduce(0, +)
        playerStats.longRun = playerStats.longRun < (playerRuns.max() ?? 0) ? playerRuns.max()! : playerStats.longRun
        playerStats.wins = ( (playerRuns.reduce(0, +) > otherPlayerRuns.reduce(0, +))  && !practiceGame ) ? playerStats.wins + 1 : playerStats.wins + 0 // can't get a win against self
        playerStats.losses = ( (playerRuns.reduce(0, +) < otherPlayerRuns.reduce(0, +))  && !practiceGame ) ? playerStats.losses + 1 : playerStats.losses + 0// can't lose against self
        if playerStats.innings > 0 {
            playerStats.lastAverage = average(playerStats.points, playerStats.innings)
            playerStats.averages.append(playerStats.lastAverage)
        }
    }
    
    func setOrUpdatePlayerStats(playerStats: [PlayerStats], playerName: String, playerRuns: [Int], otherPlayerRuns: [Int], practiceGame: Bool) {
        if playerStats.isEmpty {
            setNewPlayerStats(playerName: playerName, playerRuns: playerRuns, otherPlayerRuns: otherPlayerRuns,  practiceGame: practiceGame)
        } // player not in database
        
       else {
           updatePlayerStats(playerStats: playerStats[0], playerRuns: playerRuns, otherPlayerRuns: otherPlayerRuns, practiceGame: practiceGame)
       } // player in database
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 1200
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            orangePlayerName = ""
            whitePlayerName = ""
            textFieldsShown = false
            focus = .none
            archiveDialog = false
        } //clean up everything and dismiss archive view
    }
}

#Preview {
    @Previewable @State var archiveDialog: Bool = true
    @Previewable @State var newGameFlash: Bool = false
    ArchiveDialogView(newGameFlash: $newGameFlash, archiveDialog: $archiveDialog)
        .modelContainer(statsPreviewContainer)
}
