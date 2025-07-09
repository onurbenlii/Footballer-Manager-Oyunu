//
//  OfficeViewModel.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 3.07.2025.
//


// In: Features/Office/ViewModel/OfficeViewModel.swift

import Foundation
import Combine

@MainActor
class OfficeViewModel: ObservableObject {
    
    // Ofis verilerini tutacak değişkenler
    @Published var currentOfficeLevel: Int = 0
    @Published var currentPlayerCapacity: Int = 0
    @Published var maxPlayerCapacity: Int = 0
    @Published var scoutQualityDescription: String = ""
    @Published var nextLevelUpgradeCost: String = "Son Seviye"
    @Published var canUpgrade: Bool = false
    
    // Alert için
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        
        // GameManager'daki playerManager değişikliklerini dinle
        gameManager.$playerManager
            .compactMap { $0 }
            .sink { [weak self] manager in
                self?.updateOfficeDetails(for: manager)
            }
            .store(in: &cancellables)
    }
    
    // Arayüzde gösterilecek verileri formatla
    private func updateOfficeDetails(for manager: PlayerManager) {
        guard let officeData = gameManager.officeLevels[manager.officeLevel] else { return }
        
        self.currentOfficeLevel = officeData.level
        self.currentPlayerCapacity = manager.managedFootballerIDs.count
        self.maxPlayerCapacity = officeData.maxPlayers
        self.scoutQualityDescription = "\(officeData.minScoutingPotential) - \(officeData.maxScoutingPotential) Potansiyel"
        
        // Bir sonraki seviye var mı ve maliyeti ne kadar?
        if let upgradeCost = officeData.upgradeCost {
            self.nextLevelUpgradeCost = upgradeCost.formatted(.currency(code: "TRY"))
            // Yükseltme yapılıp yapılamayacağını kontrol et
            self.canUpgrade = manager.cash >= upgradeCost
        } else {
            self.nextLevelUpgradeCost = "Son Seviye"
            self.canUpgrade = false
        }
    }
    
    // Ofisi yükseltme fonksiyonunu tetikle
    func upgradeButtonTapped() {
        let result = gameManager.upgradeOffice()
        self.alertMessage = result.message
        self.showAlert = true
    }
}