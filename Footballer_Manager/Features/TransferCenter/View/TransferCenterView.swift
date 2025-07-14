// In: Features/TransferCenter/View/TransferCenterView.swift

import SwiftUI

struct TransferCenterView: View {
    
    @StateObject private var viewModel: TransferCenterViewModel
    private let gameManager: GameManager // <-- HATA DÜZELTMESİ: gameManager'ı burada saklıyoruz
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager // <-- HATA DÜZELTMESİ: Değeri atıyoruz
        _viewModel = StateObject(wrappedValue: TransferCenterViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        Group {
            if viewModel.activeOffers.isEmpty {
                Text("Aktif transfer teklifi bulunmuyor.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                List(viewModel.activeOffers) { offer in
                    if let player = viewModel.getPlayerFromID(offer.playerID),
                       let offeringTeam = viewModel.getTeamFromID(offer.offeringTeamID) {
                        
                        VStack(alignment: .leading, spacing: 10) {
                            PlayerRowView(footballer: player)
                            
                            Divider()
                            
                            HStack {
                                Text("Teklif Yapan:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(offeringTeam.name)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            HStack {
                                Text("Bonservis Bedeli:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(offer.amount, format: .currency(code: "TRY"))
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            
                            // HATA DÜZELTMESİ: Artık 'gameManager' burada tanınıyor
                            NavigationLink(destination: TransferNegotiationView(offer: offer, gameManager: gameManager)) {
                                Text("Pazarlık Masasına Otur")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 5)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Transfer Merkezi")
    }
}

#Preview {
    let gm = GameManager()
    // Önizleme için birkaç sahte teklif oluşturalım
    if let player = gm.allPlayers.first(where: {$0.teamID != nil}), let team = gm.teams.last {
        let offer = TransferOffer(playerID: player.id, offeringTeamID: team.id, amount: 5000000, proposedSalary: 25000)
        gm.activeOffers.append(offer)
    }
    
    // HATA DÜZELTMESİ: 'return' ifadesini geri ekliyoruz
    return NavigationView {
        TransferCenterView(gameManager: gm)
    }
}
