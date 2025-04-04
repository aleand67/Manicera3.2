//
//  StatsView.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI
import SwiftData

struct statsView: View {
    @AppStorage("statsOnBoarding") var statsOnBoarding = true
    var body: some View {
        ZStack {
            VStack{
                Text("Individual Stats")
                    .font(Font.largeTitle.weight(.regular))
                    .foregroundStyle(Color("WhiteFeedback"))
                    .frame(maxWidth: .infinity, alignment:  .leading)
                    .padding(10)
                
                Divider().background(.white)
                
                if UIDevice.current.userInterfaceIdiom == .pad, #available(iOS 16.0, *) {
                    table()
                        .preferredColorScheme(.dark) //needed to deal with disparity on how charts are displayed in iPad vs...
                }
                else {
                    grid()
                        .preferredColorScheme(.light) //... iPhone
                }
            }
            .background(.black)
            .overlay(
            StatsOnBoarding()
                .showView(statsOnBoarding)
            )
        }
    }
}



#Preview {
    statsView(statsOnBoarding: true)
        .modelContainer(statsPreviewContainer)
}
