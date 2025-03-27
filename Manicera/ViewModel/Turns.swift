//
//  Turns.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

enum playerId: Codable {
    case orange, white
}

final class TurnsModel: ObservableObject {
    
    @EnvironmentObject var currentBoxScore: CurrentBoxScore
    @Published var run: Int = 0
    var player: playerId?
    var orangeScore: Int = 0
    var whiteScore: Int = 0
    var overallTurn: Int = 0
    var inning: Int = 0
    var orangeAvg: Double = 0.0
    var whiteAvg: Double = 0.0
    var firstPlayer: playerId?
                    
    func carambola() {
        run += 1
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
    }

    func notCarambola(data: CurrentBoxScore) {
        if run > 0 {
            run -= 1
            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
            impactHeavy.impactOccurred()
            }
        else {
            turnBack(data: data)
        }
    }
    
    func turnOver(currentBoxScore: CurrentBoxScore) {
        
        if overallTurn > 0 {
            if player == firstPlayer {
                currentBoxScore.secondRuns.append(run)
                }
            else {
                currentBoxScore.firstRuns.append(run)
                }
        } //close previous player inning
        run = 0
        overallTurn += 1
        inning = Int(ceil(Double(overallTurn) / 2))
    }
    
    func turnBack(data: CurrentBoxScore) {
        
        if overallTurn > 1 {
            if player == firstPlayer {
                run = data.secondRuns.last! //go back to previous run
                data.secondRuns.removeLast() //remove it from record
                }
            else {
                run = data.firstRuns.last! //go back to previous run
                data.firstRuns.removeLast() //remove it from record
                }
            player = (player == .orange) ? .white : .orange //set previous player
            orangeScore -= (player == .orange) ? run : 0 //set previous score for orange
            whiteScore -= (player == .white) ? run : 0 //set previous score for white
            overallTurn -= 1
            inning = Int(ceil(Double(overallTurn) / 2))
            orangeAvg = average(orangeScore,inning)
            whiteAvg = average(whiteScore, inning)
        }
        else {
            clearScoreBoard()
            data.clearBoxScore()
            orangeAvg = average(orangeScore, inning)
            whiteAvg = average(whiteScore, inning)
        }
    }
    
    func newGame(currentBoxScore: CurrentBoxScore) {
        if run != 0 {
            player = (player == .orange) ? .white : .orange //set correct player to close up last inning
            turnOver(currentBoxScore: currentBoxScore) //close up last inning
        }
        
        clearScoreBoard()
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
    
    }
    
    func clearScoreBoard(){
        player = nil
        overallTurn = 0
        inning = 0
        run = 0
        orangeScore = 0
        whiteScore = 0
        orangeAvg = 0.0
        whiteAvg = 0.0
        firstPlayer = nil
    }
    
}
