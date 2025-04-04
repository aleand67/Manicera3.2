//
//  Chart.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/29/25.
//

import SwiftUI
import Charts

struct chart: View {
    let player: PlayerStats
    @State private var rawSelectedGame: Int?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GroupBox (
            label: Text("\(player.name!) \(Image(systemName: "x.circle.fill"))")
                .foregroundStyle(UIDevice.current.userInterfaceIdiom == .pad ? .white : .black)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }//works on both, but necessary on fullScreen modal on iPad
        )
        {Chart {
            
            ForEach(0..<player.averages.count, id: \.self)
            { entry in
                LineMark(
                    x: .value("", entry),
                    y: .value("average", player.averages[entry])
                )
                .symbol(.circle)
                .foregroundStyle(.blue)
                
                PointMark(
                    x: .value("", entry),
                    y: .value("average", player.averages[entry])
                )
                .opacity(rawSelectedGame != nil && rawSelectedGame == entry ? 1 : 0)
                .foregroundStyle(.blue)
                .annotation(position: .trailing) {
                    Text("\(player.averages[entry], specifier: "%.3f")")
                        .font(.system(.headline))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 5))
                        .opacity(rawSelectedGame != nil && rawSelectedGame == entry ? 1 : 0)
                                    }
            }
        }
        .chartXSelection(value: $rawSelectedGame)
        .chartXAxis(.hidden)
        .chartYAxis {AxisMarks(values: .automatic) {
            AxisValueLabel()
                .foregroundStyle(.gray)
            AxisGridLine()
                .foregroundStyle(.gray)
        }
        }
        .chartYScale(domain: (player.averages.min() ?? 0)...(player.averages.max() ?? 2))
        .aspectRatio(3, contentMode: .fit)
        .background(.white)
        }
    }
}

#Preview {
    chart(player: PlayerStats.example)
}
