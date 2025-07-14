// In: Data/Models/Models.swift

import Foundation

// --- Personel Yönetimi için Yeni Yapılar ---
enum StaffRole: String, Codable, CaseIterable {
    case scout = "Gözlemci"
    case commercial = "Ticari Müdür"
    case coach = "Antrenör"
}

// Ofis seviyelerinin özelliklerini tutacak struct
struct OfficeLevel {
    let level: Int
    let maxPlayers: Int
    let upgradeCost: Int?
    let minScoutingPotential: Int
    let maxScoutingPotential: Int
}

struct StaffMember: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let role: StaffRole
    let skillLevel: Int
    let weeklyWage: Int
}

struct StaffCandidate: Identifiable, Codable, Hashable {
    let id: UUID
    let staff: StaffMember
}
// ------------------------------------------

// --- Transfer Pazarlığı için Yeni Yapılar ---
enum OfferStatus: String, Codable {
    case pending = "Beklemede"
    case negotiating = "Pazarlıkta"
    case accepted = "Kabul Edildi"
    case rejected = "Reddedildi"
}

struct TransferOffer: Identifiable, Codable, Hashable {
    let id: UUID
    let playerID: UUID
    let offeringTeamID: UUID
    var amount: Int
    var proposedSalary: Int
    var status: OfferStatus

    init(playerID: UUID, offeringTeamID: UUID, amount: Int, proposedSalary: Int) {
        self.id = UUID()
        self.playerID = playerID
        self.offeringTeamID = offeringTeamID
        self.amount = amount
        self.proposedSalary = proposedSalary
        self.status = .pending
    }
}
// ------------------------------------------

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

struct NewsItem: Identifiable, Codable, Hashable {
    let id: UUID
    var year: Int
    var month: Int
    let title: String
    let body: String
    let symbolName: String
    var isRead: Bool
    var newsType: NewsType = .standard
    var offerTargetPlayerID: UUID? = nil
    var offerBidderTeamID: UUID? = nil
    var offerAmount: Int? = nil

    init(year: Int, month: Int, title: String, body: String, symbol: NewsSymbol, isRead: Bool = false) {
        self.id = UUID()
        self.year = year
        self.month = month
        self.title = title
        self.body = body
        self.symbolName = symbol.rawValue
        self.isRead = isRead
    }
    
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
    var prestige: Int
}

struct PlayerManager: Codable {
    var cash: Int
    var reputation: Int
    var managedFootballerIDs: [UUID]
    var officeLevel: Int = 1
    var hiredStaff: [StaffMember] = []
}

// Oyunu kaydetmek için kullanılan ana yapı
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
    var activeOffers: [TransferOffer]
    var staffMarket: [StaffCandidate] = []
}
