import SwiftUI

// MARK: - Quote Screen
struct QuoteScreen: View {
    @EnvironmentObject var quoteStore: QuoteStore
    @State private var currentQuote: Quote
    @State private var showingShuffleAnimation = false
    @State private var selectedCategory: QuoteCategory? = nil
    
    init() {
        // Initialize with today's quote
        self._currentQuote = State(initialValue: QuotePool.quoteOfTheDay())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Quote of the Day Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Quote of the Day")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(Date(), style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        QuoteCard(
                            quote: currentQuote,
                            isFavorite: quoteStore.isFavorite(currentQuote),
                            onToggleFavorite: {
                                quoteStore.toggleFavorite(currentQuote)
                            }
                        )
                    }
                    
                    // Shuffle Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Discover")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            Button(action: shuffleQuote) {
                                HStack {
                                    Image(systemName: "shuffle")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Shuffle")
                                        .font(.system(size: 17, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Shuffle to get a random quote")
                            
                            // Category Filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                                        Button(action: {
                                            selectedCategory = selectedCategory == category ? nil : category
                                        }) {
                                            HStack(spacing: 6) {
                                                Text(category.emoji)
                                                    .font(.caption)
                                                Text(category.displayName)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(selectedCategory == category ? Color.blue : Color.secondary.opacity(0.1))
                                            )
                                            .foregroundColor(selectedCategory == category ? .white : .secondary)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    
                    // Favorites Section
                    if !quoteStore.getFavoriteQuotes().isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Favorites")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(quoteStore.getFavoriteQuotes()) { quote in
                                    QuoteCard(
                                        quote: quote,
                                        isFavorite: true,
                                        onToggleFavorite: {
                                            quoteStore.toggleFavorite(quote)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    // All Quotes Section (filtered by category if selected)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(selectedCategory?.displayName ?? "All Quotes")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            if selectedCategory != nil {
                                Button("Clear Filter") {
                                    selectedCategory = nil
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        LazyVStack(spacing: 16) {
                            ForEach(filteredQuotes) { quote in
                                QuoteCard(
                                    quote: quote,
                                    isFavorite: quoteStore.isFavorite(quote),
                                    onToggleFavorite: {
                                        quoteStore.toggleFavorite(quote)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Quotes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Shuffle") {
                        shuffleQuote()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            // Refresh quote of the day when view appears
            currentQuote = QuotePool.quoteOfTheDay()
        }
    }
    
    // MARK: - Computed Properties
    private var filteredQuotes: [Quote] {
        if let category = selectedCategory {
            return QuotePool.all.filter { $0.category == category }
        }
        return QuotePool.all
    }
    
    // MARK: - Actions
    private func shuffleQuote() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingShuffleAnimation = true
        }
        
        // Get new quote
        let newQuote = QuotePool.randomWeighted()
        
        // Animate the change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuote = newQuote
                showingShuffleAnimation = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    QuoteScreen()
        .environmentObject(QuoteStore())
}
