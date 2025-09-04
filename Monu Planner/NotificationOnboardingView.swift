import SwiftUI
import UserNotifications

struct NotificationOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showSettingsGuidance = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.4, green: 0.5, blue: 0.6).opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "bell.badge")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    }
                    .padding(.top, 24)
                    
                    // Title
                    Text("Stay on Track")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                        .multilineTextAlignment(.center)
                    
                    // Subtitle
                    Text("Get gentle reminders to plan your day, track habits, and review your progress")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
                
                // Features list
                VStack(spacing: 16) {
                    featureRow(icon: "🌿", title: "Daily Planning", description: "Plan your day ahead")
                    featureRow(icon: "✨", title: "Habit Tracking", description: "Track your daily habits")
                    featureRow(icon: "📊", title: "Weekly Progress", description: "Review your achievements")
                    featureRow(icon: "🎯", title: "Goal Reminders", description: "Stay focused on your goals")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // Buttons
                VStack(spacing: 12) {
                    // Enable button
                    Button(action: {
                        Task {
                            await handleNotificationPermission()
                        }
                    }) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16))
                            Text(getButtonText())
                                .font(.custom("Georgia", size: 16))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.4, green: 0.5, blue: 0.6))
                        .cornerRadius(12)
                    }
                    
                    // Maybe later button
                    Button(action: { 
                        NotificationOnboardingManager.shared.dismissOnboarding()
                        dismiss() 
                    }) {
                        Text("Maybe Later")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
        .alert("Enable Notifications", isPresented: $showSettingsGuidance) {
            Button("OK") {
                showSettingsGuidance = false
            }
        } message: {
            Text("1. In Settings, find 'Monu Planner'\n2. Tap on it\n3. Tap 'Notifications'\n4. Turn on 'Allow Notifications'\n5. Return to the app")
        }
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    // MARK: - Helper Functions
    private func getButtonText() -> String {
        return "Enable Notifications"
    }
    
    private func checkNotificationStatus() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            if settings.authorizationStatus == .authorized {
                await MainActor.run {
                    NotificationOnboardingManager.shared.markOnboardingAsSeen()
                    dismiss()
                }
            }
        }
    }
    
    private func handleNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        
        // Get current authorization status
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            // First time - request permission
            let granted = await notificationManager.requestAuthorization()
            if granted {
                NotificationOnboardingManager.shared.markOnboardingAsSeen()
                dismiss()
            }
            
        case .denied:
            // User denied before - open Settings
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                await MainActor.run {
                    UIApplication.shared.open(settingsUrl)
                }
                // Show a helpful message to guide the user
                await MainActor.run {
                    // We'll add a state to show guidance after opening settings
                    showSettingsGuidance = true
                }
            }
            
        case .authorized:
            // Already authorized
            NotificationOnboardingManager.shared.markOnboardingAsSeen()
            dismiss()
            
        case .provisional, .ephemeral:
            // Request full authorization
            let granted = await notificationManager.requestAuthorization()
            if granted {
                NotificationOnboardingManager.shared.markOnboardingAsSeen()
                dismiss()
            }
            
        @unknown default:
            // Fallback to request permission
            let granted = await notificationManager.requestAuthorization()
            if granted {
                NotificationOnboardingManager.shared.markOnboardingAsSeen()
                dismiss()
            }
        }
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Georgia", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                
                Text(description)
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? Color(red: 0.22, green: 0.22, blue: 0.22) : Color(red: 0.97, green: 0.96, blue: 0.94))
        .cornerRadius(10)
    }
}

// MARK: - Notification Onboarding Manager
class NotificationOnboardingManager: ObservableObject {
    static let shared = NotificationOnboardingManager()
    
    @Published var shouldShowOnboarding = false
    
    private init() {
        checkIfShouldShowOnboarding()
    }
    
    private func checkIfShouldShowOnboarding() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "has_seen_notification_onboarding")
        let hasDismissedOnboarding = UserDefaults.standard.bool(forKey: "has_dismissed_notification_onboarding")
        
        // Check notification authorization status
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                
                // Only show onboarding if:
                // 1. User hasn't seen it before AND hasn't dismissed it
                // 2. Notifications are not authorized
                // 3. User hasn't explicitly dismissed it
                self.shouldShowOnboarding = !hasSeenOnboarding && !hasDismissedOnboarding && !isAuthorized
            }
        }
    }
    
    func markOnboardingAsSeen() {
        UserDefaults.standard.set(true, forKey: "has_seen_notification_onboarding")
        shouldShowOnboarding = false
    }
    
    func dismissOnboarding() {
        UserDefaults.standard.set(true, forKey: "has_dismissed_notification_onboarding")
        shouldShowOnboarding = false
    }
    
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "has_seen_notification_onboarding")
        UserDefaults.standard.removeObject(forKey: "has_dismissed_notification_onboarding")
        checkIfShouldShowOnboarding()
    }
    
    func updateOnboardingStatus() {
        // Add safety check to prevent crashes
        DispatchQueue.main.async {
            self.checkIfShouldShowOnboarding()
        }
    }
}

#Preview {
    NotificationOnboardingView()
        .environmentObject(NotificationManager.shared)
} 