// In: Core/Manager/GameManager.swift

import Foundation
import Combine

// Ofis seviyelerinin özelliklerini tutacak struct
struct OfficeLevel {
    let level: Int
    let maxPlayers: Int
    let upgradeCost: Int?
    let minScoutingPotential: Int
    let maxScoutingPotential: Int
}

// Kaydedilecek tüm oyun durumunu bir arada tutan yapı
struct GameState: Codable {
    var playerManager: PlayerManager
    var allPlayers: [Footballer]
    var scoutingOpportunities: [Footballer]
    var teams: [Team]
    var newsItems: [NewsItem]
    var leagueTable: [TeamStats]
    var recentResults: [MatchResult]
    var currentYear: Int
    var currentMonth: Int
}

class GameManager: ObservableObject {
    
    @Published var allPlayers: [Footballer] = []
    @Published var scoutingOpportunities: [Footballer] = []
    @Published var teams: [Team] = []
    @Published var leagueTable: [TeamStats] = []
    @Published var recentResults: [MatchResult] = []
    
    @Published var playerManager: PlayerManager?
    @Published var newsItems: [NewsItem] = []
    
    @Published var currentYear: Int = 2025
    @Published var currentMonth: Int = 7
    
    // Uzman Yönetici Sınıfları
    private let playerLifecycleManager = PlayerLifecycleManager()
    private let simulationManager = SimulationManager()
    private let marketManager = MarketManager()
    
    // Antrenman kampları listesi
    let trainingCamps: [TrainingCamp] = [
        TrainingCamp(id: UUID(), name: "Hız Kampı", description: "Oyuncunun hız ve depar özelliklerini geliştirir.", cost: 100_000, durationMonths: 3, targetAttribute: \.pace, pointsGained: 2, iconName: "hare.fill"),
        TrainingCamp(id: UUID(), name: "Bitiricilik Kliniği", description: "Forvet ve ofansif orta sahalar için şut yeteneğini keskinleştirir.", cost: 150_000, durationMonths: 4, targetAttribute: \.shooting, pointsGained: 3, iconName: "soccerball.inverse"),
        TrainingCamp(id: UUID(), name: "Oyun Kurma Atölyesi", description: "Orta sahalar için pas ve oyun görüşünü geliştirir.", cost: 120_000, durationMonths: 3, targetAttribute: \.passing, pointsGained: 2, iconName: "eye.fill"),
        TrainingCamp(id: UUID(), name: "Savunma Taktikleri Semineri", description: "Defans oyuncularının pozisyon alma ve müdahale yeteneklerini artırır.", cost: 100_000, durationMonths: 4, targetAttribute: \.defending, pointsGained: 3, iconName: "shield.lefthalf.filled")
    ]
    
    let officeLevels: [Int: OfficeLevel] = [
        1: OfficeLevel(level: 1, maxPlayers: 1, upgradeCost: 500_000, minScoutingPotential: 55, maxScoutingPotential: 70),
        2: OfficeLevel(level: 2, maxPlayers: 3, upgradeCost: 2_000_000, minScoutingPotential: 65, maxScoutingPotential: 80),
        3: OfficeLevel(level: 3, maxPlayers: 5, upgradeCost: 10_000_000, minScoutingPotential: 75, maxScoutingPotential: 90),
        4: OfficeLevel(level: 4, maxPlayers: 8, upgradeCost: nil, minScoutingPotential: 80, maxScoutingPotential: 95)
    ]
    
    let monthAdvancedPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        if !loadGame() {
            print("Kayıtlı oyun bulunamadı, yeni oyun oluşturuluyor.")
            generateInitialData()
        } else {
            print("Kayıtlı oyun başarıyla yüklendi.")
        }
    }
    
    // MARK: - Kayıt ve Yükleme
    
    private var saveURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("savegame.json")
    }
    
    func saveGame() {
        guard let playerManager = playerManager else { return }
        let gameState = GameState(playerManager: playerManager, allPlayers: allPlayers, scoutingOpportunities: scoutingOpportunities, teams: teams, newsItems: newsItems, leagueTable: leagueTable, recentResults: recentResults, currentYear: currentYear, currentMonth: currentMonth)
        do {
            let data = try JSONEncoder().encode(gameState)
            try data.write(to: saveURL, options: [.atomicWrite, .completeFileProtection])
            print("Oyun başarıyla kaydedildi: \(saveURL.path)")
        } catch {
            print("Oyunu kaydederken hata oluştu: \(error.localizedDescription)")
        }
    }
    
    @discardableResult
    func loadGame() -> Bool {
        do {
            let data = try Data(contentsOf: saveURL)
            let gameState = try JSONDecoder().decode(GameState.self, from: data)
            self.playerManager = gameState.playerManager
            self.allPlayers = gameState.allPlayers
            self.scoutingOpportunities = gameState.scoutingOpportunities
            self.teams = gameState.teams
            self.newsItems = gameState.newsItems
            self.leagueTable = gameState.leagueTable
            self.recentResults = gameState.recentResults
            self.currentYear = gameState.currentYear
            self.currentMonth = gameState.currentMonth
            return true
        } catch {
            print("Kayıtlı oyun yüklenemedi: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Ana Oyun Döngüsü
    
    private func addNewsItem(title: String, body: String, symbol: NewsSymbol) {
        let newItem = NewsItem(year: currentYear, month: currentMonth, title: title, body: body, symbol: symbol)
        newsItems.insert(newItem, at: 0)
    }
    
    func advanceOneMonth() -> (success: Bool, message: String) {
        guard var playerManager = self.playerManager else { return (false, "Oyun verileri yüklenemedi.") }
        
        // 1. Maçları Oynat
        let matchWeekResult = simulationManager.simulateMatchWeek(teams: self.teams, allPlayers: self.allPlayers, currentLeagueTable: self.leagueTable)
        self.allPlayers = matchWeekResult.updatedPlayers
        self.leagueTable = matchWeekResult.updatedLeagueTable
        self.recentResults = matchWeekResult.recentResults
        
        // 2. Ay ve Yıl ilerlemesi
        currentMonth += 1
        if currentMonth > 12 {
            currentMonth = 1
            currentYear += 1
            self.allPlayers = playerLifecycleManager.ageAllPlayers(for: self.allPlayers)
            self.leagueTable = simulationManager.resetLeagueTable(for: self.teams)
            addNewsItem(title: "Yeni Sezon Başladı!", body: "Ligde yeni sezon başladı ve tüm takımların puanları sıfırlandı. Şampiyonluk yarışı yeniden başlıyor!", symbol: .league)
        }
        
        // 3. Oyuncu Gelişimi, Sakatlık, Antrenman ve Nitelik güncellemeleri
        self.allPlayers = playerLifecycleManager.updateAttributes(for: self.allPlayers)
        let lifecycleResult = playerLifecycleManager.processMonthlyUpdates(for: self.allPlayers, trainingCamps: self.trainingCamps, currentYear: self.currentYear, currentMonth: self.currentMonth)
        self.allPlayers = lifecycleResult.updatedPlayers
        self.newsItems.insert(contentsOf: lifecycleResult.newsItems, at: 0)
        
        // 4. Yeni Keşif Fırsatları Yarat
        guard let currentOffice = officeLevels[playerManager.officeLevel] else { return (false, "Ofis verisi yok.") }
        self.scoutingOpportunities = marketManager.generateScoutingOpportunities(officeLevel: currentOffice, currentYear: self.currentYear)
        
        // 4.5. Transfer Tekliflerini Oluştur
        let listedPlayers = allPlayers.filter { $0.isTransferListed && $0.teamID != nil }
        for player in listedPlayers {
            let potentialBidders = teams.filter { $0.id != player.teamID && $0.budget > player.marketValue }
            for bidder in potentialBidders {
                let interestScore = (Double(bidder.budget) / 10_000_000) + Double(player.currentAbility / 5) + Double(player.potentialAbility / 10)
                if Double.random(in: 0...100) < interestScore {
                    let offerAmount = Int(Double(player.marketValue) * Double.random(in: 0.8...1.3))
                    if bidder.budget > offerAmount {
                        let newsBody = "\(bidder.name) kulübü, oyuncunuz \(player.name) \(player.surname) için \(offerAmount.formatted(.currency(code: "TRY"))) değerinde bir transfer teklifi yaptı. Teklifi değerlendirmek için gelen kutunuzu kontrol edin."
                        
                        let offerNews = NewsItem(year: currentYear, month: currentMonth, title: "Transfer Teklifi Geldi!", body: newsBody, symbol: .transfer, offerTargetPlayerID: player.id, offerBidderTeamID: bidder.id, offerAmount: offerAmount)
                        newsItems.insert(offerNews, at: 0)
                    }
                }
            }
        }
        
        // 5. Finansal İşlemler
        let managedPlayers = allPlayers.filter { $0.isManagedByPlayer }
        let totalMonthlyIncome = managedPlayers.reduce(0) { total, player in
            if player.getContractStatus(forCurrentYear: self.currentYear) != .expired, let commission = player.commissionRate {
                 let incomeFromPlayer = Double(player.salary) * commission
                 return total + Int(incomeFromPlayer)
            }
            return total
        }
        playerManager.cash += totalMonthlyIncome
        
        let monthlyExpenses = 25000
        playerManager.cash -= monthlyExpenses
        self.playerManager = playerManager
        
        monthAdvancedPublisher.send()
        
        let finalMessage = "Bir ay ilerlendi."
        return (true, finalMessage)
    }
    
    // MARK: - Yönetici Fonksiyonlarına Delege Etme
    
    func upgradeOffice() -> (success: Bool, message: String) {
        guard let playerManager = self.playerManager else { return (false, "Yönetici verisi yok.") }
        let result = marketManager.upgradeOffice(playerManager: playerManager, officeLevels: self.officeLevels)
        
        if result.success, let updatedManager = result.updatedPlayerManager {
            self.playerManager = updatedManager
            addNewsItem(title: "Ofis Yükseltildi!", body: result.message, symbol: .upgrade)
        }
        return (result.success, result.message)
    }
    
    func attemptNewRepresentation(footballerId: UUID, salaryCommission: Double, transferCommission: Double, successChance: Int) -> (success: Bool, message: String) {
        guard let playerManager = self.playerManager else { return (false, "Yönetici verisi yok.") }
        
        let result = marketManager.attemptNewRepresentation(footballerId: footballerId, salaryComm: salaryCommission, transferComm: transferCommission, successChance: successChance, playerManager: playerManager, scoutingOpportunities: self.scoutingOpportunities, officeLevels: self.officeLevels)
        
        if result.success {
            self.playerManager = result.updatedPlayerManager
            if let updatedScouting = result.updatedScoutingOpportunities { self.scoutingOpportunities = updatedScouting }
            if let newPlayer = result.newPlayerForPortfolio { self.allPlayers.append(newPlayer) }
        } else {
             self.playerManager = result.updatedPlayerManager
        }

        addNewsItem(title: result.newsInfo.title, body: result.newsInfo.body, symbol: result.newsInfo.symbol)
        
        return (result.success, result.message)
    }

    func sendPlayerToTraining(playerId: UUID, campId: UUID) -> (success: Bool, message: String) {
        guard var playerManager = self.playerManager else { return (false, "Yönetici verisi yok.") }
        guard let playerIndex = allPlayers.firstIndex(where: { $0.id == playerId }) else { return (false, "Oyuncu bulunamadı.") }
        guard let camp = trainingCamps.first(where: { $0.id == campId }) else { return (false, "Antrenman kampı bulunamadı.") }
        
        var player = allPlayers[playerIndex]
        
        if player.activeTraining != nil { return (false, "Bu oyuncu zaten bir antrenmanda.") }
        if player.injury != nil { return (false, "Sakat bir oyuncu antrenmana gönderilemez.") }
        if playerManager.cash < camp.cost { return (false, "Yetersiz bakiye.") }
        
        playerManager.cash -= camp.cost
        player.activeTraining = PlayerTraining(campID: campId, monthsRemaining: camp.durationMonths)
        
        self.allPlayers[playerIndex] = player
        self.playerManager = playerManager
        
        let message = "\(player.name) \(player.surname), \(camp.name) kampına gönderildi."
        addNewsItem(title: "Antrenman Başladı", body: message, symbol: .training)
        
        return (true, message)
    }
    
    func signPlayerToClub(footballerId: UUID, teamId: UUID) -> (success: Bool, message: String) {
        guard var playerManager = self.playerManager else { return (false, "Yönetici verisi yok.") }
        guard let playerIndex = allPlayers.firstIndex(where: { $0.id == footballerId }) else { return (false, "Oyuncu bulunamadı.") }
        guard let team = teams.first(where: { $0.id == teamId }) else { return (false, "Kulüp bulunamadı.") }
        
        let successChance = 50 + playerManager.reputation + (allPlayers[playerIndex].potentialAbility / 5) - (allPlayers[playerIndex].currentAbility / 4)
        if Int.random(in: 1...100) > successChance {
            let msg = "\(team.name) kulübü, oyuncunun potansiyeline yatırım yapmaktan vazgeçti."
            addNewsItem(title: "Anlaşma Sağlanamadı", body: msg, symbol: .failure)
            return (false, msg)
        }
        
        var footballer = allPlayers[playerIndex]
        let newSalary = (footballer.currentAbility * 150) + (footballer.potentialAbility * 100)
        let contractLength = footballer.age < 18 ? 5 : 3
        footballer.teamID = teamId
        footballer.salary = newSalary
        footballer.contractExpiryYear = self.currentYear + contractLength
        self.allPlayers[playerIndex] = footballer
        
        playerManager.reputation += 5
        self.playerManager = playerManager
        
        let msg = "\(footballer.name), \(team.name) ile ilk profesyonel sözleşmesini imzaladı! (+5 İtibar)"
        addNewsItem(title: "İlk Profesyonel Sözleşme", body: msg, symbol: .success)
        return (true, msg)
    }
    
    func negotiateNewContract(for footballerId: UUID) -> (success: Bool, message: String) {
        return (false, "Bu özellik henüz aktif değil.")
    }

    func renewContract(for footballerId: UUID) -> (success: Bool, message: String) {
        guard var playerManager = self.playerManager else { return (false, "Yönetici verisi bulunamadı.") }
        guard let playerIndex = allPlayers.firstIndex(where: { $0.id == footballerId }) else { return (false, "Oyuncu bulunamadı.") }
        var footballer = allPlayers[playerIndex]
        
        guard let teamId = footballer.teamID, let team = teams.first(where: { $0.id == teamId }) else {
            return (false, "Oyuncunun bir kulübü yok.")
        }
        
        let newSalary = Int(Double((footballer.currentAbility * 150) + (footballer.potentialAbility * 50)) * 1.20)
        let contractLength = footballer.age < 24 ? 4 : (footballer.age < 29 ? 3 : 2)
        
        if team.budget < (newSalary * 12 * contractLength) {
            let message = "\(team.name) kulübünün bütçesi bu yeni sözleşmeyi karşılamaya yetmiyor."
            addNewsItem(title: "Sözleşme Reddedildi", body: message, symbol: .failure)
            return (false, message)
        }
        
        let successChance = 80 + playerManager.reputation - (footballer.currentAbility / 10)
        
        if Int.random(in: 1...100) <= successChance {
            footballer.salary = newSalary
            footballer.contractExpiryYear = self.currentYear + contractLength
            self.allPlayers[playerIndex] = footballer
            playerManager.reputation += 3
            self.playerManager = playerManager
            
            let message = "\(footballer.name) \(footballer.surname), \(team.name) ile olan sözleşmesini \(contractLength) yıl daha uzattı! (+3 İtibar)"
            addNewsItem(title: "Sözleşme Yenilendi", body: message, symbol: .contract)
            return (true, message)
            
        } else {
            playerManager.reputation = max(1, playerManager.reputation - 2)
            self.playerManager = playerManager
            
            let message = "\(footballer.name) \(footballer.surname) kendisine sunulan yeni sözleşme teklifini yetersiz buldu ve reddetti. (-2 İtibar)"
            addNewsItem(title: "Teklif Reddedildi", body: message, symbol: .failure)
            return (false, message)
        }
    }

    func toggleTransferListing(for footballerId: UUID) -> (success: Bool, message: String) {
        guard let playerIndex = allPlayers.firstIndex(where: { $0.id == footballerId }) else {
            return (false, "Oyuncu bulunamadı.")
        }
        
        allPlayers[playerIndex].isTransferListed.toggle()
        
        let isListed = allPlayers[playerIndex].isTransferListed
        let playerName = allPlayers[playerIndex].name
        
        let message = isListed ? "\(playerName) transfer listesine eklendi. İlgilenen kulüplerden gelecek teklifler bekleniyor." : "\(playerName) transfer listesinden çıkarıldı."
        let newsTitle = isListed ? "Transfer Listesinde" : "Liste Dışı"
        
        addNewsItem(title: newsTitle, body: message, symbol: .transfer)
        
        return (true, message)
    }
    
    // MARK: - Transfer Teklifi Yönetimi (Kabul/Ret)

    func acceptTransferOffer(newsId: UUID) {
        guard var playerManager = self.playerManager else { return }
        
        guard let newsIndex = newsItems.firstIndex(where: { $0.id == newsId }),
              let playerID = newsItems[newsIndex].offerTargetPlayerID,
              let bidderID = newsItems[newsIndex].offerBidderTeamID,
              let offerAmount = newsItems[newsIndex].offerAmount else { return }
              
        guard var player = allPlayers.first(where: { $0.id == playerID }),
              let newTeam = teams.first(where: { $0.id == bidderID }) else { return }

        let commissionEarned = Int(Double(offerAmount) * (player.transferCommissionRate ?? 0.05))
        playerManager.cash += commissionEarned
        
        if let teamIndex = teams.firstIndex(where: { $0.id == newTeam.id }) {
            teams[teamIndex].budget -= offerAmount
        }
        
        player.teamID = newTeam.id
        player.isTransferListed = false
        let newSalary = Int(Double(player.salary) * 1.5)
        player.salary = newSalary
        
        if let playerIndex = allPlayers.firstIndex(where: { $0.id == playerID }) {
            allPlayers[playerIndex] = player
        }
        
        playerManager.reputation += 10
        self.playerManager = playerManager
        
        newsItems.remove(at: newsIndex)
        
        let successMessage = "\(player.name), \(offerAmount.formatted(.currency(code: "TRY"))) karşılığında \(newTeam.name) takımına transfer oldu. Bu transferden \(commissionEarned.formatted(.currency(code: "TRY"))) komisyon kazandınız! (+10 İtibar)"
        addNewsItem(title: "Transfer Başarılı!", body: successMessage, symbol: .success)
    }

    func rejectTransferOffer(newsId: UUID) {
        guard let newsIndex = newsItems.firstIndex(where: { $0.id == newsId }) else { return }
        newsItems.remove(at: newsIndex)
    }

    // MARK: - Oyun Başlangıcı
    
    func generateInitialData() {
        print("Oyun verileri oluşturuluyor...")
        self.playerManager = PlayerManager(cash: 500_000, reputation: 10, managedFootballerIDs: [], officeLevel: 1)
        
        let teamNames = ["Aslan Spor", "Kartal Gücü", "Kanarya FK", "Bordo Mavi", "Sivas Yiğidolar", "Göztepe", "Yeşil Timsahlar", "Anadolu Yıldızı", "Başkent United", "Ege FK", "Akdeniz Gücü", "Dağlar Spor"]
        for name in teamNames {
            let team = Team(id: UUID(), name: name, budget: Int.random(in: 20_000_000...80_000_000))
            self.teams.append(team)
            self.leagueTable.append(TeamStats(teamID: team.id))
            self.allPlayers.append(contentsOf: marketManager.createInitialSquad(for: team, currentYear: self.currentYear))
        }
        
        guard let currentOffice = officeLevels[1] else { return }
        self.scoutingOpportunities = marketManager.generateScoutingOpportunities(officeLevel: currentOffice, currentYear: self.currentYear)
        print("✅ Başarıyla oluşturuldu.")
    }
}
