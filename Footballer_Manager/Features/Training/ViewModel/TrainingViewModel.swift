//
//  TrainingViewModel.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 9.07.2025.
//


// In: Features/Training/ViewModel/TrainingViewModel.swift

import Foundation

@MainActor
class TrainingViewModel: ObservableObject {
    
    let footballer: Footballer
    @Published var availableCamps: [TrainingCamp] = []
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var trainingStarted: Bool = false
    
    private let gameManager: GameManager
    
    init(footballer: Footballer, gameManager: GameManager) {
        self.footballer = footballer
        self.gameManager = gameManager
        self.availableCamps = gameManager.trainingCamps
    }
    
    func sendPlayerToCamp(campId: UUID) {
        let result = gameManager.sendPlayerToTraining(playerId: footballer.id, campId: campId)
        
        self.alertMessage = result.message
        self.trainingStarted = result.success
        self.showAlert = true
    }
}