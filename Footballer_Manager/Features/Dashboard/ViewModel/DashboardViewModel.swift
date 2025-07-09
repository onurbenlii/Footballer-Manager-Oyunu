// In: Features/Dashboard/ViewModel/DashboardViewModel.swift

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    
    @Published var playerCash: String = "Yükleniyor..."
    @Published var managedPlayerCount: Int = 0
    @Published var currentDateString: String = "Yükleniyor..."
    @Published var playerReputation: Int = 0
    @Published var hasUnreadNews: Bool = false // YENİ
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    private let monthNames = [1: "Ocak", 2: "Şubat", 3: "Mart", 4: "Nisan", 5: "Mayıs", 6: "Haziran", 7: "Temmuz", 8: "Ağustos", 9: "Eylül", 10: "Ekim", 11: "Kasım", 12: "Aralık"]
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        subscribeToGameManager()
        subscribeToDateChanges()
        subscribeToNewsItems() // YENİ
    }
    
    func advanceMonthButtonTapped() {
        let result = gameManager.advanceOneMonth()
        self.alertMessage = result.message
        self.showAlert = true
    }
    
    private func subscribeToGameManager() {
        gameManager.$playerManager
            .compactMap { $0 }
            .sink { [weak self] manager in
                self?.formatPlayerData(for: manager)
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToDateChanges() {
        gameManager.$currentMonth
            .combineLatest(gameManager.$currentYear)
            .sink { [weak self] (month, year) in
                guard let self = self else { return }
                let monthName = self.monthNames[month] ?? ""
                self.currentDateString = "\(monthName) \(year)"
            }
            .store(in: &cancellables)
    }
    
    // YENİ FONKSİYON
    private func subscribeToNewsItems() {
        gameManager.$newsItems
            .map { news -> Bool in
                // Okunmamış haber var mı?
                news.contains { !$0.isRead }
            }
            .assign(to: \.hasUnreadNews, on: self)
            .store(in: &cancellables)
    }
    
    private func formatPlayerData(for manager: PlayerManager) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₺"
        formatter.maximumFractionDigits = 0
        
        if let formattedCash = formatter.string(from: NSNumber(value: manager.cash)) {
            self.playerCash = formattedCash
        }
        
        self.managedPlayerCount = manager.managedFootballerIDs.count
        self.playerReputation = manager.reputation
    }
}
