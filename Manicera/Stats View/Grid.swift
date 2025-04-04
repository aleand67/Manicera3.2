//
//  Grid.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/29/25.
//

import SwiftUI
import SwiftData

let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 0), count: 6)

enum LabelOrder {
    case playerUp
    case playerDown
    case winsUp
    case winsDown
    case pointsUp
    case pointsDown
    case inningsUp
    case inningsDown
    case longRunUp
    case longRunDown
    case averageUp
    case averageDown
    case none
} //Cases for different orderings on grid stats table for iPhones - eliminate this and the whole grid view when Tables works well with iPhones

struct playerLabel: View {
    @Binding var labelOrder: LabelOrder
    var body: some View {
        switch labelOrder {
        case .playerUp:
            HStack{
                Text("Player")
                Image(systemName: "chevron.up")
            }.padding(.horizontal, 10)
        case .playerDown:
            HStack{
                Text("Player")
                Image(systemName: "chevron.down")
            }.padding(.horizontal, 10)
        default:
            Text("Player").padding(.horizontal, 25) //making space to cover long names
        }
    }
} //"Player" label with up/down chevrons for grid sorting

struct winsLabel: View {
    @Binding var labelOrder: LabelOrder
    var body: some View {
        switch labelOrder {
        case .winsUp:
            HStack{
                Text("W – L")
                Image(systemName: "chevron.up")
            }.padding(.horizontal, 10)
        case .winsDown:
            HStack{
                Text("W – L")
                Image(systemName: "chevron.down")
            }.padding(.horizontal, 10)
        default:
            Text("W – L").padding(.horizontal, 5)
        }
    }
}//"W – L" label with up/down chevrons for grid sorting

struct pointsLabel: View {
    @Binding var labelOrder: LabelOrder
    var body: some View {
        switch labelOrder {
        case .pointsUp:
            HStack{
                Text("Points")
                Image(systemName: "chevron.up")
            }
        case .pointsDown:
            HStack{
                Text("Points")
                Image(systemName: "chevron.down")
            }
        default:
            Text("Points")
        }
    }
}//"Points" label with up/down chevrons for grid sorting

struct inningsLabel: View {
    @Binding var labelOrder: LabelOrder
    var body: some View {
        switch labelOrder {
        case .inningsUp:
            HStack{
                Text("Innings")
                Image(systemName: "chevron.up")
            }
        case .inningsDown:
            HStack{
                Text("Innings")
                Image(systemName: "chevron.down")
            }
        default:
            Text("Innings")
        }
    }
}//"Innings" label with up/down chevrons for grid sorting

struct longRunLabel: View {
    @Binding var labelOrder: LabelOrder
    var body: some View {
        switch labelOrder {
        case .longRunUp:
            HStack{
                Text("Long Run")
                Image(systemName: "chevron.up")
            }
        case .longRunDown:
            HStack{
                Text("Long Run")
                Image(systemName: "chevron.down")
            }
        default:
            Text("Long Run")
        }
    }
}//"Long Run" label with up/down chevrons for grid sorting

struct averageLabel: View {
    @Binding var labelOrder: LabelOrder
    var body: some View {
        switch labelOrder {
        case .averageUp:
            HStack{
                Text("Average")
                Image(systemName: "chevron.up")
            }
        case .averageDown:
            HStack{
                Text("Average")
                Image(systemName: "chevron.down")
            }
        default:
            Text("Average")
        }
    }
}//"Average" label with up/down chevrons for grid sorting

struct headers: View {
    @Binding var sortOrder: SortDescriptor<PlayerStats>
    @State private var labelOrder: LabelOrder = .none
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Group{
                Button {
                    sortOrder = SortDescriptor(\PlayerStats.name, order: (sortOrder.order == .reverse) ? .forward : .reverse)
                    labelOrder = sortOrder.order == .forward ? .playerUp : .playerDown
                } label: {
                    playerLabel(labelOrder: $labelOrder)
                } //Dynamic Column Header for Player Name
                Button {
                    sortOrder = SortDescriptor(\PlayerStats.wins, order: (sortOrder.order == .reverse) ? .forward : .reverse)
                    labelOrder = sortOrder.order == .forward ? .winsUp : .winsDown
                } label: {
                    winsLabel(labelOrder: $labelOrder)
                } //Dynamic Column Header for W – L
                Button {
                    sortOrder = SortDescriptor(\PlayerStats.points, order: (sortOrder.order == .reverse) ? .forward : .reverse)
                    labelOrder = sortOrder.order == .forward ? .pointsUp : .pointsDown
                } label: {
                    pointsLabel(labelOrder: $labelOrder)
                } //Dynamic Column Header for Points
                Button {
                    sortOrder = SortDescriptor(\PlayerStats.innings, order: (sortOrder.order == .reverse) ? .forward : .reverse)
                    labelOrder = sortOrder.order == .forward ? .inningsUp : .inningsDown
                } label: {
                    inningsLabel(labelOrder: $labelOrder)
                } //Dynamic Column Header for Innings
                Button {
                    sortOrder = SortDescriptor(\PlayerStats.longRun, order: (sortOrder.order == .reverse) ? .forward : .reverse)
                    labelOrder = sortOrder.order == .forward ? .longRunUp : .longRunDown
                } label: {
                    longRunLabel(labelOrder: $labelOrder)
                } //Dynamic Column Header for Long Run
                Button {
                    sortOrder = SortDescriptor(\PlayerStats.lastAverage, order: (sortOrder.order == .reverse) ? .forward : .reverse)
                    labelOrder = sortOrder.order == .forward ? .averageUp : .averageDown
                } label: {
                    averageLabel(labelOrder: $labelOrder)
                } //Dynamic Column Header for Average
            }
            .foregroundStyle(.blue)
            .font(.title2)
            .padding(.bottom, 5)
            .background(.black)
        }
    }
}
    
struct grid: View {
    @State var sortOrder = SortDescriptor(\PlayerStats.lastAverage, order: .reverse)
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
            .foregroundStyle(.gray)
            .padding(.horizontal)
            .foregroundStyle(.white)
        }
    }
    
    init(sortOrder: SortDescriptor<PlayerStats>) {
        _stats = Query(sort: [sortOrder])
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
            .lineLimit(1)
            .foregroundStyle(.white)
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
                    .presentationBackground(.black)
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

#Preview {
    @Previewable @State var sortOrder = SortDescriptor(\PlayerStats.wins)
    grid()
        .background(.black)
        .modelContainer(statsPreviewContainer)
}
