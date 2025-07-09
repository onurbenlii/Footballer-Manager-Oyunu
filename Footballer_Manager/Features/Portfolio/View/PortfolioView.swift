// In: Features/Portfolio/View/PortfolioView.swift
import SwiftUI

struct PortfolioView: View {
    @StateObject private var viewModel: PortfolioViewModel
    private let gameManager: GameManager
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        _viewModel = StateObject(wrappedValue: PortfolioViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        Group {
            if viewModel.managedPlayers.isEmpty {
                Text("Henüz menajerliğini yaptığınız bir oyuncu yok.").font(.headline).foregroundColor(.secondary)
            } else {
                List(viewModel.managedPlayers) { player in
                    NavigationLink(destination: PlayerDetailView(footballer: player, gameManager: gameManager)) {
                        HStack {
                            PlayerRowView(footballer: player)
                            Spacer()
                            // YENİ: Sözleşme durumu için uyarı ikonu
                            if player.getContractStatus(forCurrentYear: gameManager.currentYear) != .active {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(player.getContractStatus(forCurrentYear: gameManager.currentYear) == .expiring ? .orange : .red)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Portföyüm")
        .onAppear {
            viewModel.fetchManagedPlayers()
        }
    }
}
