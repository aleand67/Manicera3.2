//
//  Table.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/29/25.
//

import SwiftData
import SwiftUI

struct table: View {
    @Query var stats: [PlayerStats]
    @Environment(\.modelContext) var modelContext
    @State private var sortOrder = [KeyPathComparator(\PlayerStats.lastAverage, order: .reverse)]
    @State private var selection: PlayerStats.ID?
    @State private var showChart: Bool = false
    @State private var showAlert: Bool = false

    var body: some View {
        Table(of: PlayerStats.self, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Player", value: \PlayerStats.name!) {stats in
                Text(stats.name!)
            }
            TableColumn("Games", value: \.games) {stats in Text("\(stats.games)")}.alignment(.center)
            TableColumn("W – L", value: \.wins) {stats in Text("\(stats.wins)" + " - " + "\(stats.losses)")}.alignment(.center)
            TableColumn("Points", value: \.points) {stats in Text("\(stats.points)")}.alignment(.center)
            TableColumn("Innings", value: \.innings) {stats in Text("\(stats.innings)")}.alignment(.center)
            TableColumn("Long Run", value: \.longRun) {stats in Text("\(stats.longRun)")}.alignment(.center)
            TableColumn("Average", value: \.lastAverage) {stats in Text("\((stats.lastAverage), specifier: "%.3f")")}.alignment(.center)
        }
        rows: {
            ForEach(stats.sorted(using: sortOrder)) { row in
                TableRow(row)
                    .contextMenu {
                        Button("Average Graph") {
                            selection = row.id
                            showChart.toggle()
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            selection = row.id
                            showAlert.toggle()
                        } label: {
                            Label("Delete Player", systemImage: "trash")
                        } //delete player

                    }
            }
        }
        .fullScreenCover(isPresented: $showChart) {
            if let selected = stats.first(where: { $0.id == selection }) {
                chart(player: selected)
            } else {
                Text("No Data")
            }
        }// sheet with chart
        .alert("Are you sure you want to delete this player?", isPresented: $showAlert) {
            Button("yes, delete this player", role: .destructive) {
                if let index = stats.firstIndex(where: { $0.id == selection }) {
                    modelContext.delete(stats[index])
                }
            }
            Button("No. Don't delete the player", role: .cancel) { }
        } message: {Text("Can't Undo")} // delete player dialog
    }
}

#Preview {
    table()
        .modelContainer(statsPreviewContainer)
}
