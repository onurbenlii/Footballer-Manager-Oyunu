//
//  FindClubView.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 2.07.2025.
//


// In: Features/FindClub/View/FindClubView.swift

import SwiftUI

struct FindClubView: View {
    @StateObject private var viewModel: FindClubViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(footballer: Footballer, gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: FindClubViewModel(footballer: footballer, gameManager: gameManager))
    }
    
    var body: some View {
        VStack {
            PlayerRowView(footballer: viewModel.footballer)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            
            Divider()
            
            if viewModel.potentialClubs.isEmpty {
                Spacer()
                Text("Bu oyuncunun maaş beklentisini karşılayabilecek bir kulüp bulunamadı.\nOyuncu geliştikçe tekrar deneyin.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                List {
                    Section(header: Text("İlgilenen Kulüpler")) {
                        ForEach(viewModel.potentialClubs) { team in
                            Button(action: {
                                viewModel.signWithClub(teamId: team.id)
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(team.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("Bütçe: \(team.budget.formatted(.currency(code: "TRY")))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Kulüp Bul")
        .background(Color(.systemGroupedBackground))
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.signingResult == true ? "İmza Atıldı!" : "Anlaşma Sağlanamadı"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("Tamam"), action: {
                    if viewModel.signingResult == true {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            )
        }
    }
}