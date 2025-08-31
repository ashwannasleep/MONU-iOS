import Foundation

// MARK: - Quote Category
enum QuoteCategory: String, CaseIterable, Codable {
    case motivation = "motivation"
    case growth = "growth"
    case reflection = "reflection"
    case philosophy = "philosophy"
    
    var displayName: String {
        switch self {
        case .motivation: return "Motivation"
        case .growth: return "Growth & Mindset"
        case .reflection: return "Reflection"
        case .philosophy: return "Philosophy"
        }
    }
    
    var emoji: String {
        switch self {
        case .motivation: return "🔥"
        case .growth: return "🌱"
        case .reflection: return "💭"
        case .philosophy: return "🧠"
        }
    }
}

// MARK: - Quote Model
struct Quote: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let category: QuoteCategory
    let author: String?
    
    init(text: String, category: QuoteCategory, author: String? = nil) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.author = author
    }
}

// MARK: - Quote Pool
enum QuotePool {
            // MARK: - All Quotes
        static let all: [Quote] = [
            // Universal quotes that apply to everyone
            Quote(text: "Take your time", category: .motivation),
            Quote(text: "Everything starts here", category: .motivation),
            Quote(text: "Let today be gentle", category: .motivation),
            Quote(text: "The moment is yours", category: .motivation),
            Quote(text: "It's okay to go slow", category: .motivation),
            Quote(text: "This space belongs to you", category: .motivation),
            Quote(text: "Little steps, lasting change", category: .motivation),
            Quote(text: "This is where it begins", category: .motivation),
            Quote(text: "You've arrived", category: .motivation),
            Quote(text: "Every day is a new beginning", category: .growth),
            Quote(text: "Your journey matters", category: .growth),
            Quote(text: "Trust the process", category: .growth),
            Quote(text: "You are capable", category: .motivation),
            Quote(text: "Breathe and begin", category: .reflection),
            Quote(text: "You have what it takes", category: .motivation)
        ]
    
    // MARK: - Category Helpers
    static var motivation: [Quote] {
        all.filter { $0.category == .motivation }
    }
    
    static var growth: [Quote] {
        all.filter { $0.category == .growth }
    }
    
    static var reflection: [Quote] {
        all.filter { $0.category == .reflection }
    }
    
    static var philosophy: [Quote] {
        all.filter { $0.category == .philosophy }
    }
    
    // MARK: - Quote of the Day
    static func quoteOfTheDay(date: Date = Date(), tz: TimeZone = .current) -> Quote {
        var calendar = Calendar.current
        calendar.timeZone = tz
        
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let daySeed = (components.year ?? 2024) * 10000 + (components.month ?? 1) * 100 + (components.day ?? 1)
        
        // Simple deterministic selection using day seed
        let index = daySeed % all.count
        return all[index]
    }
    
    // MARK: - Weighted Random
    static func randomWeighted() -> Quote {
        // Weights: Motivation 0.4, Growth 0.4, Reflection 0.1, Philosophy 0.1
        let random = Double.random(in: 0...1)
        
        if random < 0.4 {
            return motivation.randomElement() ?? all.randomElement() ?? all[0]
        } else if random < 0.8 {
            return growth.randomElement() ?? all.randomElement() ?? all[0]
        } else if random < 0.9 {
            return reflection.randomElement() ?? all.randomElement() ?? all[0]
        } else {
            return philosophy.randomElement() ?? all.randomElement() ?? all[0]
        }
    }
}
