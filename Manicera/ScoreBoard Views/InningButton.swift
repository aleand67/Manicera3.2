//
//  InningButton.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

struct InningButton: View {
    
    @EnvironmentObject var turns: TurnsModel
    @State var bigButtonSize: CGFloat
    @GestureState private var inningIsPressed = false
    @Binding var newGameFlash: Bool
    @Binding var archiveDialog: Bool
    @AppStorage("wasInningButtonUsed") var wasInningButtonUsed = false
    
    var inningButtonSize: CGFloat {
        return (inningIsPressed && archiveDialog == false) ? bigButtonSize * 0.12 : bigButtonSize * 0.10
    }
    
    var body: some View {
        ZStack{
            Circle()
                .fill(Color("InningRed"))
                .frame(width: inningButtonSize, height: inningButtonSize)
            
            Text("\(turns.inning)")
                .font(.system(size: inningButtonSize*0.50))
                .foregroundStyle(newGameFlash ? Color("Undo") : Color("WhiteManicera"))
        }
        .gesture(LongPressGesture(minimumDuration: 1, maximumDistance: 10)
            .onEnded({_ in
                
                if turns.player != nil {
                archiveDialog = true
                }
                
                wasInningButtonUsed = true
                })
        .updating($inningIsPressed) { value, state, _ in
            state = value
            }
        )
    }
}
