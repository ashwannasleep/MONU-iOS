import Foundation
import SwiftUI
import Amplify

// MARK: - Quote Store
final class QuoteStore: ObservableObject {
    @Published var favorites: Set<UUID> = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let favoritesKey = "monu.quote.favorites.v1"
    
    init() {
        loadFavorites() // Load from UserDefaults as fallback
        loadFromAmplify() // Try to load from Amplify
    }
    
    // MARK: - Favorites Management
    func isFavorite(_ quote: Quote) -> Bool {
        favorites.contains(quote.id)
    }
    
    func toggleFavorite(_ quote: Quote) {
        if favorites.contains(quote.id) {
            favorites.remove(quote.id)
            print("💔 Removed quote from favorites: \(quote.text)")
        } else {
            favorites.insert(quote.id)
            print("❤️ Added quote to favorites: \(quote.text)")
        }
        
        // Save to both Amplify and UserDefaults for redundancy
        saveToAmplify(quote: quote, isFavorite: favorites.contains(quote.id))
        saveFavorites()
        print("💾 Saved favorites. Total favorites: \(favorites.count)")
    }
    
    func getFavoriteQuotes() -> [Quote] {
        return QuotePool.all.filter { favorites.contains($0.id) }
    }
    
    // MARK: - Amplify Persistence
    private func saveToAmplify(quote: Quote, isFavorite: Bool) {
        Task {
            do {
                let amplifyQuote = AmplifyQuote(
                    id: quote.id.uuidString,
                    text: quote.text,
                    author: quote.author,
                    category: quote.category.rawValue, // Convert enum to string
                    isFavorite: isFavorite,
                    owner: nil
                )
                
                try await Amplify.DataStore.save(amplifyQuote)
                print("✅ Saved quote to Amplify: \(quote.text)")
            } catch {
                print("❌ Failed to save quote to Amplify: \(error)")
                await MainActor.run {
                    self.error = "Failed to save favorite: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func loadFromAmplify() {
        Task {
            do {
                let quotes = try await Amplify.DataStore.query(AmplifyQuote.self)
                let favoriteQuotes = quotes.filter { $0.isFavorite }
                
                await MainActor.run {
                    self.favorites = Set(favoriteQuotes.compactMap { UUID(uuidString: $0.id) })
                    print("📱 Loaded \(self.favorites.count) favorites from Amplify")
                }
            } catch {
                print("❌ Failed to load quotes from Amplify: \(error)")
                // Fallback to UserDefaults
                await MainActor.run {
                    self.loadFavorites()
                }
            }
        }
    }
    
    // MARK: - UserDefaults Fallback
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let decodedFavorites = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
            favorites = []
            print("📱 No saved favorites found, starting with empty set")
            return
        }
        favorites = decodedFavorites
        print("📱 Loaded \(favorites.count) favorites from UserDefaults")
    }
    
    private func saveFavorites() {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        UserDefaults.standard.set(data, forKey: favoritesKey)
    }
}
// MARK: - Amplify Quote Model
struct AmplifyQuote: Model {
    let id: String
    var text: String
    var author: String?
    var category: String?
    var isFavorite: Bool
    var owner: String?
    var createdAt: Temporal.DateTime?
    var updatedAt: Temporal.DateTime?
    
    init(id: String = UUID().uuidString,
         text: String,
         author: String? = nil,
         category: String? = nil,
         isFavorite: Bool = false,
         owner: String? = nil,
         createdAt: Temporal.DateTime? = nil,
         updatedAt: Temporal.DateTime? = nil) {
        self.id = id
        self.text = text
        self.author = author
        self.category = category
        self.isFavorite = isFavorite
        self.owner = owner
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension AmplifyQuote: Identifiable {}

