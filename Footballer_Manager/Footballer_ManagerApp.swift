// In: Application/Footballer_ManagerApp.swift

import SwiftUI

@main
struct Footballer_ManagerApp: App {
    
    @StateObject private var gameManager = GameManager()
    
    // YENİ: Uygulamanın durumunu (aktif, pasif, arka plan) takip etmek için
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            DashboardView(gameManager: gameManager)
        }
        // GÜNCELLENDİ: scenePhase değişikliğini dinle
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .inactive {
                print("Uygulama arka plana alınıyor, oyun kaydediliyor...")
                gameManager.saveGame()
            }
        }
    }
}
