//
//  TrainingView.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 9.07.2025.
//


// In: Features/Training/View/TrainingView.swift

import SwiftUI

struct TrainingView: View {
    
    @StateObject private var viewModel: TrainingViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(footballer: Footballer, gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: TrainingViewModel(footballer: footballer, gameManager: gameManager))
    }
    
    var body: some View {
        List {
            Section(header: PlayerRowView(footballer: viewModel.footballer).padding(.bottom)) {
                ForEach(viewModel.availableCamps) { camp in
                    Button(action: {
                        viewModel.sendPlayerToCamp(campId: camp.id)
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: camp.iconName)
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                Text(camp.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Text(camp.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Spacer()
                                Text("Süre: \(camp.durationMonths) Ay")
                                Spacer()
                                Text("Maliyet: \(camp.cost, format: .currency(code: "TRY"))")
                                Spacer()
                            }
                            .font(.caption.bold())
                            .padding(.top, 5)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle("Antrenman Kampı Seç")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.trainingStarted ? "Antrenman Başladı" : "Hata"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("Tamam"), action: {
                    if viewModel.trainingStarted {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            )
        }
    }
}


#Preview {
    let gm = GameManager()
    // Önizleme için bir oyuncu alalım
    let player = gm.allPlayers.first ?? Footballer(id: UUID(), name: "Preview", surname: "Player", age: 18, position: .midfielder, pace: 70, shooting: 70, passing: 70, defending: 70, potentialAbility: 90, marketValue: 1000000, teamID: nil, contractExpiryYear: 0)
    
    return NavigationView {
        TrainingView(footballer: player, gameManager: gm)
    }
}