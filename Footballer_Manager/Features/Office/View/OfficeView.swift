//
//  OfficeInfoRow.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 3.07.2025.
//


// In: Features/Office/View/OfficeView.swift

import SwiftUI

struct OfficeInfoRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundColor(iconColor)
                .frame(width: 30)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
}


struct OfficeView: View {
    @StateObject private var viewModel: OfficeViewModel
    
    init(gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: OfficeViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        List {
            Section(header: Text("Mevcut Ofis Durumu")) {
                OfficeInfoRow(iconName: "building.2.fill", iconColor: .brown, title: "Ofis Seviyesi", value: "\(viewModel.currentOfficeLevel)")
                
                OfficeInfoRow(iconName: "person.3.fill", iconColor: .blue, title: "Oyuncu Kapasitesi", value: "\(viewModel.currentPlayerCapacity) / \(viewModel.maxPlayerCapacity)")
                
                OfficeInfoRow(iconName: "binoculars.fill", iconColor: .purple, title: "Kaşif Kalitesi", value: viewModel.scoutQualityDescription)
            }
            
            Section(header: Text("Yükseltme")) {
                VStack(spacing: 15) {
                    OfficeInfoRow(iconName: "arrow.up.building.fill", iconColor: .green, title: "Sonraki Seviye Maliyeti", value: viewModel.nextLevelUpgradeCost)
                    
                    Button(action: {
                        viewModel.upgradeButtonTapped()
                    }) {
                        Text("Ofisi Yükselt")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canUpgrade ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.canUpgrade)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Ofisim")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("İşlem Sonucu"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Tamam")))
        }
    }
}

#Preview {
    let gm = GameManager()
    return NavigationView {
        OfficeView(gameManager: gm)
    }
}