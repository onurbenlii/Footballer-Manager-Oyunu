// In: Features/Scouting/ViewModel/ScoutingViewModel.swift

import Foundation
import Combine

class ScoutingViewModel: ObservableObject {
    
    @Published var availablePlayers: [Footballer] = []
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        
        // GameManager'daki fırsat listesini dinle
        gameManager.$scoutingOpportunities
            .sink { [weak self] opportunities in
                self?.availablePlayers = opportunities
            }
            .store(in: &cancellables)
    }
}
