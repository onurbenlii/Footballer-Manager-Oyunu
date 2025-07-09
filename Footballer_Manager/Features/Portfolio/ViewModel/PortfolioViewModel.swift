// In: Features/Portfolio/ViewModel/PortfolioViewModel.swift
import Foundation

class PortfolioViewModel: ObservableObject {
    @Published var managedPlayers: [Footballer] = []
    private let gameManager: GameManager
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        fetchManagedPlayers()
    }
    
    // GÜNCELLENDİ: Artık 'gameManager.allPlayers' dizisinden veri çekiyor.
    public func fetchManagedPlayers() {
        // 'allPlayers' listesinden, oyuncu tarafından yönetilenleri filtrele.
        self.managedPlayers = gameManager.allPlayers.filter { $0.isManagedByPlayer }
                                                  .sorted { $0.currentAbility > $1.currentAbility }
    }
}
