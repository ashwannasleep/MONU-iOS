import SwiftUI

// MARK: - Layout Helper
struct LayoutHelper {
    // Standard breakpoints
    static let iPadBreakpoint: CGFloat = 768
    static let largeiPadBreakpoint: CGFloat = 1024
    
    // Standard padding
    static let standardPadding: CGFloat = 20
    static let widePadding: CGFloat = 32
    static let narrowPadding: CGFloat = 16
    
    // Standard spacing
    static let standardSpacing: CGFloat = 24
    static let tightSpacing: CGFloat = 16
    static let wideSpacing: CGFloat = 32
    
    // Get responsive padding based on screen width
    static func responsivePadding(for width: CGFloat) -> CGFloat {
        if width > iPadBreakpoint {
            return widePadding
        } else {
            return standardPadding
        }
    }
    
    // Get responsive spacing based on screen width
    static func responsiveSpacing(for width: CGFloat) -> CGFloat {
        if width > iPadBreakpoint {
            return wideSpacing
        } else {
            return standardSpacing
        }
    }
    
    // Get grid columns based on screen width
    static func responsiveGridColumns(for width: CGFloat, maxColumns: Int = 2) -> [GridItem] {
        let spacing: CGFloat = 20
        let padding: CGFloat = responsivePadding(for: width) * 2
        let availableWidth = width - padding
        
        if width > largeiPadBreakpoint && maxColumns >= 3 {
            // Large iPad: 3 columns if wide enough
            return Array(repeating: GridItem(.flexible(), spacing: spacing), count: 3)
        } else if width > iPadBreakpoint {
            // iPad: 2 columns
            return Array(repeating: GridItem(.flexible(), spacing: spacing), count: 2)
        } else {
            // iPhone: 1 column
            return [GridItem(.flexible())]
        }
    }
    
    // Check if device is iPad
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Get current screen width
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
}

// MARK: - Responsive View Modifier
struct ResponsiveLayout: ViewModifier {
    let width: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, LayoutHelper.responsivePadding(for: width))
    }
}

// MARK: - Responsive Grid Modifier
struct ResponsiveGrid: ViewModifier {
    let width: CGFloat
    let maxColumns: Int
    
    func body(content: Content) -> some View {
        LazyVGrid(
            columns: LayoutHelper.responsiveGridColumns(for: width, maxColumns: maxColumns),
            spacing: LayoutHelper.responsiveSpacing(for: width)
        ) {
            content
        }
    }
}

// MARK: - View Extensions
extension View {
    func responsiveLayout(for width: CGFloat) -> some View {
        modifier(ResponsiveLayout(width: width))
    }
    
    func responsiveGrid(for width: CGFloat, maxColumns: Int = 2) -> some View {
        modifier(ResponsiveGrid(width: width, maxColumns: maxColumns))
    }
}
