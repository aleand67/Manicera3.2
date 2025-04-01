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
    @State private var newGameFlash: Bool = false
    @State private var archiveDialog: Bool = false
    
    @AppStorage("scoreButtonUsed") var scoreButtonUsed = false
    @AppStorage("wasInningButtonUsed") var wasInningButtonUsed = false
    @AppStorage("wasSwipingUsed") var wasSwipingUsed = false
    
    private var orangeFeedbackColor: Color {
        orangeIsPressed == true && turns.player == .orange ? Color("OrangeFeedback") : Color("OrangeManicera")
    }
    
    private var whiteFeedbackColor: Color {
        whiteIsPressed == true && turns.player == .white ? Color("WhiteFeedback") : Color("WhiteManicera")
    }
    
    private func colorChange() { //flash black when undoing carambola
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
                        Text("Orange-Point \(Image(systemName:"hand.tap")) \(Image(systemName:"hand.tap"))")
                            .foregroundStyle(Color.white)
                            .font(.system(size: tall*0.03))
                            .multilineTextAlignment(.center)
                            .frame(width: wide*0.22, height: tall*0.20, alignment: .bottom)
                            .opacity(!scoreButtonUsed && turns.player == .orange ? 1 : 0) //show score carambola instructions the first time
                        
                        Spacer()
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background(orangeIsPressed ? orangeFeedbackColor : Color("OrangeManicera"))
                    .gesture(TapGesture()
                        .onEnded{
                            if turns.player == .orange {
                                scoreButtonUsed = true
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
                        
                        Text("White-Point \(Image(systemName:"hand.tap")) \(Image(systemName:"hand.tap"))")
                            .foregroundStyle(Color.white)
                            .font(.system(size: tall*0.03))
                            .multilineTextAlignment(.center)
                            .frame(width: wide*0.22, height: tall*0.20, alignment: .bottom)
                            .opacity(!scoreButtonUsed && turns.player == .white ? 1 : 0)//show score carambola instructions the first time
                        
                        Spacer()
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background(whiteIsPressed ? whiteFeedbackColor : Color("WhiteManicera"))
                    .gesture(TapGesture()
                        .onEnded{
                            if turns.player == .white {
                                scoreButtonUsed = true
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
                

                ArchiveDialogView(newGameFlash: $newGameFlash, archiveDialog: $archiveDialog)
                    .opacity(archiveDialog ? 1 : 0)//show save screen when game over
                
                VStack{
                    Rectangle()
                        .fill(.white.opacity(0.0001))
                        .frame(width: wide, height: tall * swipeFactor)

                    Spacer()
                }.showView(!archiveDialog)//top draggable region to switch tabs unless archiveDialogView is on

                Text ("Restart-Instructions \(Image(systemName:"hand.tap"))")
                    .padding(2)
                    .foregroundStyle(Color.black)
                    .font(.system(size: tall*0.03, weight: .light))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .multilineTextAlignment(.center)
                    .frame(width: wide*0.80, height: tall*0.70, alignment: .bottom)
                    .opacity((!wasInningButtonUsed && turns.overallTurn > 0) ? 1 : 0)//restart instructions first time
                
                swipingInstructions(tall: tall, wide: wide)
                .showView(!wasSwipingUsed && !archiveDialog)//show swiping instructions if never used and not in archiving mode
            }
        }
    }

    
    private func scoreView(player: playerId,
                   score: Int,
                   run: Int,
                   tall: CGFloat,
                   wide: CGFloat,
                   color: Color) -> some View{
        HStack{
            Spacer()
            Text("\(score)")
                .foregroundStyle(newGameFlash ? Color("Undo") : color)
            Text(" +\(run)").showView(turns.player == player)
                .foregroundStyle((buttonFlash ? Color("Undo") : color))
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
    
    private func avgView(avg: Double,
                 tall: CGFloat,
                 wide: CGFloat,
                 color: Color) -> some View {
        Text("average \(avg, specifier: "%.3f")")
            .padding()
            .frame(height: tall*0.055, alignment: .center)
            .foregroundStyle(newGameFlash ? Color("Undo") : color)
            .font(.system(size: tall*0.04))
            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(color))
            .padding(25)
    }
    
    private func swipeHandText(tall: CGFloat) -> some View {
        Text(Image(systemName: "hand.draw"))
            .font(.system(size: horizontalSizeClass == .compact ? tall * 0.05 : tall * 0.03))
            .fontWeight(.light)
    }//swipe hand SFSymbol for first run swiping instructions
    
    private func swipingInstructions(tall: CGFloat, wide: CGFloat) -> some View {
        HStack{

                swipeHandText(tall: tall)

                Spacer()
            
                Text("Swiping-Instructions \(Image(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"))")
                    .font(horizontalSizeClass == .compact ? .system(size: tall * 0.05) : .system(size: tall * 0.03))
                    .fontWeight(.light)

                Spacer()

                swipeHandText(tall: tall)
            
            }
            .padding()
            .foregroundStyle(Color.black)
            .frame(width: horizontalSizeClass == .compact ? wide * 0.90 : wide * 0.98, height: tall*0.05)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .offset(y: horizontalSizeClass == .compact ? -tall*0.46 : -tall*0.47)

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
