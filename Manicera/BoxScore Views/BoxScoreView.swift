//
//  BoxScoreView.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI
import SwiftData

func avg(numerator: Int, denominator: Int) -> String {
    return denominator == 0 ? "0.000" : String(format: "%.3f", Double(numerator) / Double(denominator))
}
                        
private var rows: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

private func color1(first: playerId?) -> Color {
    return (first == .orange) ? Color("OrangeFeedback") : Color("WhiteFeedback")
}

private func color2(first: playerId?) -> Color {
    return (first == .orange) ? Color("WhiteFeedback") : Color("OrangeFeedback")
}

let star = Image(systemName: "star")

struct boxScoreView: View {
    @Query(sort: \BoxScore.date, order: .reverse) var boxScores: [BoxScore]
    @Environment(CurrentBoxScore.self) var currentBoxScore
    @Environment(\.modelContext) var modelContext
    @State var showArmaggedonWarning: Bool = false
    @AppStorage("boxScoreOnBoarding") var boxScoreOnBoarding = true
    
    var body: some View {
        ScrollView(.vertical) {
            Group {
                Text("Current game")
                    .font(Font.largeTitle.weight(.regular))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment:  .leading)
                    .padding()
                
                Divider().background(.white)
                IndividualBoxScoreView(game: currentBoxScore)
            }
            .showView(currentBoxScore.firstRuns.count > 0)
            
            Text("Past games")
                .font(Font.largeTitle.weight(.regular))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment:  .leading)
                .padding()
            
            Group {
                ForEach(boxScores, id: \.self)
                {oldGame in
                    IndividualBoxScoreView(
                        game: savedToBsD(oldScoreBox: oldGame),
                        firstNamePlayer: oldGame.firstPlayerName, secondNamePlayer: oldGame.secondPlayerName,
                        date: oldGame.date
                    )
                }
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        showArmaggedonWarning.toggle()
                    } label: {
                        Label("Clear All Records", systemImage: "trash")
                    }
                    .padding(.bottom, 100)
                    .alert("This will eliminate EVERY recorded game and statistics for ALL players. Are you sure you want to do this?", isPresented: $showArmaggedonWarning) {
                        Button("yes, destroy all data", role: .destructive) {
                                do {
                                    try modelContext.delete(model: PlayerStats.self)
                                    try modelContext.delete(model: BoxScore.self)
                                } catch {
                                    print("failed to clear data")
                                }
                            }
                        Button("No. Don't delete anything.", role: .cancel) {}
                    } message: {Text("Can't Undo")}
                } // Delete ALL records and stats
            }
            .showView(boxScores.isEmpty == false)
        }
        .background(.black)
        .overlay(
            BoxScoreOnBoarding()
            .showView(boxScoreOnBoarding)
            )
    }
}

private func savedToBsD(oldScoreBox: BoxScore) -> CurrentBoxScore { //transform saved boxscores into current ones for displaying
    let boxScore = CurrentBoxScore(
        id: UUID(),
        firstColor: oldScoreBox.firstColor,
        firstRuns: oldScoreBox.firstRuns,
        secondRuns: oldScoreBox.secondRuns
    )
    
    return boxScore
}

private func headerView(game: CurrentBoxScore,  firstPlayerName: String?, secondPlayerName: String?, date: Date?) ->  some View {
    
    LazyHGrid(rows: rows, spacing:0) {
        if date != nil {
            Group{
                Text(" ")
                    .padding(10)
                
                HStack(spacing:0){
                    Text(star)
                        .font(.caption2)
                        .showView((game.firstRuns.reduce(0, +) > game.secondRuns.reduce(0, +)) && (firstPlayerName != secondPlayerName))
                    Text(firstPlayerName!)
                } //show first player name (with star if won)
                .foregroundStyle(color1(first: game.firstColor))
                
                HStack(spacing:0){
                    Text(star)
                        .font(.caption2)
                        .showView((game.firstRuns.reduce(0, +) < game.secondRuns.reduce(0, +)) && (firstPlayerName != secondPlayerName))
                    Text(secondPlayerName!)
                } //show second player name (with star if won)
                .foregroundStyle(color2(first: game.firstColor))
            }
            .frame(width:120)
            .background(.black)
        } //if old game
        Group{
            Text("Total")
                .frame(width:60)
            Text("\(game.firstRuns.reduce(0, +))")
                .frame(width:60)
                .foregroundStyle(color1(first: game.firstColor))
            Text("\(game.secondRuns.reduce(0, +))")
                .frame(width:60)
                .foregroundStyle(color2(first: game.firstColor))
        }
        .background(.black)
        .foregroundStyle(.white)

        Group{
            Text("Average")
                .frame(width:70)
            Text(avg(numerator: game.firstRuns.reduce(0, +), denominator: game.firstRuns.count))
                .frame(width:70)
                .foregroundStyle(color1(first: game.firstColor))
            Text(avg(numerator: game.secondRuns.reduce(0, +), denominator: game.secondRuns.count))
                .frame(width:70)
                .foregroundStyle(color2(first: game.firstColor))
        }
        .padding(5)
        .background(.black)
        .foregroundStyle(.white)
        
    }
}

struct IndividualBoxScoreView: View {
    @State var game: CurrentBoxScore
    @State var firstNamePlayer: String?
    @State var secondNamePlayer: String?
    @State var date: Date?
    
    var body: some View{
      
    Group{
        if date != nil {
            HStack{
                Text(date!, style: .date).fontWeight(.light)
                Text(date!, style: .time).fontWeight(.light)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment:  .leading)
            .padding()
        }
        
        ScrollView(.horizontal) {
                LazyHGrid(rows: rows, spacing:0, pinnedViews: [.sectionHeaders]) {
                    Section(header: headerView(game: game, firstPlayerName: firstNamePlayer, secondPlayerName: secondNamePlayer, date: date)) {
                      ForEach(game.firstRuns.indices, id: \.self) { index in
                          Group{
                              Text("\(index + 1)")
                              Text("\(game.firstRuns[index])")
                                  .boldHighRun(run: game.firstRuns[index], max: game.firstRuns.max())
                                  .foregroundStyle(color1(first: game.firstColor))
                              Text(index > game.secondRuns.count - 1 ? "–" : "\(game.secondRuns[index])")
                                  .foregroundStyle(color2(first: game.firstColor))
                                  .boldHighRun(run: index > game.secondRuns.count - 1 ? 0: game.secondRuns[index], max: game.secondRuns.max())
                              
                          }
                          .showView(game.firstRuns.count > 0) //needed because ForEach views are not destroyed, so when turning back to beggining of game will get out of Range error
                    }
                }
            }
            .foregroundStyle(.white)
            .frame(height:90)
        }
        .padding(.bottom, 70)

        Divider()
            .background(.white)
        }
        .background(.black)
    }
}

#Preview {
    boxScoreView(boxScoreOnBoarding: true)
        .modelContainer(boxScorePreviewContainer)
        .environmentObject(CurrentBoxScore.example)
}
