// In: Core/Manager/MarketManager.swift

import Foundation

class MarketManager {
    
    private let firstNames = ["Ahmet", "Mehmet", "Mustafa", "Ali", "Hasan", "Hüseyin", "Emre", "Burak", "Can", "Ozan", "Yusuf", "Arda"]
    private let lastNames = ["Yılmaz", "Kaya", "Demir", "Çelik", "Şahin", "Turan", "Güler", "Öztürk", "Aydın", "Yıldız", "Polat"]
    
    // Sonuçları paket halinde döndürmek için yeni bir yapı
    struct RepresentationResult {
        let success: Bool
        let message: String
        let updatedPlayerManager: PlayerManager
        let updatedScoutingOpportunities: [Footballer]?
        let newPlayerForPortfolio: Footballer?
        let newsInfo: (title: String, body: String, symbol: NewsSymbol)
    }
    
    func attemptNewRepresentation(footballerId: UUID, salaryComm: Double, transferComm: Double, successChance: Int, playerManager: PlayerManager, scoutingOpportunities: [Footballer], officeLevels: [Int: OfficeLevel]) -> RepresentationResult {
        
        var mutableManager = playerManager
        var mutableScouting = scoutingOpportunities
        
        guard let currentOffice = officeLevels[mutableManager.officeLevel] else {
            let newsInfo = ("Hata", "Ofis verisi bulunamadı.", NewsSymbol.failure)
            return RepresentationResult(success: false, message: newsInfo.1, updatedPlayerManager: playerManager, updatedScoutingOpportunities: nil, newPlayerForPortfolio: nil, newsInfo: newsInfo)
        }

        if mutableManager.managedFootballerIDs.count >= currentOffice.maxPlayers {
            let message = "Ofis kapasiteniz dolu! (Mevcut Limit: \(currentOffice.maxPlayers) oyuncu)."
            let newsInfo = ("Anlaşma Engellendi", message, NewsSymbol.failure)
            return RepresentationResult(success: false, message: message, updatedPlayerManager: playerManager, updatedScoutingOpportunities: nil, newPlayerForPortfolio: nil, newsInfo: newsInfo)
        }
        
        guard let playerIndex = mutableScouting.firstIndex(where: { $0.id == footballerId }) else {
            let newsInfo = ("Hata", "Pazarlık yapılan oyuncu bulunamadı.", NewsSymbol.failure)
            return RepresentationResult(success: false, message: newsInfo.1, updatedPlayerManager: playerManager, updatedScoutingOpportunities: nil, newPlayerForPortfolio: nil, newsInfo: newsInfo)
        }
        
        var player = mutableScouting[playerIndex]
        if Int.random(in: 1...100) <= successChance {
            player.isManagedByPlayer = true
            player.commissionRate = salaryComm / 100.0
            player.transferCommissionRate = transferComm / 100.0
            mutableManager.managedFootballerIDs.append(player.id)
            mutableManager.reputation += player.potentialAbility / 30
            
            mutableScouting.remove(at: playerIndex)
            
            let message = "Tebrikler! \(player.name) ile anlaştınız. (+\(player.potentialAbility / 30) İtibar)"
            let newsInfo = ("Yeni Yetenek Keşfedildi", message, NewsSymbol.signature)
            
            return RepresentationResult(success: true, message: message, updatedPlayerManager: mutableManager, updatedScoutingOpportunities: mutableScouting, newPlayerForPortfolio: player, newsInfo: newsInfo)
        } else {
            mutableManager.reputation = max(1, mutableManager.reputation - 1)
            let message = "Oyuncu ve ailesi teklifinizi yeterli bulmadı. (-1 İtibar)"
            let newsInfo = ("Pazarlık Başarısız", message, NewsSymbol.failure)
            return RepresentationResult(success: false, message: message, updatedPlayerManager: mutableManager, updatedScoutingOpportunities: nil, newPlayerForPortfolio: nil, newsInfo: newsInfo)
        }
    }
    
    // Diğer fonksiyonlar aynı, sadece createRandomFootballer'a currentYear parametresi ekleniyor
    func createInitialSquad(for team: Team, currentYear: Int) -> [Footballer] {
        var squad: [Footballer] = []
        for _ in 0..<22 {
            let newPlayer = createRandomFootballer(for: team.id, minPotential: 55, maxPotential: 85, isScouted: false, currentYear: currentYear)
            squad.append(newPlayer)
        }
        return squad
    }
    
    func generateScoutingOpportunities(officeLevel: OfficeLevel, currentYear: Int) -> [Footballer] {
        var newOpportunities: [Footballer] = []
        for _ in 0..<3 {
            let newPlayer = createRandomFootballer(for: nil,
                                                   minPotential: officeLevel.minScoutingPotential,
                                                   maxPotential: officeLevel.maxScoutingPotential,
                                                   isScouted: true,
                                                   currentYear: currentYear)
            newOpportunities.append(newPlayer)
        }
        return newOpportunities
    }
    
    private func createRandomFootballer(for teamId: UUID?, minPotential: Int, maxPotential: Int, isScouted: Bool = false, currentYear: Int) -> Footballer {
        let age = isScouted ? Int.random(in: 16...19) : Int.random(in: 17...34)
        let potential = isScouted ? Int.random(in: minPotential...maxPotential) : Int.random(in: 55...85)
        
        let agePenalty = max(0, 25 - age)
        
        let pace = max(40, potential - Int.random(in: 0...agePenalty) - Int.random(in: 0...25))
        let shooting = max(40, potential - Int.random(in: 0...agePenalty) - Int.random(in: 0...25))
        let passing = max(40, potential - Int.random(in: 0...agePenalty) - Int.random(in: 0...25))
        let defending = max(40, potential - Int.random(in: 0...agePenalty) - Int.random(in: 0...25))
        
        let position = Position.allCases.randomElement() ?? .midfielder
        
        let tempFootballer = Footballer(id: UUID(), name: "", surname: "", age: age, position: position, pace: pace, shooting: shooting, passing: passing, defending: defending, potentialAbility: potential, marketValue: 0, teamID: teamId, contractExpiryYear: 0)
        let currentAbility = tempFootballer.currentAbility
        
        let baseValue = (currentAbility * 10000) + (potential * 5000)
        let marketValue = max(5000, baseValue)
        
        let salary = teamId != nil ? (currentAbility * 100) + Int.random(in: 100...1000) : 0
        let contractExpiryYear = teamId != nil ? currentYear + Int.random(in: 1...4) : 0
        
        return Footballer(id: UUID(), name: firstNames.randomElement() ?? "Ad", surname: lastNames.randomElement() ?? "Soyad", age: age, position: position, pace: pace, shooting: shooting, passing: passing, defending: defending, potentialAbility: potential, marketValue: marketValue, teamID: teamId, contractExpiryYear: contractExpiryYear, salary: salary, isManagedByPlayer: false, commissionRate: nil, transferCommissionRate: nil, lastMatchRating: nil)
    }
    
    // upgradeOffice fonksiyonu GameManager'da kalabilir çünkü doğrudan playerManager state'ini değiştiriyor.
    // Şimdilik onu da buraya taşıyalım ve sonucu tuple olarak döndürelim
    func upgradeOffice(playerManager: PlayerManager, officeLevels: [Int: OfficeLevel]) -> (success: Bool, message: String, updatedPlayerManager: PlayerManager?) {
        var mutableManager = playerManager
        guard let currentOffice = officeLevels[mutableManager.officeLevel],
              let upgradeCost = currentOffice.upgradeCost,
              let nextOffice = officeLevels[mutableManager.officeLevel + 1]
        else {
            return (false, "Ofisiniz zaten son seviyede.", nil)
        }
        
        if mutableManager.cash < upgradeCost {
            return (false, "Yetersiz bakiye. Bu yükseltme için \(upgradeCost.formatted(.currency(code: "TRY"))) gereklidir.", nil)
        }
        
        mutableManager.cash -= upgradeCost
        mutableManager.officeLevel += 1
        
        let message = "Tebrikler! Ofisiniz Seviye \(nextOffice.level)'e yükseltildi."
        return (true, message, mutableManager)
    }
}
