//
//  StatsView.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI
import SwiftData
import Charts

let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 0), count: 6)

struct StatsView: View {
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

private func headerView() -> some View {
    
    LazyVGrid(columns: columns) {
        Group{
            Text("Player") 
            Text("W–L")
            Text("Points")
            Text("Innings")
            Text("Average")
            Text("Long Run")
            
        }
        .foregroundColor(Color.blue)
        .font(.title2)
        .padding(.bottom, 5)
        .background(Color.black)
    }
}
    
struct grid: View {
    @Query(sort: \PlayerStats.wins, order: .reverse) var stats: [PlayerStats]
    @Environment(\.modelContext) var modelContext
    var body: some View {
        if stats.count > 0 {// if at least one player in record
            ScrollView([.vertical]) {
                LazyVGrid(columns: columns, spacing: 10, pinnedViews: [.sectionHeaders]) {
                    Section(header: headerView()){
                        ForEach(stats, id: \.id) { player in
                            Group{
                                nameCell(player: player)
                                Text("\(player.wins)" + " - " + "\(player.losses)")
                                Text("\(player.points)")
                                Text("\(player.innings)")
                                Text("\((player.averages.last ?? 0.0), specifier: "%.3f")")
                                Text("\(player.longRun)")
                            }
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.5)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            } //this hides the data rows as you scroll behind the header
                            .padding(.horizontal)
                            .foregroundColor(Color.white)
                        }
                    }
                }
            }
        } else {
            Color.black
        }
    }
}

struct table: View {
    @Query var stats: [PlayerStats]
    @Environment(\.modelContext) var modelContext
    @State private var sortOrder = [KeyPathComparator(\PlayerStats.averages.last, order: .reverse)]
    @State private var selection: PlayerStats.ID?
    @State private var showChart: Bool = false
    @State private var showAlert: Bool = false

    var body: some View {
        Table(of: PlayerStats.self, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Player", value: \PlayerStats.name!) {stats in
                Text(stats.name!)
            }
            TableColumn("Games", value: \.games) {stats in Text("\(stats.games)")}.alignment(.center)
            TableColumn("W-L", value: \.wins) {stats in Text("\(stats.wins)" + " - " + "\(stats.losses)")}.alignment(.center)
            TableColumn("Points", value: \.points) {stats in Text("\(stats.points)")}.alignment(.center)
            TableColumn("Innings", value: \.innings) {stats in Text("\(stats.innings)")}.alignment(.center)
            TableColumn("Long Run", value: \.longRun) {stats in Text("\(stats.longRun)")}.alignment(.center)
            TableColumn("Average", value: \.averages.last!) {stats in Text("\((stats.averages.last ?? 0), specifier: "%.3f")")}.alignment(.center)
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
                                    }
                                    .padding(10)
                                    .foregroundColor(Color.white)
                    }
                }
            }
            .sheet(isPresented: $showChart) {
            if let selected = stats.first(where: { $0.id == selection }) {
                ZStack {
                    chart(player: selected)
                        .presentationDetents([.fraction(0.40)]) //set frame tight to graph
                }
            } else {
                Text("No Data")
            }
        }
        .alert("Are you sure you want to delete this player?", isPresented: $showAlert) {
            Button("yes, delete this player", role: .destructive) {
                if let index = stats.firstIndex(where: { $0.id == selection }) {
                    modelContext.delete(stats[index])
                }
            }
            Button("No. Don't delete the player", role: .cancel) { }
        } message: {Text("Can't Undo")}
    }
}

struct chart: View {
    let player: PlayerStats
    
    var body: some View {
        GroupBox (label: Text("\(player.name!)").foregroundColor(UIDevice.current.userInterfaceIdiom == .pad ? .white : .black)) {
            Chart {
                ForEach(0..<player.averages.count, id: \.self)
                { entry in
                    LineMark(
                        x: PlottableValue.value("", entry),
                        y: PlottableValue.value("average", player.averages[entry])
                    )
                    .foregroundStyle(.blue)
                    .symbol(.circle)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {AxisMarks(values: .automatic) {
                    AxisValueLabel()
                        .foregroundStyle(Color.gray)
                    AxisGridLine()
                        .foregroundStyle(Color.gray)
                }
            }
            .chartYScale(domain: (player.averages.min() ?? 0)...(player.averages.max() ?? 2))
            .aspectRatio(3, contentMode: .fit)
            .background(Color.white)
        }
    }
}

struct nameCell: View {
    @Query var stats: [PlayerStats]
    @Environment(\.modelContext) var modelContext
    @State private var showChart: Bool = false
    @State private var showAlert: Bool = false
    @State var player: PlayerStats
    var body: some View {
        Text("\(player.name!)")
            .foregroundColor(.white)
            .contextMenu {
                Button("Average Graph") {
                    showChart.toggle()
                }
                Divider()
                Button(role: .destructive) {
                    showAlert.toggle()
                } label: {
                    Label("Delete Player", systemImage: "trash")
                }
            }
            .sheet(isPresented: $showChart) {
                chart(player: player)
                    .presentationBackground(Color.black)
            }
            .alert("Are you sure you want to delete this player?", isPresented: $showAlert) {
                Button("yes, delete this player", role: .destructive) {
                    if let index = stats.firstIndex(where: { $0.id == player.id }) {
                        modelContext.delete(stats[index])
                    }
                }
                Button("No. Don't delete the player", role: .cancel) { }
                } message: {Text("Can't Undo")}
    }
}

