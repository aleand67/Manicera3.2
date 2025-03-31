//
//  OrangeButton.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

struct OrangeButton: View {
    
    @EnvironmentObject var turns: TurnsModel
    @EnvironmentObject var currentBoxScore: CurrentBoxScore
    
    @State var bigButtonSize: CGFloat
    
    @AppStorage("wasOrangeButtonUsed") var wasOrangeButtonUsed: Bool = false
    
    var body: some View {
        
        Button(action: {
            
            turns.player = .orange //orange turn
            turns.whiteScore = turns.whiteScore + turns.run //finalize white turn
            
            if turns.overallTurn == 0 {
                turns.firstPlayer = .orange
                currentBoxScore.firstColor = .orange
            } //first player is orange
            else {
                turns.whiteAvg = Double(turns.whiteScore) / Double(turns.inning)
            } //finalize white average
            
            turns.turnOver(currentBoxScore: currentBoxScore) //reset run, increase inning
            
            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
            impactHeavy.impactOccurred()
            
            wasOrangeButtonUsed = true
        })
        {VStack{
            (wasOrangeButtonUsed ? Text("") : Text(Image(systemName: "hand.tap")))
            Text(wasOrangeButtonUsed ?  "" : "Orange Turn")}
                .font(.system(size: bigButtonSize*0.02))
                .foregroundColor(Color("OrangeScript"))
                .frame(width: bigButtonSize*0.22,
                       height: bigButtonSize*0.20)
                .background(
                    Circle()
                        .strokeBorder(Color("OrangeScript"), lineWidth: 3)
                        .background(Circle().fill( turns.player == .orange ? Color("OrangeScript") : Color("OrangeManicera")))
                        .frame(width: bigButtonSize*0.27,
                               height: bigButtonSize*0.27)
                )
            
        }
        .disabled(turns.player == .orange)
    }
}
