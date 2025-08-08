import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("selectedThemeColor") var selectedThemeColor: ThemeColor = .pastelBlue
    @Published var colorScheme: ColorScheme = .light

    private init() {
        updateColorScheme()
    }

    func toggleTheme() {
        isDarkMode.toggle()
        updateColorScheme()
    }

    func setTheme(_ isDark: Bool) {
        isDarkMode = isDark
        updateColorScheme()
    }

    func setThemeColor(_ color: ThemeColor) {
        selectedThemeColor = color
    }

    private func updateColorScheme() {
        colorScheme = isDarkMode ? .dark : .light
    }

    // Computed properties for consistent theming across the app
    var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.97, green: 0.96, blue: 0.94)
    }

    var textColor: Color {
        colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) : Color(red: 0.05, green: 0.05, blue: 0.05)
    }

    var secondaryTextColor: Color {
        colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.2, green: 0.2, blue: 0.2)
    }

    var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : Color.white
    }

    var accentColor: Color {
        selectedThemeColor.color
    }

    var buttonBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.27, green: 0.27, blue: 0.27) : Color(red: 0.78, green: 0.75, blue: 0.7)
    }

    var buttonBorderColor: Color {
        colorScheme == .dark ? Color(red: 0.4, green: 0.4, blue: 0.4) : Color(red: 0.08, green: 0.04, blue: 0.04)
    }
    
    // Function to get appropriate text color for theme color backgrounds
    func textColorForTheme(_ themeColor: ThemeColor) -> Color {
        // For now, use a simple approach based on the theme color
        // Light colors get dark text, dark colors get light text
        switch themeColor {
        case .pastelYellow, .pastelOrange, .pastelPink, .pastelBlue, .mint, .silver:
            return Color(red: 0.1, green: 0.1, blue: 0.1) // Dark text for light colors
        case .pastelPurple:
            return Color.white // Light text for darker purple
        }
    }
}

// MARK: - Theme Colors
enum ThemeColor: String, CaseIterable {
    case pastelYellow = "pastelYellow"
    case pastelOrange = "pastelOrange"
    case pastelPink = "pastelPink"
    case pastelPurple = "pastelPurple"
    case pastelBlue = "pastelBlue"
    case mint = "mint"
    case silver = "silver"
    
    var color: Color {
        switch self {
        case .pastelYellow:
            return Color(red: 0.9, green: 0.85, blue: 0.6) // Darker yellow
        case .pastelOrange:
            return Color(red: 0.9, green: 0.75, blue: 0.55) // Darker orange
        case .pastelPink:
            return Color(red: 0.9, green: 0.75, blue: 0.8) // Darker pink
        case .pastelPurple:
            return Color(red: 0.8, green: 0.75, blue: 0.85) // Darker purple
        case .pastelBlue:
            return Color(red: 0.75, green: 0.8, blue: 0.9) // Darker blue
        case .mint:
            return Color(red: 0.75, green: 0.85, blue: 0.8) // Darker mint
        case .silver:
            return Color(red: 0.8, green: 0.8, blue: 0.8) // Darker silver
        }
    }
    
    var displayName: String {
        switch self {
        case .pastelYellow: return "Yellow"
        case .pastelOrange: return "Orange"
        case .pastelPink: return "Pink"
        case .pastelPurple: return "Purple"
        case .pastelBlue: return "Blue"
        case .mint: return "Mint"
        case .silver: return "Silver"
        }
    }
    
    var icon: String {
        switch self {
        case .pastelYellow: return "star.fill"
        case .pastelOrange: return "sun.max.fill"
        case .pastelPink: return "heart.fill"
        case .pastelPurple: return "sparkles"
        case .pastelBlue: return "drop.fill"
        case .mint: return "leaf.fill"
        case .silver: return "circle.fill"
        }
    }
} 
