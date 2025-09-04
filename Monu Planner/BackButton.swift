import SwiftUI

struct BackButton: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            navigationManager.goBack()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(themeManager.textColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
