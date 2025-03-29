//
//  CurrentBoxScore.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

@Observable
final class CurrentBoxScore: ObservableObject, Identifiable {
    
    var id: UUID
    var firstColor: playerId?
    var firstRuns: [Int]
    var secondRuns: [Int]

    func clearBoxScore() {
        firstColor = nil
        firstRuns = []
        secondRuns = []
    }
    
    init(id: UUID = UUID(), firstColor: playerId? = nil, firstRuns: [Int] = [], secondRuns: [Int] = []) {
        self.id = id
        self.firstColor = firstColor
        self.firstRuns = firstRuns
        self.secondRuns = secondRuns
    }
    
}
