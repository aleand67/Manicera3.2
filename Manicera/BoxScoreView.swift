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

struct boxScoreView: View {
    @Query(sort: \BoxScore.date, order: .reverse) var boxScores: [BoxScore]
    @Environment(CurrentBoxScore.self) var currentBoxScore
    @Environment(\.modelContext) var modelContext
    @State var showArmaggedonWarning: Bool = false
    var body: some View {
        ScrollView(.vertical) {
            if currentBoxScore.firstRuns.count > 0 {
                Text("Current game")
                    .font(Font.largeTitle.weight(.regular))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment:  .leading)
                    .padding()
                
                Divider().background(Color.white)
                IndividualBoxScoreView(game: currentBoxScore)
            }
            
            Text("Past games")
                .font(Font.largeTitle.weight(.regular))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment:  .leading)
                .padding()
            
            if boxScores.isEmpty == false { //if there is at least one game
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
        }
        .background(Color.black)
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
                
                if ( (game.firstRuns.reduce(0, +) > game.secondRuns.reduce(0, +)) && (firstPlayerName != secondPlayerName) ) {
                    (Text(Image(systemName: "star.fill")) + Text(firstPlayerName!))
                        .foregroundColor(color1(first: game.firstColor))
                }
                else {
                    Text(firstPlayerName!)
                        .foregroundColor(color1(first: game.firstColor))
                    }
                    
                
                if ( (game.firstRuns.reduce(0, +) < game.secondRuns.reduce(0, +)) && (firstPlayerName != secondPlayerName) )  {
                    (Text(Image(systemName: "star.fill")) + Text(secondPlayerName!))
                        .foregroundColor(color2(first: game.firstColor))
                }
                else {
                    Text(secondPlayerName!)

                        .fontWeight(.light)

                        .foregroundColor(color2(first: game.firstColor))
                    }
            }
            .frame(width:120)
            .background(Color.black)
        } //if old game
        Group{
            Text("Total")
                .frame(width:60)
            Text("\(game.firstRuns.reduce(0, +))")
                .frame(width:60)
                .foregroundColor(color1(first: game.firstColor))
            Text("\(game.secondRuns.reduce(0, +))")
                .frame(width:60)
                .foregroundColor(color2(first: game.firstColor))
        }
        .background(Color.black)
        .foregroundColor(Color.white)

        Group{
            Text("Average")
                .frame(width:70)
            Text(avg(numerator: game.firstRuns.reduce(0, +), denominator: game.firstRuns.count))
                .frame(width:70)
                .foregroundColor(color1(first: game.firstColor))
            Text(avg(numerator: game.secondRuns.reduce(0, +), denominator: game.secondRuns.count))
                .frame(width:70)
                .foregroundColor(color2(first: game.firstColor))
        }
        .padding(5)
        .background(Color.black)
        .foregroundColor(Color.white)
        
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
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, alignment:  .leading)
            .padding()
        }
        
        ScrollView(.horizontal) {
                LazyHGrid(rows: rows, spacing:0, pinnedViews: [.sectionHeaders]) {
                    Section(header: headerView(game: game, firstPlayerName: firstNamePlayer, secondPlayerName: secondNamePlayer, date: date)) {
                      ForEach(game.firstRuns.indices, id: \.self) { index in
                          if game.firstRuns.count > 0 { //needed because ForEach views are not destroyed, so when turning back to beggining of game will get out of Range error
                              Group{
                                  Text("\(index + 1)")
                                      .frame(width:35)
                                  Text("\(game.firstRuns[index])")
                                      .boldHighRun(run: game.firstRuns[index], max: game.firstRuns.max())
                                      .foregroundColor(color1(first: game.firstColor))
                                  if index > game.secondRuns.count - 1 {
                                      Text("-") //Show empty inning if second player didn't play last inning
                                          .foregroundColor(color2(first: game.firstColor))
                                          .frame(width:35)
                                  } else {
                                      Text("\(game.secondRuns[index])")
                                          .boldHighRun(run: game.secondRuns[index], max: game.secondRuns.max())
                                          .foregroundColor(color2(first: game.firstColor))
                                  }
                              }
                          }
                    }
                }
            }
            .foregroundColor(Color.white)
            .frame(height:90)
        }
        .padding(.bottom, 70)

        Divider()
            .background(Color.white)
        }
        .background(Color.black)
    }
}

#Preview {
    boxScoreView()
        .modelContainer(boxScorePreviewContainer)
        .environmentObject(CurrentBoxScore.example)
}
