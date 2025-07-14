// In: Features/Index/ViewModel/InboxViewModel.swift

import Foundation
import Combine

@MainActor
class InboxViewModel: ObservableObject {
    @Published var newsItems: [NewsItem] = []
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        
        gameManager.$newsItems
            .map { items in
                items.sorted { $0.year > $1.year || ($0.year == $1.year && $0.month > $1.month) }
            }
            .sink { [weak self] sortedItems in
                self?.newsItems = sortedItems
            }
            .store(in: &cancellables)
    }
    
    func markAsRead(item: NewsItem) {
        if item.newsType == .standard {
            if let index = gameManager.newsItems.firstIndex(where: { $0.id == item.id }) {
                gameManager.newsItems[index].isRead = true
            }
        }
    }
    
    // DÜZELTİLDİ: Teklifi kabul etme fonksiyonu
    func acceptOffer(newsItem: NewsItem) {
        // NewsItem'ın ID'si, TransferOffer'ın ID'si ile aynı.
        // Bu yüzden newsItem.id'yi doğrudan kullanabiliriz.
        gameManager.acceptTransferOffer(offerId: newsItem.id) // Hata düzeltildi: newsId -> offerId
    }
    
    // DÜZELTİLDİ: Teklifi reddetme fonksiyonu
    func rejectOffer(newsItem: NewsItem) {
        gameManager.rejectTransferOffer(offerId: newsItem.id) // Hata düzeltildi: newsId -> offerId
    }
}
