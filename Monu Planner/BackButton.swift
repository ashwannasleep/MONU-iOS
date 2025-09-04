import SwiftUI

struct BackButton: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            navigationManager.goBack()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: LayoutHelper.isIPad ? 22 : 18, weight: .medium))
                .foregroundColor(themeManager.textColor)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: LayoutHelper.isIPad ? 44 : 36, height: LayoutHelper.isIPad ? 44 : 36)
        .background(
            Circle()
                .fill(themeManager.backgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}
