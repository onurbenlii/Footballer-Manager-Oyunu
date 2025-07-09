//
//  NegotiationView.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 2.07.2025.
//


// In: Features/Negotiation/View/NegotiationView.swift

import SwiftUI

struct NegotiationView: View {
    
    @StateObject private var viewModel: NegotiationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(footballer: Footballer, gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: NegotiationViewModel(footballer: footballer, gameManager: gameManager))
    }
    
    var body: some View {
        VStack {
            // Oyuncu Bilgi Kartı
            PlayerRowView(footballer: viewModel.footballer)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            
            Divider().padding()
            
            // Pazarlık Alanı
            Form {
                Section(header: Text("Teklif Detayları")) {
                    // Maaş Komisyonu Slider'ı
                    VStack(alignment: .leading) {
                        Text("Maaş Komisyonu: %\(viewModel.salaryCommission, specifier: "%.1f")")
                        Slider(value: $viewModel.salaryCommission, in: 1.0...15.0, step: 0.5)
                    }
                    .padding(.vertical, 5)
                    
                    // Bonservis Komisyonu Slider'ı
                    VStack(alignment: .leading) {
                        Text("Sonraki Satıştan Pay: %\(viewModel.transferCommission, specifier: "%.1f")")
                        Slider(value: $viewModel.transferCommission, in: 0.0...30.0, step: 1.0)
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("Başarı Olasılığı")) {
                    HStack {
                        Spacer()
                        Text("%\(viewModel.successChance)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(successChanceColor())
                        Spacer()
                    }
                    .padding()
                }
            }
            
            // Teklif Butonu
            Button(action: {
                viewModel.makeOffer()
            }) {
                Text("Teklif Yap")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Pazarlık Masası")
        .background(Color(.systemGroupedBackground))
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.negotiationResult == true ? "Anlaşma Sağlandı!" : "Teklif Reddedildi"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("Tamam"), action: {
                    // Anlaşma başarılıysa bu ekrandan geri git
                    if viewModel.negotiationResult == true {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            )
        }
    }
    
    // Başarı şansına göre renk döndüren yardımcı fonksiyon
    private func successChanceColor() -> Color {
        switch viewModel.successChance {
        case 0...30:
            return .red
        case 31...60:
            return .orange
        case 61...100:
            return .green
        default:
            return .gray
        }
    }
}