// In: Core/Manager/PlayerLifecycleManager.swift

import Foundation

class PlayerLifecycleManager {
    
    // Bir ayın sonunda oyuncularla ilgili tüm değişiklikleri ve haberleri bir arada döndürmek için kullanılır.
    struct MonthlyUpdateResult {
        let updatedPlayers: [Footballer]
        let newsItems: [NewsItem]
    }
    
    // Oyuncuların aylık güncellemelerini işleyen ana fonksiyon
    func processMonthlyUpdates(for players: [Footballer], trainingCamps: [TrainingCamp], currentYear: Int, currentMonth: Int) -> MonthlyUpdateResult {
        var updatedPlayers = players
        var news: [NewsItem] = []
        
        for i in 0..<updatedPlayers.count {
            var player = updatedPlayers[i]
            
            // 1. Antrenman Süreci
            if var training = player.activeTraining {
                training.monthsRemaining -= 1
                if training.monthsRemaining <= 0 {
                    if let camp = trainingCamps.first(where: { $0.id == training.campID }) {
                        player[keyPath: camp.targetAttribute] += camp.pointsGained
                        let newsBody = "\(player.name) \(player.surname), \(camp.name) kampını başarıyla tamamladı ve yeteneklerini geliştirdi!"
                        // DÜZELTME: Doğru init metodu kullanıldı.
                        news.append(NewsItem(year: currentYear, month: currentMonth, title: "Antrenman Tamamlandı", body: newsBody, symbol: .success))
                    }
                    player.activeTraining = nil
                } else {
                    player.activeTraining = training
                }
                updatedPlayers[i] = player
                continue // Antrenmandaki oyuncu sakatlanamaz
            }
            
            // 2. Sakatlık Süreci
            if var injury = player.injury {
                injury.monthsRemaining -= 1
                if injury.monthsRemaining <= 0 {
                    player.injury = nil
                    let newsBody = "\(player.name) \(player.surname) sakatlığını atlattı ve sahalara geri dönmeye hazır."
                    // DÜZELTME: Doğru init metodu kullanıldı.
                    news.append(NewsItem(year: currentYear, month: currentMonth, title: "Sakatlıktan Döndü", body: newsBody, symbol: .success))
                } else {
                    player.injury = injury
                }
                updatedPlayers[i] = player
                continue // Sakat oyuncu bu ay tekrar sakatlanamaz
            }
            
            // 3. Yeni Sakatlık İhtimali
            if Int.random(in: 1...1000) <= 15 {
                let injuryDuration = Int.random(in: 1...6)
                player.injury = Injury(monthsRemaining: injuryDuration)
                updatedPlayers[i] = player
                let newsBody = "\(player.name) antrenmanda sakatlandı ve sahalardan \(injuryDuration) ay uzak kalacak."
                // DÜZELTME: Doğru init metodu kullanıldı.
                news.append(NewsItem(year: currentYear, month: currentMonth, title: "Sakatlık Şoku!", body: newsBody, symbol: .injury))
            }
        }
        
        return MonthlyUpdateResult(updatedPlayers: updatedPlayers, newsItems: news)
    }
    
    // Oyuncuların yeteneklerini ve piyasa değerlerini günceller
    func updateAttributes(for players: [Footballer]) -> [Footballer] {
        var updatedPlayers = players
        for i in 0..<updatedPlayers.count {
            var player = updatedPlayers[i]
            let peakAge = 28
            let potentialGap = player.potentialAbility - player.currentAbility
            if player.age < peakAge && potentialGap > 0 {
                if Double.random(in: 0...1) < (0.5 + (Double(potentialGap) / 50.0)) {
                    let attributeToImprove = Int.random(in: 0...3)
                    switch attributeToImprove {
                    case 0: player.pace = min(player.potentialAbility, player.pace + 1)
                    case 1: player.shooting = min(player.potentialAbility, player.shooting + 1)
                    case 2: player.passing = min(player.potentialAbility, player.passing + 1)
                    case 3: player.defending = min(player.potentialAbility, player.defending + 1)
                    default: break
                    }
                }
            } else if player.age > peakAge {
                if Double.random(in: 0...1) < (0.3 + (Double(player.age - peakAge) / 20.0)) {
                    let attributeToDecline = Int.random(in: 0...3)
                    switch attributeToDecline {
                    case 0: player.pace = max(20, player.pace - 1)
                    case 1: player.shooting = max(20, player.shooting - 1)
                    case 2: player.passing = max(20, player.passing - 1)
                    case 3: player.defending = max(20, player.defending - 1)
                    default: break
                    }
                }
            }
            let baseValue = (player.currentAbility * 10000) + (player.potentialAbility * 5000)
            let ageFactor = player.age > 29 ? (player.age - 29) * 25000 : 0
            player.marketValue = max(5000, baseValue - ageFactor)
            updatedPlayers[i] = player
        }
        return updatedPlayers
    }
    
    // Tüm oyuncuların yaşını bir artırır
    func ageAllPlayers(for players: [Footballer]) -> [Footballer] {
        var updatedPlayers = players
        for i in 0..<updatedPlayers.count {
            updatedPlayers[i].age += 1
        }
        return updatedPlayers
    }
}
