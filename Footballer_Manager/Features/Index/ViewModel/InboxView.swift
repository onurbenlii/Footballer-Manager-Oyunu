// In: Features/Inbox/View/InboxView.swift

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
                List(viewModel.newsItems) { item in
                    Button(action: {
                        selectedNewsItem = item
                        viewModel.markAsRead(item: item)
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: item.symbolName)
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .fontWeight(item.isRead ? .regular : .bold)
                                    .foregroundColor(.primary)
                                Text(item.dateString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if !item.isRead {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
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

#Preview {
    // DÜZELTME: Kurulum mantığı kaldırıldı ve doğrudan bir GameManager örneği kullanıldı.
    // Önizleme verilerini doğrudan GameManager'ın init'inde veya ayrı bir mock servisinde yönetmek daha iyi bir pratiktir.
    // Şimdilik boş bir gelen kutusu ile önizleme yapılacak.
    NavigationView {
        InboxView(gameManager: GameManager())
    }
}
