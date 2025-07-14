// In: Features/TransferCenter/ViewModel/TransferNegotiationViewModel.swift

import Foundation
import Combine

@MainActor
class TransferNegotiationViewModel: ObservableObject {
    
    @Published var offer: TransferOffer
    
    // Pazarlıkta kullanacağımız değişkenler
    @Published var counterOfferAmount: Double
    @Published var counterOfferSalary: Double // <-- YENİ EKLENDİ
    @Published var successChance: Int = 0
    @Published var negotiationEnded: Bool = false
    @Published var alertMessage: String = ""
    
    let player: Footballer
    let offeringTeam: Team
    
    private let gameManager: GameManager
    
    init(offer: TransferOffer, gameManager: GameManager) {
        self.offer = offer
        self.gameManager = gameManager
        
        // Pazarlığa başlarken, karşı tekliflerimiz kulübün ilk teklifiyle aynı olsun
        self.counterOfferAmount = Double(offer.amount)
        self.counterOfferSalary = Double(offer.proposedSalary) // <-- YENİ EKLENDİ
        
        self.player = gameManager.allPlayers.first { $0.id == offer.playerID }!
        self.offeringTeam = gameManager.teams.first { $0.id == offer.offeringTeamID }!
        
        // İki slider'dan herhangi biri değiştiğinde başarı şansını yeniden hesapla
        Publishers.CombineLatest($counterOfferAmount, $counterOfferSalary)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] newAmount, newSalary in
                self?.calculateSuccessChance(amount: newAmount, salary: newSalary)
            }
            .store(in: &cancellables)
        
        // İlk başarı şansını hesapla
        calculateSuccessChance(amount: self.counterOfferAmount, salary: self.counterOfferSalary)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // Başarı şansını hesaplayan ana mantık (artık maaşı da dikkate alıyor)
    private func calculateSuccessChance(amount: Double, salary: Double) {
        let initialOfferAmount = Double(offer.amount)
        let initialSalary = Double(offer.proposedSalary)
        
        let amountDifference = amount - initialOfferAmount
        let salaryDifference = salary - initialSalary
        
        let teamBudget = Double(offeringTeam.budget)
        
        // İstediğimiz artışlar, kulüp bütçesinin ne kadarına denk geliyor?
        // Maaşın etkisi bonservise göre 5 kat daha fazla olsun (çünkü uzun vadeli bir maliyet)
        let amountPenalty = max(0, (amountDifference / teamBudget) * 100)
        let salaryPenalty = max(0, (salaryDifference * 12 * 3 / teamBudget) * 100) * 5 // 3 yıllık maliyet üzerinden
        
        let reputationBonus = gameManager.playerManager?.reputation ?? 0
        
        // Başarı şansı, itibarla başlar ve istediğimiz para arttıkça azalır.
        var chance = 95.0 - amountPenalty - salaryPenalty + Double(reputationBonus)
        
        self.successChance = Int(max(5, min(100, chance)))
    }
    
    func makeCounterOffer() {
        // Bu fonksiyonu bir sonraki adımda GameManager'da güncelleyeceğiz
    }
    
    func acceptOffer() {
        gameManager.acceptTransferOffer(offerId: offer.id)
        self.alertMessage = "Teklif kabul edildi! \(player.name), \(offeringTeam.name) takımına transfer oldu."
        self.negotiationEnded = true
    }
}
