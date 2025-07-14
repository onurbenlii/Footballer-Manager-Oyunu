// In: Features/TransferCenter/View/TransferNegotiationView.swift

import SwiftUI

struct TransferNegotiationView: View {
    
    @StateObject private var viewModel: TransferNegotiationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(offer: TransferOffer, gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: TransferNegotiationViewModel(offer: offer, gameManager: gameManager))
    }
    
    var body: some View {
        VStack {
            VStack {
                PlayerRowView(footballer: viewModel.player)
                HStack {
                    Text("Teklif Yapan Kulüp:")
                        .font(.headline)
                    Text(viewModel.offeringTeam.name)
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Divider().padding(.horizontal)
            
            Form {
                Section(header: Text("Teklif Detayları")) {
                    // Bonservis Slider'ı
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Karşı Bonservis Teklifiniz: \(Int(viewModel.counterOfferAmount).formatted(.currency(code: "TRY")))")
                        Slider(value: $viewModel.counterOfferAmount,
                               in: Double(viewModel.offer.amount) * 0.9...Double(viewModel.offer.amount) * 2.5,
                               step: 50000)
                        Text("İlk Teklif: \(viewModel.offer.amount.formatted(.currency(code: "TRY")))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                    
                    // --- YENİ EKLENEN MAAŞ SLIDER'I ---
                    VStack(alignment: .leading, spacing: 5) {
                        Text("İstediğiniz Maaş (Aylık): \(Int(viewModel.counterOfferSalary).formatted(.currency(code: "TRY")))")
                        Slider(value: $viewModel.counterOfferSalary,
                               in: Double(viewModel.offer.proposedSalary) * 0.9...Double(viewModel.offer.proposedSalary) * 2.0, // Maaşta en fazla %100 artış isteyelim
                               step: 1000)
                        Text("İlk Teklif: \(viewModel.offer.proposedSalary.formatted(.currency(code: "TRY")))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                    // ------------------------------------
                }
                
                Section(header: Text("Kabul Edilme Olasılığı")) {
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
            
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.makeCounterOffer()
                }) {
                    Text("Karşı Teklif Yap")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    viewModel.acceptOffer()
                }) {
                    Text("Kabul Et")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Pazarlık Masası")
        .background(Color(.systemGroupedBackground))
        .alert(isPresented: $viewModel.negotiationEnded) {
            Alert(title: Text("Pazarlık Bitti"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Tamam"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }
    
    private func successChanceColor() -> Color {
        switch viewModel.successChance {
        case 0...30: return .red
        case 31...60: return .orange
        case 61...100: return .green
        default: return .gray
        }
    }
}
