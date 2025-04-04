//
//  BoxScoreOnBoarding.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 4/2/25.
//

import SwiftUI

struct BoxScoreOnBoarding: View {
    @AppStorage("boxScoreOnBoarding") var boxScoreOnBoarding = true
    var body: some View {
        VStack {
            Text("Welcome to the Boxscore Page")
                .font(.title2)
                .bold()
                .padding(.bottom, 5)
            
            Text("You'll find all old boxscores here as well as the current one.")
            Text("Winners are marked with a \(star), and long runs are **bold**.")
            Spacer()
            Text("***Swipe left*** \(Image(systemName: "hand.draw")) to return to the scoreboard.")
            
            Button {
                boxScoreOnBoarding = false
            } label: {
                    Text("Got it!")
                        .font(Font.headline.weight(.bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .foregroundStyle(.white)
        .fixedSize()
        .padding()
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 200)    }
}

#Preview {
    BoxScoreOnBoarding(boxScoreOnBoarding: true)
}
