//
//  PreviewSampleData.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/27/25.
//

import Foundation
import SwiftData

let statsPreviewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: PlayerStats.self)
        
        Task { @MainActor in
            let context = container.mainContext
            
            var counter = 1
            while counter < 100 {
                context.insert(PlayerStats(averages: Array(1...Int.random(in: 21...30)).map {_ in  Double.random(in:0.750...1.230)},
                            lastAverage: Double.random(in:0.750...1.230),
                            games: Int.random(in:21...30),
                            innings: Int.random(in:250...500),
                            longRun: Int.random(in:0...7),
                            losses: Int.random(in:10...17),
                            name: "Player \(counter)",
                            points: Int.random(in:140...350),
                            wins: Int.random(in:10...17)))
                counter += 1
                }
            context.insert(PlayerStats(averages: Array(1...Int.random(in: 21...30)).map {_ in  Double.random(in:0.750...1.230)}, lastAverage: 0.852, games: 43, innings: 1050, longRun: 18, losses: 21, name: "RobertinoSF", points: 952, wins: 22))
        }
        return container
    } catch {
        fatalError("Failed to create container with error: \(error.localizedDescription)")
    }
}()

let boxScorePreviewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: BoxScore.self)
        
        Task { @MainActor in
            let context = container.mainContext
            
            var counter = 1
            while counter < 100 {
                let firstRunCount: Int = Int.random(in: 21...30)
                let date: Date = Date(timeIntervalSince1970: TimeInterval(Int32.random(in: 0...Int32.max)))
                context.insert(BoxScore(date: date, firstColor: counter % 2 == 0 ? .orange : .white, firstPlayerName: "Player \(counter)", firstRuns: Array(1...firstRunCount).map {_ in  Int.random(in:0...6)}, secondPlayerName: "Player 2.\(counter)", secondRuns: Array(1...firstRunCount - Int.random(in: 0...1)).map {_ in  Int.random(in:0...6)}))
                    
                counter += 1
                }
            
        }
        return container
    } catch {
        fatalError("Failed to create container with error: \(error.localizedDescription)")
    }
}()

