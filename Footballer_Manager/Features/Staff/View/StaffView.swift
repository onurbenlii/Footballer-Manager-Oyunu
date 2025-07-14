//
//  StaffView.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 14.07.2025.
//


// In: Features/Staff/View/StaffView.swift

import SwiftUI

struct StaffView: View {
    
    @StateObject private var viewModel: StaffViewModel
    
    init(gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: StaffViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        List {
            // Mevcut Personel Bölümü
            Section(header: Text("Mevcut Personel")) {
                if viewModel.hiredStaff.isEmpty {
                    Text("Henüz işe alınmış personeliniz yok.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.hiredStaff) { staff in
                        StaffRow(staff: staff, isHired: true)
                    }
                }
            }
            
            // Personel Piyasası Bölümü
            Section(header: Text("İşe Alınabilir Adaylar")) {
                if viewModel.availableCandidates.isEmpty {
                    Text("Piyasada uygun aday bulunmuyor.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.availableCandidates) { candidate in
                        HStack {
                            StaffRow(staff: candidate.staff, isHired: false)
                            Spacer()
                            Button(action: {
                                viewModel.hireCandidate(candidate)
                            }) {
                                Text("İşe Al")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .navigationTitle("Personel Yönetimi")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("İşlem Sonucu"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Tamam")))
        }
    }
}

// Personel satırını göstermek için yardımcı bir View
struct StaffRow: View {
    let staff: StaffMember
    let isHired: Bool
    
    private var iconName: String {
        switch staff.role {
        case .scout: return "binoculars.fill"
        case .commercial: return "briefcase.fill"
        case .coach: return "figure.run"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .frame(width: 35)
                .foregroundColor(isHired ? .green : .secondary)
            
            VStack(alignment: .leading) {
                Text(staff.name)
                    .font(.headline)
                Text(staff.role.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Yetenek: \(staff.skillLevel)")
                    .font(.headline)
                Text("Maaş: \(staff.weeklyWage, format: .currency(code: "TRY")) / Hafta")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}


#Preview {
    NavigationView {
        StaffView(gameManager: GameManager())
    }
}