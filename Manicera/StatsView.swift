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
    @State var sortOrder = SortDescriptor(\PlayerStats.wins)
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
                grid(sortOrder: $sortOrder)
                    .preferredColorScheme(.light) //... iPhone
            }
        }
        .background(Color.black)
    }
}

struct headers: View {
    @Binding var sortOrder: SortDescriptor<PlayerStats>
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Group{
                Button("Player") {sortOrder = SortDescriptor(\PlayerStats.name, order: (sortOrder.order == .reverse) ? .forward : .reverse)}
                Button("W–L") {sortOrder = SortDescriptor(\PlayerStats.wins, order: (sortOrder.order == .reverse) ? .forward : .reverse)}
                Button("Points") {sortOrder = SortDescriptor(\PlayerStats.points, order: (sortOrder.order == .reverse) ? .forward : .reverse)}
                Button("Innings") {sortOrder = SortDescriptor(\PlayerStats.innings, order: (sortOrder.order == .reverse) ? .forward : .reverse)}
                Button("Long Run") {sortOrder = SortDescriptor(\PlayerStats.longRun, order: (sortOrder.order == .reverse) ? .forward : .reverse)}
                Button("Average") {sortOrder = SortDescriptor(\PlayerStats.lastAverage, order: (sortOrder.order == .reverse) ? .forward : .reverse)}
            }
            .foregroundColor(Color.blue)
            .font(.title2)
            .padding(.bottom, 5)
            .background(Color.black)
        }
    }
}
    
struct grid: View {
    @Binding var sortOrder: SortDescriptor<PlayerStats>
    var body: some View {
        ScrollView([.vertical]) {
            LazyVGrid(columns: columns, spacing: 10, pinnedViews: [.sectionHeaders]) {
                Section(header: headers(sortOrder: $sortOrder)){
                    gridRows(sortOrder: sortOrder) // need to separate child view to allow for dynamic sorting using @Query
                }
            }
        }
    }
}

struct gridRows: View {
    @Query(sort: \PlayerStats.name) var stats: [PlayerStats]
    var body: some View {
        ForEach(stats, id: \.id) { player in
            Group{
                nameCell(player: player) //Player name with contextual menu with chart and delete option
                Text("\(player.wins)" + " - " + "\(player.losses)")
                Text("\(player.points)")
                Text("\(player.innings)")
                Text("\(player.longRun)")
                Text("\((player.lastAverage), specifier: "%.3f")")
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
    
    init(sortOrder: SortDescriptor<PlayerStats>) {
        _stats = Query(sort: [sortOrder])
    }
}

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
            TableColumn("W-L", value: \.wins) {stats in Text("\(stats.wins)" + " - " + "\(stats.losses)")}.alignment(.center)
            TableColumn("Points", value: \.points) {stats in Text("\(stats.points)")}.alignment(.center)
            TableColumn("Innings", value: \.innings) {stats in Text("\(stats.innings)")}.alignment(.center)
            TableColumn("Long Run", value: \.longRun) {stats in Text("\(stats.longRun)")}.alignment(.center)
            TableColumn("Average", value: \.averages.last!) {stats in Text("\((stats.lastAverage), specifier: "%.3f")")}.alignment(.center)
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
        .sheet(isPresented: $showChart) {
            if let selected = stats.first(where: { $0.id == selection }) {
            ZStack {
                chart(player: selected)
                    .presentationDetents([.fraction(0.40)]) //set frame tight to graph
            }
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
                    .symbol(.circle)
                    .foregroundStyle(.blue)
                    
//                    PointMark(x: PlottableValue.value("", entry),
//                              y: PlottableValue.value("average", player.averages[entry])
//                          )
//                    .foregroundStyle(.blue)
//                    .annotation(position: .trailing) {
//                        Text("\(player.averages[entry], specifier: "%.3f")")
//                            .font(.system(.caption))
//                            .foregroundColor(Color.white)
//                            .background(Color.blue, in: RoundedRectangle(cornerRadius: 5))
//                    }
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

