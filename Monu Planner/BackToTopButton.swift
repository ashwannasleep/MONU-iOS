import SwiftUI

struct BackToTopButton: View {
    @Binding var scrollOffset: CGFloat
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var shouldShow: Bool {
        scrollOffset > 300
    }
    
    var body: some View {
        if shouldShow {
            Button(action: action) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .medium))
                    Text("Top")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: shouldShow)
        }
    }
}

// MARK: - ScrollView Reader Helper
struct ScrollViewReader<Content: View>: View {
    let content: (ScrollViewReader) -> Content
    @Binding var scrollOffset: CGFloat
    
    init(scrollOffset: Binding<CGFloat>, @ViewBuilder content: @escaping (ScrollViewReader) -> Content) {
        self._scrollOffset = scrollOffset
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
            }
            .frame(height: 0)
            
            content(self)
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = -value
        }
    }
}

// MARK: - Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 