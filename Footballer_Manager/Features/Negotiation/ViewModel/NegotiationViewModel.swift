// In: Features/Negotiation/ViewModel/NegotiationViewModel.swift

import Foundation
import Combine

@MainActor
class NegotiationViewModel: ObservableObject {
    
    // Pazarlık yapılan oyuncu
    let footballer: Footballer
    
    // Teklif edilen komisyon oranları
    @Published var salaryCommission: Double = 10.0 // Maaş komisyonu, %10'dan başlasın
    @Published var transferCommission: Double = 15.0 // Bonservis komisyonu, %15'ten başlasın
    
    // Hesaplanan başarı şansı
    @Published var successChance: Int = 0
    
    // Sonucu göstermek için
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var negotiationResult: Bool? = nil
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    init(footballer: Footballer, gameManager: GameManager) {
        self.footballer = footballer
        self.gameManager = gameManager
        
        // Komisyon oranları her değiştiğinde başarı şansını yeniden hesapla
        Publishers.CombineLatest($salaryCommission, $transferCommission)
            .sink { [weak self] salaryComm, transferComm in
                self?.calculateSuccessChance(salaryCommission: salaryComm, transferCommission: transferComm)
            }
            .store(in: &cancellables)
        
        // İlk değeri manuel olarak hesapla
        calculateSuccessChance(salaryCommission: self.salaryCommission, transferCommission: self.transferCommission)
    }
    
    // GÜNCELLENDİ: Başarı şansını hesaplayan yeni ve dengeli formül
    private func calculateSuccessChance(salaryCommission: Double, transferCommission: Double) {
        guard let reputation = gameManager.playerManager?.reputation else {
            self.successChance = 0
            return
        }
        
        // 1. Temel Şans: Her oyuncunun bir menajerle anlaşmaya açık olma ihtimali.
        let baseChance = 50.0
        
        // 2. İtibar Bonusu: Yüksek itibar, oyuncuyu etkiler.
        let reputationBonus = Double(reputation)
        
        // 3. Oyuncu Kalitesi Zorluğu: Potansiyeli yüksek oyuncular daha zor ikna olur.
        let playerDifficultyPenalty = Double(footballer.potentialAbility) / 3.0
        
        // 4. Komisyon Cezası: Yüksek komisyon talepleri oyuncuyu soğutur.
        let salaryCommissionPenalty = salaryCommission * 1.5
        let transferCommissionPenalty = transferCommission * 0.75
        
        // Tüm faktörleri birleştirerek nihai şansı hesapla
        var finalChance = baseChance + reputationBonus - playerDifficultyPenalty - salaryCommissionPenalty - transferCommissionPenalty
        
        // Şansın %5 ile %95 arasında kalmasını sağla
        finalChance = max(5, min(95, finalChance))
        
        self.successChance = Int(finalChance)
    }
    
    // Oyuncuyu temsil etmek için teklif yap
    func makeOffer() {
        let result = gameManager.attemptNewRepresentation(
            footballerId: footballer.id,
            salaryCommission: self.salaryCommission,
            transferCommission: self.transferCommission,
            successChance: self.successChance
        )
        
        self.alertMessage = result.message
        self.negotiationResult = result.success
        self.showAlert = true
    }
}
