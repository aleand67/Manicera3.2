//
//  StatsView.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 0), count: 6)

struct statsView: View {
    var body: some View {
        VStack{
            Text("Individual Stats")
                .font(Font.largeTitle.weight(.regular))
                .foregroundColor(Color("WhiteFeedback"))
                .frame(maxWidth: .infinity, alignment:  .leading)
                .padding(10)
            
            Divider().background(Color.white)
            
            if UIDevice.current.userInterfaceIdiom == .pad, #available(iOS 16.0, *) {
                table()
                    .preferredColorScheme(.dark) //needed to deal with disparity on how charts are displayed in iPad vs...
            }
            else {
                grid()
                    .preferredColorScheme(.light) //... iPhone
            }
        }
        .background(Color.black)
    }
}



#Preview {
    statsView()
        .modelContainer(statsPreviewContainer)
}
