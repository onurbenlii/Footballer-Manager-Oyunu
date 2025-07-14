//
//  TransferCenterViewModel.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 14.07.2025.
//


// In: Features/TransferCenter/ViewModel/TransferCenterViewModel.swift

import Foundation
import Combine

@MainActor
class TransferCenterViewModel: ObservableObject {
    
    @Published var activeOffers: [TransferOffer] = []
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        
        // GameManager'deki aktif teklifler listesini dinle
        gameManager.$activeOffers
            .sink { [weak self] offers in
                // Teklifleri, beklemede olanlar en üstte olacak şekilde sırala
                self?.activeOffers = offers.sorted { $0.status == .pending && $1.status != .pending }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Functions
    // View'da (arayüzde) ID'lerden isimlere ulaşmak için yardımcı fonksiyonlar
    
    func getPlayerFromID(_ id: UUID) -> Footballer? {
        return gameManager.allPlayers.first { $0.id == id }
    }
    
    func getTeamFromID(_ id: UUID) -> Team? {
        return gameManager.teams.first { $0.id == id }
    }
}