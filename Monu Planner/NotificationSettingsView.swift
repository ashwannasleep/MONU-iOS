import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    

    
    var body: some View {
        ZStack {
            // Background
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 6) {
                        Text("Notifications")
                            .font(.custom("Georgia", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.textColor)
                        
                        Text("Coming Soon")
                            .font(.custom("Georgia", size: 14))
                            .italic()
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Coming Soon Message
                    VStack(spacing: 16) {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 48))
                            .foregroundColor(themeManager.accentColor)
                        
                        Text("Notification Features")
                            .font(.custom("Georgia", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.textColor)
                        
                        Text("Advanced notification settings will be available in a future update. For now, basic notifications are handled automatically by the app.")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(24)
                    .background(themeManager.cardBackgroundColor)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(themeManager.accentColor)
            }
        }
    }
}