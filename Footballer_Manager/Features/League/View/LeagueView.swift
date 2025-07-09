//
//  LeagueView.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 3.07.2025.
//


// In: Features/League/View/LeagueView.swift

import SwiftUI

struct LeagueView: View {
    
    @StateObject private var viewModel: LeagueViewModel
    
    init(gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: LeagueViewModel(gameManager: gameManager))
    }
    
    // Puan durumu başlıkları için stil
    private let headerFont = Font.system(.caption, weight: .bold)
    
    var body: some View {
        ScrollView {
            VStack {
                // Sonuçlar Bölümü
                Section(header: Text("Son Haftanın Sonuçları").font(.headline).padding()) {
                    if viewModel.recentResults.isEmpty {
                        Text("Henüz maç oynanmadı.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        VStack {
                            ForEach(viewModel.recentResults) { result in
                                HStack {
                                    Text(viewModel.getTeamName(from: result.homeTeamID))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    Text("\(result.homeScore) - \(result.awayScore)")
                                        .font(.headline.bold())
                                        .padding(.horizontal)
                                    Text(viewModel.getTeamName(from: result.awayTeamID))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                
                // Puan Durumu Bölümü
                Section(header: Text("Puan Durumu").font(.headline).padding()) {
                    VStack {
                        // Başlık Satırı
                        HStack {
                            Text("#").frame(width: 30)
                            Text("Takım").frame(maxWidth: .infinity, alignment: .leading)
                            Text("O").frame(width: 30)
                            Text("G").frame(width: 30)
                            Text("B").frame(width: 30)
                            Text("M").frame(width: 30)
                            Text("AV").frame(width: 35)
                            Text("P").frame(width: 35)
                        }
                        .font(headerFont)
                        .padding(.horizontal)
                        
                        Divider()
                        
                        // Takım Satırları
                        ForEach(Array(viewModel.leagueTable.enumerated()), id: \.element.id) { index, stats in
                            HStack {
                                Text("\(index + 1)").frame(width: 30)
                                Text(viewModel.getTeamName(from: stats.teamID)).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(stats.played)").frame(width: 30)
                                Text("\(stats.won)").frame(width: 30)
                                Text("\(stats.drawn)").frame(width: 30)
                                Text("\(stats.lost)").frame(width: 30)
                                Text("\(stats.goalDifference)").frame(width: 35)
                                Text("\(stats.points)").fontWeight(.bold).frame(width: 35)
                            }
                            .font(.subheadline)
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                            .background((index + 1) % 2 == 0 ? Color.clear : Color(.systemGray6))
                        }
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Lig Fikstürü")
    }
}


#Preview {
    let gm = GameManager()
    return NavigationView {
        LeagueView(gameManager: gm)
    }
}