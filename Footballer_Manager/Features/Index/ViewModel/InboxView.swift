// In: Features/Index/View/InboxView.swift

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel: InboxViewModel
    @State private var selectedNewsItem: NewsItem?
    
    init(gameManager: GameManager) {
        _viewModel = StateObject(wrappedValue: InboxViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        Group {
            if viewModel.newsItems.isEmpty {
                Text("Gelen kutunuz boş.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(viewModel.newsItems) { item in
                        // --- GÜNCELLENEN KISIM BAŞLIYOR ---
                        VStack(alignment: .leading, spacing: 10) {
                            // Haberin ana gövdesi
                            HStack(spacing: 15) {
                                Image(systemName: item.symbolName)
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .fontWeight(item.isRead ? .regular : .bold)
                                        .foregroundColor(.primary)
                                    Text(item.body) // Detaylı metin eklendi
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(3)
                                }
                                
                                Spacer()
                                
                                if !item.isRead {
                                    Circle()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            // Eğer haber bir transfer teklifiyse, butonları göster
                            if item.newsType == .transferOffer {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        viewModel.acceptOffer(newsItem: item)
                                    }) {
                                        Text("Kabul Et")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Listede buton stilini düzeltir
                                    
                                    Button(action: {
                                        viewModel.rejectOffer(newsItem: item)
                                    }) {
                                        Text("Reddet")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle()) // Tüm alanı tıklanabilir yapar
                        .onTapGesture {
                            // Sadece standart haberler için detay gösterme alert'i çalışır
                            if item.newsType == .standard {
                                selectedNewsItem = item
                                viewModel.markAsRead(item: item)
                            }
                        }
                        // --- GÜNCELLENEN KISIM BİTİYOR ---
                    }
                }
            }
        }
        .navigationTitle("Gelen Kutusu")
        .alert(item: $selectedNewsItem) { item in
            Alert(title: Text(item.title), message: Text(item.body), dismissButton: .default(Text("Tamam")))
        }
    }
}
