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
        
        // GameManager'deki haber listesini dinle ve her zaman en yeniden eskiye doğru sırala
        gameManager.$newsItems
            .map { items in
                items.sorted { $0.year > $1.year || ($0.year == $1.year && $0.month > $1.month) }
            }
            .sink { [weak self] sortedItems in
                self?.newsItems = sortedItems
            }
            .store(in: &cancellables)
    }
    
    // Bir haberi okundu olarak işaretle
    func markAsRead(item: NewsItem) {
        // Sadece standart haberler okundu olarak işaretlenir, teklifler silinir.
        if item.newsType == .standard {
            if let index = gameManager.newsItems.firstIndex(where: { $0.id == item.id }) {
                gameManager.newsItems[index].isRead = true
            }
        }
    }
    
    // YENİ FONKSİYON 1: Teklifi Kabul Et
    func acceptOffer(newsItem: NewsItem) {
        gameManager.acceptTransferOffer(newsId: newsItem.id)
    }
    
    // YENİ FONKSİYON 2: Teklifi Reddet
    func rejectOffer(newsItem: NewsItem) {
        gameManager.rejectTransferOffer(newsId: newsItem.id)
    }
}
