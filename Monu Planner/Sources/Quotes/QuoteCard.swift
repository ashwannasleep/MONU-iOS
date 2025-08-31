import SwiftUI

// MARK: - Quote Card
struct QuoteCard: View {
    let quote: Quote
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Quote text
            Text(quote.text)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .accessibilityLabel("Quote: \(quote.text)")
            
            HStack {
                // Category badge
                HStack(spacing: 6) {
                    Text(quote.category.emoji)
                        .font(.caption)
                    Text(quote.category.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.secondary.opacity(0.1))
                )
                .foregroundColor(.secondary)
                .accessibilityLabel("Category: \(quote.category.displayName)")
                
                Spacer()
                
                // Favorite button
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isFavorite ? .red : .secondary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                .accessibilityHint("Double tap to \(isFavorite ? "remove from" : "add to") favorites")
            }
            
            // Author line (if available)
            if let author = quote.author {
                Text("— \(author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .accessibilityLabel("Author: \(author)")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        QuoteCard(
            quote: QuotePool.all[0],
            isFavorite: false,
            onToggleFavorite: {}
        )
        
        QuoteCard(
            quote: QuotePool.all[1],
            isFavorite: true,
            onToggleFavorite: {}
        )
        
        QuoteCard(
            quote: QuotePool.all[2],
            isFavorite: false,
            onToggleFavorite: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
