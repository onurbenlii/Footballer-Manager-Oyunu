// In: Features/Dashboard/View/DashboardView.swift

import SwiftUI

struct DashboardView: View {
    
    @StateObject private var viewModel: DashboardViewModel
    private let gameManager: GameManager
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        _viewModel = StateObject(wrappedValue: DashboardViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Menajer Profili")) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.red)
                        Text("Tarih")
                        Spacer()
                        Text(viewModel.currentDateString)
                            .font(.headline)
                    }
                    HStack {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(.brown)
                        Text("Kasa")
                        Spacer()
                        Text(viewModel.playerCash)
                            .font(.headline)
                    }
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                        Text("Yönetilen Oyuncu Sayısı")
                        Spacer()
                        Text("\(viewModel.managedPlayerCount)")
                            .font(.headline)
                    }
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("İtibar")
                        Spacer()
                        Text("\(viewModel.playerReputation)")
                            .font(.headline)
                    }
                }
                
                Section(header: Text("Aksiyonlar")) {
                    // YENİ: Ofis linki eklendi
                    NavigationLink(destination: OfficeView(gameManager: gameManager)) {
                        Label("Ofisim", systemImage: "building.2.crop.circle.fill")
                    }
                    
                    NavigationLink(destination: StaffView(gameManager: gameManager)) {
                        Label("Personel", systemImage: "person.2.fill")
                    }
                    
                    NavigationLink(destination: LeagueView(gameManager: gameManager)) {
                                           Label("Puan Durumu", systemImage: "sportscourt.fill")
                    }
                    
                    // DashboardView.swift -> Aksiyonlar bölümüne ekle

                    NavigationLink(destination: TransferCenterView(gameManager: gameManager)) {
                        Label("Transfer Merkezi", systemImage: "arrow.right.arrow.left.square.fill")
                    }
                    
                    NavigationLink(destination: ScoutingView(gameManager: gameManager)) {
                        Label("Oyuncu Keşfet", systemImage: "magnifyingglass")
                    }
                    
                    NavigationLink(destination: PortfolioView(gameManager: gameManager)) {
                        Label("Portföyüm", systemImage: "person.crop.rectangle.stack.fill")
                    }
                    
                    NavigationLink(destination: InboxView(gameManager: gameManager)) {
                        Label {
                            Text("Gelen Kutusu")
                        } icon: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "envelope.fill")
                                if viewModel.hasUnreadNews {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        viewModel.advanceMonthButtonTapped()
                    }) {
                        Label("Bir Ay İlerle", systemImage: "arrow.right.circle.fill")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Ana Panel")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Aylık Rapor"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Tamam")))
            }
        }
    }
}
