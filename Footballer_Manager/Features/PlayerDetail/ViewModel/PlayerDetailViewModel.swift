// In: Features/PlayerDetail/ViewModel/PlayerDetailViewModel.swift

import Foundation
import Combine

@MainActor
class PlayerDetailViewModel: ObservableObject {
    
    @Published var footballer: Footballer
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    var canRenewContract: Bool {
        guard footballer.isManagedByPlayer, footballer.teamID != nil else { return false }
        return footballer.contractExpiryYear <= gameManager.currentYear + 1
    }
    
    var canNegotiateTransfer: Bool {
        guard footballer.isManagedByPlayer, footballer.teamID != nil else { return false }
        return true
    }
    
    var canFindClub: Bool {
        return footballer.isManagedByPlayer && footballer.teamID == nil
    }
    
    var canSendToTraining: Bool {
        return footballer.isManagedByPlayer && footballer.injury == nil && footballer.activeTraining == nil
    }
    
    init(footballer: Footballer, gameManager: GameManager) {
        self.footballer = footballer
        self.gameManager = gameManager
        subscribeToGameManagerUpdates()
    }

    // GÜNCELLENEN FONKSİYON
    func transferPlayerButtonTapped() {
        // GameManager'daki yeni toggle fonksiyonumuzu çağırıyoruz
        let result = gameManager.toggleTransferListing(for: footballer.id)
        
        // Arayüzü tazelemek için oyuncunun son halini yeniden çekiyoruz
        self.refreshFootballerData()
        
        // Kullanıcıya bilgi vermek için alert'i hazırlıyoruz
        self.alertMessage = result.message
        self.showAlert = true
    }
    
    func renewContractButtonTapped() {
        let result = gameManager.renewContract(for: footballer.id)
        self.refreshFootballerData()
        self.alertMessage = result.message
        self.showAlert = true
    }
    
    private func subscribeToGameManagerUpdates() {
        gameManager.monthAdvancedPublisher
            .sink { [weak self] in
                self?.refreshFootballerData()
            }
            .store(in: &cancellables)
    }
    
    private func refreshFootballerData() {
        if let updatedFootballer = gameManager.allPlayers.first(where: { $0.id == self.footballer.id }) {
            self.footballer = updatedFootballer
        }
    }
}
