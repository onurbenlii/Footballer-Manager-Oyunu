// In: Data/Models/Models.swift

import Foundation

// YENİ: Haber türünü belirlemek için
enum NewsType: String, Codable {
    case standard
    case transferOffer
}

enum NewsSymbol: String, Codable {
    case transfer = "arrow.right.arrow.left.circle.fill"
    case contract = "pencil.and.scribble"
    case signature = "signature"
    case success = "checkmark.circle.fill"
    case failure = "xmark.circle.fill"
    case warning = "exclamationmark.triangle.fill"
    case upgrade = "arrow.up.circle.fill"
    case league = "sportscourt.fill"
    case injury = "bandage.fill"
    case training = "figure.run.circle.fill"
}

struct TrainingCamp: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let cost: Int
    let durationMonths: Int
    let targetAttribute: WritableKeyPath<Footballer, Int>
    let pointsGained: Int
    let iconName: String
}

struct PlayerTraining: Codable {
    let campID: UUID
    var monthsRemaining: Int
}

// DÜZELTİLDİ: NewsItem struct'ının tam ve hatasız hali
struct NewsItem: Identifiable, Codable, Hashable {
    let id: UUID
    var year: Int
    var month: Int
    let title: String
    let body: String
    let symbolName: String
    var isRead: Bool
    
    // --- ÖNCEKİ MESAJDAKİ GİBİ AMA ARTIK HATASIZ ---
    var newsType: NewsType = .standard
    // Sadece transfer teklifleri için doldurulacak alanlar
    var offerTargetPlayerID: UUID? = nil
    var offerBidderTeamID: UUID? = nil
    var offerAmount: Int? = nil
    // ------------------------------------

    // Basit haberleri oluşturmak için kolay bir init (Codable'ı bozmaz)
    init(year: Int, month: Int, title: String, body: String, symbol: NewsSymbol, isRead: Bool = false) {
        self.id = UUID()
        self.year = year
        self.month = month
        self.title = title
        self.body = body
        self.symbolName = symbol.rawValue
        self.isRead = isRead
    }
    
    // Transfer teklifi haberi oluşturmak için kolay bir init
    init(year: Int, month: Int, title: String, body: String, symbol: NewsSymbol, offerTargetPlayerID: UUID, offerBidderTeamID: UUID, offerAmount: Int) {
        self.id = UUID()
        self.year = year
        self.month = month
        self.title = title
        self.body = body
        self.symbolName = symbol.rawValue
        self.isRead = false
        self.newsType = .transferOffer
        self.offerTargetPlayerID = offerTargetPlayerID
        self.offerBidderTeamID = offerBidderTeamID
        self.offerAmount = offerAmount
    }
    
    var dateString: String {
        let monthNames = [1: "Oca", 2: "Şub", 3: "Mar", 4: "Nis", 5: "May", 6: "Haz", 7: "Tem", 8: "Ağu", 9: "Eyl", 10: "Eki", 11: "Kas", 12: "Ara"]
        return "\(monthNames[month] ?? "") \(year)"
    }
}


// DÜZELTME: id'nin 'let' olması ve varsayılan değer almaması için init'e gerek yok.
struct MatchResult: Identifiable, Codable {
    let id: UUID
    let homeTeamID: UUID
    let awayTeamID: UUID
    let homeScore: Int
    let awayScore: Int
    
    init(homeTeamID: UUID, awayTeamID: UUID, homeScore: Int, awayScore: Int) {
        self.id = UUID()
        self.homeTeamID = homeTeamID
        self.awayTeamID = awayTeamID
        self.homeScore = homeScore
        self.awayScore = awayScore
    }
}

struct TeamStats: Identifiable, Codable {
    let teamID: UUID
    var played: Int = 0
    var won: Int = 0
    var drawn: Int = 0
    var lost: Int = 0
    var goalsFor: Int = 0
    var goalsAgainst: Int = 0
    
    var goalDifference: Int { goalsFor - goalsAgainst }
    var points: Int { (won * 3) + drawn }
    
    var id: UUID { teamID }
}

enum ContractStatus {
    case active
    case expiring
    case expired
}

enum Position: String, Codable, CaseIterable {
    case goalkeeper = "Kaleci"
    case defender = "Defans"
    case midfielder = "Orta Saha"
    case forward = "Forvet"
}

struct Injury: Codable {
    var monthsRemaining: Int
}

struct Footballer: Identifiable, Codable {
    let id: UUID
    var name: String
    var surname: String
    var age: Int
    var position: Position
    var pace: Int
    var shooting: Int
    var passing: Int
    var defending: Int
    let potentialAbility: Int
    var marketValue: Int
    var teamID: UUID?
    var contractExpiryYear: Int
    var salary: Int = 0
    var isManagedByPlayer: Bool = false
    var commissionRate: Double? = nil
    var transferCommissionRate: Double? = nil
    var lastMatchRating: Double?
    var injury: Injury? = nil
    var activeTraining: PlayerTraining? = nil
    var isTransferListed: Bool = false
    
    var currentAbility: Int {
        switch position {
        case .goalkeeper: return Int(Double(defending) * 0.7 + Double(passing) * 0.2 + Double(pace) * 0.1)
        case .defender: return Int(Double(defending) * 0.7 + Double(passing) * 0.15 + Double(pace) * 0.15)
        case .midfielder: return Int(Double(passing) * 0.6 + Double(shooting) * 0.15 + Double(defending) * 0.15 + Double(pace) * 0.1)
        case .forward: return Int(Double(shooting) * 0.7 + Double(pace) * 0.2 + Double(passing) * 0.1)
        }
    }
    
    func getContractStatus(forCurrentYear year: Int) -> ContractStatus {
        if teamID == nil { return .expired }
        if self.contractExpiryYear < year { return .expired }
        else if self.contractExpiryYear == year { return .expiring }
        else { return .active }
    }
}

struct Team: Identifiable, Codable {
    let id: UUID
    var name: String
    var budget: Int
}

struct PlayerManager: Codable {
    var cash: Int
    var reputation: Int
    var managedFootballerIDs: [UUID]
    var officeLevel: Int = 1
}
