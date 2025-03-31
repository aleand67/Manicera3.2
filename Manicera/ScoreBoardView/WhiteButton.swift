//
//  WhiteButton.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

struct WhiteButton: View {
    
    @EnvironmentObject var turns: TurnsModel
    @EnvironmentObject var currentBoxScore: CurrentBoxScore
    
    @State var bigButtonSize: CGFloat
    
    @AppStorage("wasWhiteButtonUsed") var wasWhiteButtonUsed: Bool = false
    
    var body: some View {
        
        Button(action: {
            turns.player = .white //set white turn
            turns.orangeScore = turns.orangeScore + turns.run //finalize orange turn
            if turns.overallTurn == 0 {
                turns.firstPlayer = .white
                currentBoxScore.firstColor = .white
            }//first player is white
            else {
                turns.orangeAvg = Double(turns.orangeScore) / Double(turns.inning)
            } //finalize orange average
            
            turns.turnOver(currentBoxScore: currentBoxScore) //reset run, increase inning
            
            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
            impactHeavy.impactOccurred()
            
            wasWhiteButtonUsed = true
        })
        {
            VStack{
                (wasWhiteButtonUsed ? Text("") : Text(Image(systemName: "hand.tap")))
                Text(wasWhiteButtonUsed ? "" : "White Turn")}
                .font(.system(size: bigButtonSize*0.02))
                .foregroundColor(Color("WhiteScript"))
                .frame(width: bigButtonSize*0.22,
                       height: bigButtonSize*0.20)
                .background(
                    Circle()
                        .strokeBorder(Color("WhiteScript"), lineWidth: 3)
                        .background(Circle().fill( turns.player == .white ? Color("WhiteScript") : Color("WhiteManicera")))
                        .frame(width: bigButtonSize*0.27,
                               height: bigButtonSize*0.27)
                )
        }
        .disabled(turns.player == .white)
    }
}
