//
//  StatsOnBoarding.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 4/1/25.
//

import SwiftUI

struct StatsOnBoarding: View {
    @AppStorage("statsOnBoarding") var statsOnBoarding: Bool = true
    var body: some View {
        VStack {
            Text("Welcome to the Stats Page")
                .font(.title2)
                //.foregroundStyle(.white)
                .bold()
                .padding(.bottom, 5)
            
            HStack(spacing:0) {
                Text("***Tap*** \(Image(systemName: "hand.point.up.left")) on ")
                    //.foregroundStyle(.white)
                Text("**columns headers**")
                    .foregroundStyle(.blue)
                Text(" to change order.")
                    //.foregroundStyle(.white)
            }
            Text("***Long Tap*** \(Image(systemName: "hand.tap")) on **players** for graphs and more options.")
            Spacer()
            Text("**Swipe right** \(Image(systemName: "hand.draw")) to return to scoreboard.")
            
            Button {
                statsOnBoarding = false
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
        .shadow(radius: 200)
    }
}

#Preview {
    StatsOnBoarding(statsOnBoarding: true)
}
