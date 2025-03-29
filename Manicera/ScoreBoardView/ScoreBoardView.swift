//
//  ScoreBoardView.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI
import SwiftData

struct scoreboardView: View {
    
    @EnvironmentObject var turns: TurnsModel
    @EnvironmentObject var currentBoxScore: CurrentBoxScore
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass //needed to set size of draggable rectangle on top to change tabbed views depending on screen size
    
    @State private var wide: CGFloat?
    @GestureState private var orangeIsPressed = false
    @GestureState private var whiteIsPressed = false
    @State private var buttonFlash: Bool = false
    @State var newGameFlash: Bool = false
    @State private var archiveDialog: Bool = false
    
    var orangeFeedbackColor: Color {
        if orangeIsPressed == true && turns.player == .orange {return Color("OrangeFeedback")} else {return Color("OrangeManicera")}
    }
    
    var whiteFeedbackColor: Color {
        if whiteIsPressed == true && turns.player == .white {return Color("WhiteFeedback")} else {return Color("WhiteManicera")}
    }
    
    func colorChange() { //flash black when undoing carambola
        // first toggle makes it black
        buttonFlash.toggle()
        
        // wait a bit
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750), execute: {
            // Back to normal with ease animation
            withAnimation(.easeIn){
                buttonFlash.toggle()
            }
        })
    }
    
    var body: some View {
        
        let swipeFactor = horizontalSizeClass == .compact ? 0.20 : 0.16
        
        GeometryReader {geometry in
            ZStack{
                let tall = geometry.size.height
                let wide = geometry.size.width
                
                HStack(spacing: 1) {
                    ZStack{
                        VStack {
                            
                            scoreView(player: .orange, score: turns.orangeScore, run: turns.run, tall: tall, wide: wide, color: Color("OrangeScript"))//show orange score
                            
                            Spacer()
                            
                            OrangeButton(bigButtonSize: wide)
                                
                            Spacer()
                            
                            avgView(avg: turns.orangeAvg, tall: tall, wide: wide, color: Color("OrangeScript")) //show orange average
                       } //orange side
                        if UserDefaults.standard.wasOScoreButtonUsed == false && turns.player == .orange {
                            Text("Orange-Point \(Image(systemName:"hand.tap")) \(Image(systemName:"hand.tap"))")
                            .foregroundColor(Color.white)
                            .font(.system(size: tall*0.03))
                            .multilineTextAlignment(.center)
                            .frame(width: wide*0.22, height: tall*0.20, alignment: .bottom) }//show score carambola instructions the first time
                        
                        Spacer()
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background(orangeIsPressed ? orangeFeedbackColor : Color("OrangeManicera"))
                    .gesture(TapGesture()
                        .onEnded{
                            if turns.player == .orange {
                                UserDefaults.standard.wasOScoreButtonUsed = true
                                    turns.carambola()
                            }
                        }//score orange carambola
                        .simultaneously(with: LongPressGesture(minimumDuration: 1, maximumDistance: 10)
                            .updating($orangeIsPressed) { value, state, _ in state = value
                                }//highlight long press
                            .onEnded({_ in
                                    if turns.player == .orange {
                                        turns.notCarambola(data: currentBoxScore)
                                        colorChange()
                                    }
                                })
                        )//revert orange carambola
                    )
                    
                    ZStack{
                        VStack {
                            
                            scoreView(player: .white, score: turns.whiteScore, run: turns.run, tall: tall, wide: wide, color: Color("WhiteScript")) //show white score
                            
                            Spacer()
                            
                            WhiteButton(bigButtonSize: wide)
                                
                            Spacer()
                            
                            
                            avgView(avg: turns.whiteAvg, tall: tall, wide: wide, color: Color("WhiteScript")) //show white average
                        } //white side
                        if UserDefaults.standard.wasWScoreButtonUsed == false && turns.player == .white {
                            Text("White-Point \(Image(systemName:"hand.tap")) \(Image(systemName:"hand.tap"))")
                                .foregroundColor(Color.white)
                                .font(.system(size: tall*0.03))
                                .multilineTextAlignment(.center)
                                .frame(width: wide*0.22, height: tall*0.20, alignment: .bottom)
                        } //show score carambola instructions the first time
                        
                        Spacer()
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background(whiteIsPressed ? whiteFeedbackColor : Color("WhiteManicera"))
                    .gesture(TapGesture()
                        .onEnded{
                            if turns.player == .white {
                                UserDefaults.standard.wasWScoreButtonUsed = true
                                    turns.carambola()
                            }
                        }//score white carambola
                        .simultaneously(with: LongPressGesture(minimumDuration: 1, maximumDistance: 10)
                        .updating($whiteIsPressed) { value, state, _ in state = value
                        }//highlight long press
                        .onEnded({_ in
                                if turns.player == .white {
                                    turns.notCarambola(data: currentBoxScore)
                                    colorChange()
                                }
                            })
                    )//revert white carambola
                    )
                }
                .background(Color.black)

                InningButton(bigButtonSize: wide, newGameFlash: $newGameFlash, archiveDialog: $archiveDialog)
                    .frame(height: tall*0.60, alignment: .bottom)
                
                if archiveDialog {
                    ArchiveDialogView(newGameFlash: $newGameFlash, archiveDialog: $archiveDialog)
                } //show save screen when game over
                
                VStack{
                    Rectangle()
                        .fill(.white.opacity(0.0001))
                        .frame(width: wide, height: tall * swipeFactor)

                    Spacer()
                }//top draggable region to switch tabs

                if UserDefaults.standard.wasInningButtonUsed == false {
                    Text ("Restart-Instructions \(Image(systemName:"hand.tap"))")
                        .padding(2)
                        .foregroundColor(Color("WhiteManicera"))
                        .font(.system(size: tall*0.03))
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("InningRed")))
                        .multilineTextAlignment(.center)
                        .frame(width: wide*0.80, height: tall*0.75, alignment: .bottom)
                }//restart instructions first time
                
                if UserDefaults.standard.wasSwipingUsed == false {
                    
                    swipingInstructions(tall: tall, wide: wide)//show swiping instructions the first time
                }
            }
        }
    }

    
    func scoreView(player: playerId,
                   score: Int,
                   run: Int,
                   tall: CGFloat,
                   wide: CGFloat,
                   color: Color) -> some View{
        HStack{
            Spacer()
            Text("\(score)")
                .foregroundColor(newGameFlash ? Color("Undo") : color)
            if turns.player == player {
                Text(" +\(run)")
                    .foregroundColor((buttonFlash ? Color("Undo") : color))
            }
        }
        .font(.system(size: tall*0.12))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color, lineWidth: 2)
                .frame(width: wide*0.40, height: tall*0.12)
        )
        .frame(width: wide*0.40, height: tall*0.15, alignment: .trailing)
        .padding(25)
    }
    
    func avgView(avg: Double,
                 tall: CGFloat,
                 wide: CGFloat,
                 color: Color) -> some View {
        Text("average \(avg, specifier: "%.3f")")
            .padding()
            .frame(height: tall*0.055, alignment: .center)
            .foregroundColor(newGameFlash ? Color("Undo") : color)
            .font(.system(size: tall*0.04))
            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(color))
            .padding(25)
    }
    
    func swipeHandText(tall: CGFloat) -> some View {
        Text(Image(systemName: "hand.draw"))
            .font(.system(size: tall * 0.06))
            .fontWeight(.light)
    }//swipe hand SFSymbol for first run swiping instructions
    
    func swipingInstructions(tall: CGFloat, wide: CGFloat) -> some View {
        HStack{

                swipeHandText(tall: tall)

                Spacer()
            
                Text("Swiping-Instructions \(Image(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"))")
                    .font(.system(size:tall * 0.06))
                    .fontWeight(.light)

                Spacer()

                swipeHandText(tall: tall)
            
            }
            .padding()
            .foregroundColor(Color.white)
            .frame(width: wide*0.98, height: tall*0.10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color("FeltGreen")).opacity(0.80))
            .offset(y: -tall*0.4)

    }

}

struct scoreBoardView_Previews: PreviewProvider {
    static let turns = TurnsModel()
    static let currentBoxScore = CurrentBoxScore()
    static var previews: some View {
        scoreboardView()
            .environmentObject(turns)
            .environmentObject(currentBoxScore)
    }
}
