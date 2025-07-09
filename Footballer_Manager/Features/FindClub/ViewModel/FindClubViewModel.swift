//
//  FindClubViewModel.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 2.07.2025.
//


// In: Features/FindClub/ViewModel/FindClubViewModel.swift

import Foundation

@MainActor
class FindClubViewModel: ObservableObject {
    
    let footballer: Footballer
    @Published var potentialClubs: [Team] = []
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var signingResult: Bool? = nil
    
    private let gameManager: GameManager
    
    init(footballer: Footballer, gameManager: GameManager) {
        self.footballer = footballer
        self.gameManager = gameManager
        self.findPotentialClubs()
    }
    
    private func findPotentialClubs() {
        // Oyuncunun potansiyel maaşını hesaplayalım
        let expectedSalary = (footballer.currentAbility * 150) + (footballer.potentialAbility * 100)
        
        // Bütçesi bu maaşın en az 20 katı olan kulüpleri bul
        self.potentialClubs = gameManager.teams.filter { $0.budget > (expectedSalary * 20) }
    }
    
    func signWithClub(teamId: UUID) {
        let result = gameManager.signPlayerToClub(footballerId: footballer.id, teamId: teamId)
        self.alertMessage = result.message
        self.signingResult = result.success
        self.showAlert = true
    }
}