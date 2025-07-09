// In: Features/PlayerDetail/View/PlayerDetailView.swift

import SwiftUI

struct AbilityBarView: View {
    let label: String
    let value: Int
    let maxValue: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack { Text(label); Spacer(); Text("\(value)").fontWeight(.bold) }.font(.subheadline)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5).frame(width: geometry.size.width, height: 10).foregroundColor(Color.gray.opacity(0.3))
                    RoundedRectangle(cornerRadius: 5).frame(width: geometry.size.width * (CGFloat(value) / CGFloat(maxValue)), height: 10).foregroundColor(color)
                }
            }.frame(height: 10)
        }
    }
}

struct PlayerDetailView: View {
    
    @StateObject private var viewModel: PlayerDetailViewModel
    private var gameManager: GameManager
    
    init(footballer: Footballer, gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: PlayerDetailViewModel(footballer: footballer, gameManager: gameManager))
        self.gameManager = gameManager
    }
    
    var body: some View {
        List {
            Section(header: Text("Genel Bilgiler")) {
                if let training = viewModel.footballer.activeTraining,
                   let camp = gameManager.trainingCamps.first(where: { $0.id == training.campID }) {
                    HStack {
                        Image(systemName: "figure.run.circle.fill")
                            .foregroundColor(.orange)
                        Text(camp.name)
                        Spacer()
                        Text("\(training.monthsRemaining) ay kaldı")
                            .foregroundColor(.secondary)
                    }
                } else if let injury = viewModel.footballer.injury {
                    HStack {
                        Image(systemName: "bandage.fill")
                            .foregroundColor(.red)
                        Text("Sakat")
                        Spacer()
                        Text("\(injury.monthsRemaining) ay sahalardan uzak")
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack { Text("Mevcut Yetenek"); Spacer(); Text("\(viewModel.footballer.currentAbility)").foregroundColor(.secondary).fontWeight(.bold) }
                HStack { Text("İsim"); Spacer(); Text("\(viewModel.footballer.name) \(viewModel.footballer.surname)").foregroundColor(.secondary) }
                HStack { Text("Yaş"); Spacer(); Text("\(viewModel.footballer.age)").foregroundColor(.secondary) }
                HStack { Text("Mevki"); Spacer(); Text(viewModel.footballer.position.rawValue).foregroundColor(.secondary) }
                
                if let rating = viewModel.footballer.lastMatchRating {
                    HStack {
                        Text("Son Maç Notu")
                        Spacer()
                        Text(String(format: "%.1f", rating))
                            .fontWeight(.bold)
                            .foregroundColor(ratingColor(rating))
                    }
                }
                
                if viewModel.footballer.teamID != nil {
                    HStack {
                        Text("Sözleşme Bitişi")
                        Spacer()
                        Text(String(viewModel.footballer.contractExpiryYear))
                            .foregroundColor(contractStatusColor())
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Section(header: Text("Menajerlik Anlaşması")) {
                if let salaryCommission = viewModel.footballer.commissionRate {
                    HStack {
                        Text("Maaş Komisyonu")
                        Spacer()
                        Text("%\(salaryCommission * 100, specifier: "%.1f")")
                            .foregroundColor(.secondary)
                    }
                }
                if let transferCommission = viewModel.footballer.transferCommissionRate {
                    HStack {
                        Text("Sonraki Satıştan Pay")
                        Spacer()
                        Text("%\(transferCommission * 100, specifier: "%.1f")")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Değer")) {
                HStack {
                    Text("Piyasa Değeri")
                    Spacer()
                    Text(viewModel.footballer.marketValue, format: .currency(code: "TRY").presentation(.narrow)).foregroundColor(.secondary).fontWeight(.semibold)
                }
                
                if viewModel.footballer.teamID != nil && viewModel.footballer.salary > 0 {
                    HStack {
                        Text("Aylık Maaş")
                        Spacer()
                        Text(viewModel.footballer.salary, format: .currency(code: "TRY").presentation(.narrow)).foregroundColor(.secondary).fontWeight(.semibold)
                    }
                }
            }
            
            Section(header: Text("Yetenekler")) {
                AbilityBarView(label: "Hız", value: viewModel.footballer.pace, maxValue: 100, color: .cyan)
                AbilityBarView(label: "Şut", value: viewModel.footballer.shooting, maxValue: 100, color: .red)
                AbilityBarView(label: "Pas", value: viewModel.footballer.passing, maxValue: 100, color: .orange)
                AbilityBarView(label: "Defans", value: viewModel.footballer.defending, maxValue: 100, color: .blue)
                AbilityBarView(label: "Potansiyel Yetenek", value: viewModel.footballer.potentialAbility, maxValue: 100, color: .green)
            }
            
            Section(header: Text("Aksiyonlar")) {
                if viewModel.canSendToTraining {
                    NavigationLink(destination: TrainingView(footballer: viewModel.footballer, gameManager: gameManager)) {
                        Label("Antrenmana Gönder", systemImage: "figure.run.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                if viewModel.canFindClub {
                    NavigationLink(destination: FindClubView(footballer: viewModel.footballer, gameManager: gameManager)) {
                        Label("Oyuncuya Kulüp Bul", systemImage: "magnifyingglass.circle.fill")
                            .foregroundColor(.blue)
                    }.disabled(viewModel.footballer.activeTraining != nil || viewModel.footballer.injury != nil)
                }
                
                if viewModel.canRenewContract {
                    Button(action: { viewModel.renewContractButtonTapped() }) {
                        Label("Sözleşme Yenile", systemImage: "pencil.and.scribble")
                            .foregroundColor(.green)
                    }.disabled(viewModel.footballer.activeTraining != nil || viewModel.footballer.injury != nil)
                }
                
                if viewModel.canNegotiateTransfer {
                    Button(action: { viewModel.transferPlayerButtonTapped() }) {
                        Label("Transfer Pazarlığı Yap", systemImage: "arrow.right.arrow.left.circle.fill")
                            .foregroundColor(.purple)
                    }.disabled(viewModel.footballer.activeTraining != nil || viewModel.footballer.injury != nil)
                }
            }
        }
        .navigationTitle("Oyuncu Profili")
        .listStyle(InsetGroupedListStyle())
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("İşlem Sonucu"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Tamam")))
        }
    }
    
    private func contractStatusColor() -> Color {
        switch viewModel.footballer.getContractStatus(forCurrentYear: gameManager.currentYear) {
        case .active: return .secondary
        case .expiring: return .orange
        case .expired: return .red
        }
    }
    
    private func ratingColor(_ rating: Double) -> Color {
        switch rating {
        case 8.0...: return .green
        case 7.0..<8.0: return .blue
        case 6.0..<7.0: return .orange
        default: return .red
        }
    }
}

#Preview {
    NavigationView {
        PlayerDetailView(footballer: GameManager().allPlayers.first!, gameManager: GameManager())
    }
}
