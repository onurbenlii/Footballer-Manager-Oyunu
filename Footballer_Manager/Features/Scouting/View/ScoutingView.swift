// In: Features/Scouting/View/ScoutingView.swift

import SwiftUI

struct ScoutingView: View {
    
    @StateObject private var viewModel: ScoutingViewModel
    private let gameManager: GameManager
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        _viewModel = StateObject(wrappedValue: ScoutingViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        Group {
            if viewModel.availablePlayers.isEmpty {
                Text("Bu ay keşfedilecek yeni oyuncu yok.\nBir sonraki ay tekrar kontrol et.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List(viewModel.availablePlayers) { player in
                    // GÜNCELLENDİ: Hedef artık NegotiationView
                    NavigationLink(destination: NegotiationView(footballer: player, gameManager: gameManager)) {
                        PlayerRowView(footballer: player)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Oyuncu Keşfet")
    }
}
