//
//  PlayerRowView.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 1.07.2025.
//


// In: Shared/Components/PlayerRowView.swift

import SwiftUI

struct PlayerRowView: View {
    let footballer: Footballer
    
    var body: some View {
        HStack {
            // Pozisyon ikonu ve renkleri
            Image(systemName: positionIcon())
                .font(.title2)
                .foregroundColor(positionColor())
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(footballer.name) \(footballer.surname)")
                    .font(.headline)
                Text("Yaş: \(footballer.age) | Mevki: \(footballer.position.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Yetenek göstergesi
            Text("\(footballer.currentAbility)")
                .font(.title3.bold())
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
        .padding(.vertical, 8)
    }
    
    // Mevkiye göre ikon döndüren yardımcı fonksiyon
        private func positionIcon() -> String {
            switch footballer.position {
            case .goalkeeper: return "hand.raised.fill" // Bu satırı değiştirdik
            case .defender: return "shield.lefthalf.filled"
            case .midfielder: return "square.grid.3x3.middle.filled"
            case .forward: return "figure.soccer"
            }
        }
    
    // Mevkiye göre renk döndüren yardımcı fonksiyon
    private func positionColor() -> Color {
        switch footballer.position {
        case .goalkeeper: return .orange
        case .defender: return .blue
        case .midfielder: return .green
        case .forward: return .red
        }
    }
}
