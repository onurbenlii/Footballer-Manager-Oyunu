//
//  StaffViewModel.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 14.07.2025.
//


// In: Features/Staff/ViewModel/StaffViewModel.swift

import Foundation
import Combine

@MainActor
class StaffViewModel: ObservableObject {
    
    @Published var hiredStaff: [StaffMember] = []
    @Published var availableCandidates: [StaffCandidate] = []
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        
        // GameManager'daki değişiklikleri dinle
        subscribeToPlayerManager()
        subscribeToStaffMarket()
    }
    
    private func subscribeToPlayerManager() {
        gameManager.$playerManager
            .compactMap { $0 }
            .map { $0.hiredStaff }
            .sink { [weak self] staff in
                self?.hiredStaff = staff
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToStaffMarket() {
        gameManager.$staffMarket
            .sink { [weak self] market in
                self?.availableCandidates = market
            }
            .store(in: &cancellables)
    }
    
    // Bir adayı işe alma fonksiyonunu çağır
    func hireCandidate(_ candidate: StaffCandidate) {
        let result = gameManager.hireStaffMember(candidateId: candidate.id)
        self.alertMessage = result.message
        self.showAlert = true
    }
    
    // Belirli bir roldeki personeli bulmak için yardımcı fonksiyon
    func getStaff(for role: StaffRole) -> StaffMember? {
        return hiredStaff.first { $0.role == role }
    }
}