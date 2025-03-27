//
//  Data.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import Foundation
import SwiftData

@Model
final class BoxScore {
    var id: UUID = UUID()
    var date: Date = Date.now
    var firstColor: playerId?
    var firstPlayerName: String?
    var firstRuns: [Int] = []
    var secondPlayerName: String?
    var secondRuns: [Int] = []
    
    init(date: Date, firstColor: playerId, firstPlayerName: String, firstRuns: [Int], secondPlayerName: String, secondRuns: [Int]) {
        self.date = date
        self.firstColor = firstColor
        self.firstPlayerName = firstPlayerName
        self.firstRuns = firstRuns
        self.secondPlayerName = secondPlayerName
        self.secondRuns = secondRuns
    }
    
}

@Model
final class PlayerStats {
    var id: UUID = UUID()
    var averages: [Double] = []
    var lastAverage: Double = 0.0 //needed rather than averages.last because computed properties don't work with sorting
    var games: Int = 0
    var innings: Int = 0
    var longRun: Int = 0
    var losses: Int = 0
    var name: String?
    var points: Int = 0
    var wins: Int = 0
    
    init(averages: [Double], lastAverage: Double, games: Int, innings: Int, longRun: Int, losses: Int, name: String, points: Int, wins: Int) {
        self.averages = averages
        self.lastAverage = lastAverage
        self.games = games
        self.innings = innings
        self.longRun = longRun
        self.losses = losses
        self.name = name
        self.points = points
        self.wins = wins
    }
}

func average(_ score: Int, _ innings: Int) -> Double {
    if innings == 0 {
        return 0.0
    } else {
        return Double(score) / Double(innings)
    }
}
