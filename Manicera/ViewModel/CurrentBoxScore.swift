//
//  CurrentBoxScore.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

@Observable
final class CurrentBoxScore: ObservableObject, Identifiable {
    
    var id: UUID = UUID()
    var firstColor: playerId? = nil
    var firstRuns: [Int] = []
    var secondRuns: [Int] = []

    func clearBoxScore() {
        firstColor = nil
        firstRuns = []
        secondRuns = []
    }
    
}
