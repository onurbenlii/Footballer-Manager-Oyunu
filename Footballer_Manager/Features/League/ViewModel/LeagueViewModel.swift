//
//  LeagueViewModel.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 3.07.2025.
//


// In: Features/League/ViewModel/LeagueViewModel.swift

import Foundation
import Combine

@MainActor
class LeagueViewModel: ObservableObject {
    
    @Published var leagueTable: [TeamStats] = []
    @Published var recentResults: [MatchResult] = []
    
    // Takım ID'sini isme çevirmek için bir yardımcı
    private var teamNames: [UUID: String] = [:]
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        
        // Takım ID-İsim eşleşmesini oluştur
        for team in gameManager.teams {
            self.teamNames[team.id] = team.name
        }
        
        // Puan durumu değişikliklerini dinle
        gameManager.$leagueTable
            .sink { [weak self] table in
                // Puan durumunu sırala: önce puan, sonra averaj
                self?.leagueTable = table.sorted {
                    if $0.points != $1.points {
                        return $0.points > $1.points
                    }
                    return $0.goalDifference > $1.goalDifference
                }
            }
            .store(in: &cancellables)
        
        // Maç sonucu değişikliklerini dinle
        gameManager.$recentResults
            .sink { [weak self] results in
                self?.recentResults = results
            }
            .store(in: &cancellables)
    }
    
    // Verilen takım ID'si için takım adını döndür
    func getTeamName(from teamId: UUID) -> String {
        return teamNames[teamId] ?? "Bilinmeyen Takım"
    }
}