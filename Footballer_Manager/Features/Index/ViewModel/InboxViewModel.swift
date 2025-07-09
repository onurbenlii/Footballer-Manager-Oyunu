//
//  InboxViewModel.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 2.07.2025.
//


// In: Features/Inbox/ViewModel/InboxViewModel.swift

import Foundation
import Combine

@MainActor
class InboxViewModel: ObservableObject {
    @Published var newsItems: [NewsItem] = []
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        
        // GameManager'deki haber listesini dinle
        gameManager.$newsItems
            .sink { [weak self] items in
                self?.newsItems = items
            }
            .store(in: &cancellables)
    }
    
    // Bir haberi okundu olarak işaretle
    func markAsRead(item: NewsItem) {
        // GameManager'daki ana listede ilgili haberi bul ve durumunu değiştir
        if let index = gameManager.newsItems.firstIndex(where: { $0.id == item.id }) {
            gameManager.newsItems[index].isRead = true
        }
    }
}