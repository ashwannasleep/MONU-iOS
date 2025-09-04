import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import GoogleSignIn
import UserNotifications

extension Notification.Name {
    static let welcomeCompleted = Notification.Name("welcomeCompleted")
}

@main
struct MonuPlannerApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var navigationManager: NavigationContainer.NavigationManager
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var notificationOnboarding = NotificationOnboardingManager.shared
    @StateObject private var aiInsightsManager = AIInsightsManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var calendarSyncManager = CalendarSyncManager()
    @State private var amplifyConfigured = false
    @State private var initializationError: String?
    @State private var hasSeenWelcome = false

    static var hasConfiguredAmplify = false

    init() {
        print("🚀 Starting MonuPlannerApp initialization...")
        
        do {
            // Initialize navigation manager safely
            _navigationManager = StateObject(wrappedValue: NavigationContainer.NavigationManager())
            print("✅ NavigationManager initialized")
            
            // Verify bundle configuration
            verifyBundleConfiguration()
            print("✅ Bundle configuration verified")
            
            // Configure services with error handling
            configureGoogleSignIn()
            setupNotificationHandling()
            print("✅ Services configured")
            
            // Ensure all StateObjects are properly initialized
            print("📦 StateObjects initialized:")
            print("  - NavigationManager: \(navigationManager)")
            print("  - NotificationManager: \(notificationManager)")
            print("  - NotificationOnboarding: \(notificationOnboarding)")
            print("  - AIInsightsManager: \(aiInsightsManager)")
            
            // Note: Onboarding status will be updated in the body using onAppear
            
            print("✅ MonuPlannerApp initialized successfully")
        } catch {
            print("❌ Error during MonuPlannerApp initialization: \(error)")
        }
    }


    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationManager.navigationPath) {
                if let error = initializationError {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Initialization Failed")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            Task {
                                initializationError = nil
                                amplifyConfigured = false
                                await configureAmplify()
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.97, green: 0.96, blue: 0.94))
                } else if amplifyConfigured {
                    ZStack {
                        if !hasSeenWelcome {
                            // Show welcome view for new users
                            WelcomeView()
                                .environmentObject(themeManager)
                                .transition(.opacity)
                                .onReceive(NotificationCenter.default.publisher(for: .welcomeCompleted)) { _ in
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        hasSeenWelcome = true
                                    }
                                }
                        } else {
                            // Show main app for returning users
                            LandingPageView()
                                .environmentObject(authManager)
                                .environmentObject(navigationManager)
                                .environmentObject(notificationManager)
                                .environmentObject(notificationOnboarding)
                                .environmentObject(aiInsightsManager)
                                .environmentObject(themeManager)
                                .environmentObject(calendarSyncManager)
                                .navigationDestination(for: NavigationContainer.NavigationTypes.NavigationDestination.self) { destination in
                                    destinationView(for: destination)
                                }
                                .sheet(isPresented: $notificationOnboarding.shouldShowOnboarding) {
                                    NotificationOnboardingView()
                                        .environmentObject(notificationOnboarding)
                                        .environmentObject(notificationManager)
                                }
                        }
                        
                        // Notification Banner
                        NotificationBannerContainer()
                    }
                    .environmentObject(themeManager)
                    .environmentObject(calendarSyncManager)
                    .preferredColorScheme(themeManager.colorScheme)
                    .onAppear {
                        if !amplifyConfigured {
                            Task {
                                await configureAmplify()
                            }
                        }
                        
                        // Connect calendar sync manager to auth manager for user isolation
                        Task {
                            await authManager.setCalendarSyncManager(calendarSyncManager)
                        }
                        
                        // Check authentication status
                        Task {
                            await authManager.checkAuthenticationStatus()
                        }
                        
                        // Check if user has seen welcome
                        hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
                        
                        // Update onboarding status after a short delay to ensure all managers are initialized
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            notificationOnboarding.updateOnboardingStatus()
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        
                        Text("Initializing MonuPlanner...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Setting up secure connection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.97, green: 0.96, blue: 0.94))
                    .task {
                        if !Self.hasConfiguredAmplify {
                            await configureAmplify()
                        } else {
                            amplifyConfigured = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - Bundle Verification
    private func verifyBundleConfiguration() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            print("❌ Bundle identifier not found")
            return
        }
        
        print("📦 Bundle ID: \(bundleId)")
        
        // Check if required files exist
        let requiredFiles = ["GoogleService-Info.plist", "amplifyconfiguration.json"]
        for fileName in requiredFiles {
            if Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".plist", with: "").replacingOccurrences(of: ".json", with: ""), ofType: fileName.hasSuffix(".plist") ? "plist" : "json") != nil {
                print("✅ \(fileName) found")
            } else {
                print("⚠️ \(fileName) not found in bundle")
            }
        }
    }
    
    // MARK: - Google Sign-In
    private func configureGoogleSignIn() {
        do {
            guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
                print("⚠️ GoogleService-Info.plist not found in bundle")
                return
            }
            
            guard let plist = NSDictionary(contentsOfFile: path) else {
                print("⚠️ Failed to read GoogleService-Info.plist")
                return
            }
            
            guard let clientId = plist["CLIENT_ID"] as? String else {
                print("⚠️ CLIENT_ID missing from GoogleService-Info.plist")
                return
            }
            
            // Use the same client ID as server client ID for iOS apps
            let serverClientId = clientId
            
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(
                clientID: clientId,
                serverClientID: serverClientId
            )
            print("✅ Google Sign-In configured with client ID and server client ID")
            print("   - Client ID: \(clientId)")
            print("   - Server Client ID: \(serverClientId)")
        } catch {
            print("❌ Error configuring Google Sign-In: \(error)")
        }
    }
    
    private func setupNotificationHandling() {
        do {
            UNUserNotificationCenter.current().delegate = NotificationHandler.shared
            print("✅ Notification handler configured")
        } catch {
            print("❌ Failed to setup notification handling: \(error)")
        }
    }

    // MARK: - Navigation
    @ViewBuilder
    private func destinationView(for destination: NavigationContainer.NavigationTypes.NavigationDestination) -> some View {
        switch destination {
        case .landing:
            LandingPageView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .choose:
            ChoosePageView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .dashboard:
            DashboardView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .yearlyOverview:
            YearlyOverviewView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .monthlyPlanner:
            MonthlyPlannerView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .dailyPlan:
            DailyPlanView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .habitTracker:
            HabitTrackerView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .futureVision:
            FutureVisionView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .bucketList:
            BucketListView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .pomodoro:
            PomodoroView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .userGuide:
            UserGuideView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        case .settings:
            SettingsPage()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(themeManager)
                .environmentObject(calendarSyncManager)
        }
    }

    // MARK: - Amplify Configuration
    private func configureAmplify() async {
        print("⚡️ Starting Amplify configuration...")
        
        guard !Self.hasConfiguredAmplify else {
            print("⚠️ Amplify already configured, skipping...")
            await MainActor.run {
                amplifyConfigured = true
                print("✅ Amplify configured successfully")
            }
            return
        }

        do {
            // Verify configuration file exists and is readable
            guard let configPath = Bundle.main.path(forResource: "amplifyconfiguration", ofType: "json") else {
                print("❌ amplifyconfiguration.json not found in bundle")
                throw NSError(
                    domain: "com.monuplanner.amplify",
                    code: 1001,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Configuration file not found",
                        NSLocalizedRecoverySuggestionErrorKey: "Ensure amplifyconfiguration.json is added to your Xcode project"
                    ]
                )
            }
            
            print("✅ Found config file at: \(configPath)")
            
            // Verify the JSON is valid by attempting to read it
            guard let configData = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
                  let _ = try? JSONSerialization.jsonObject(with: configData) else {
                print("❌ amplifyconfiguration.json is not valid JSON")
                throw NSError(
                    domain: "com.monuplanner.amplify",
                    code: 1002,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Invalid JSON in configuration file",
                        NSLocalizedRecoverySuggestionErrorKey: "Check the format of amplifyconfiguration.json"
                    ]
                )
            }

            // Add plugins with error handling
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            print("✅ AWSCognitoAuthPlugin added")
            
            try Amplify.add(plugin: AWSAPIPlugin())
            print("✅ AWSAPIPlugin added")
            
            // Configure Amplify
            try Amplify.configure()
            print("✅ Amplify.configure() completed")

            Self.hasConfiguredAmplify = true

            await MainActor.run {
                amplifyConfigured = true
                print("✅ Amplify configured successfully")
            }
            
            await authManager.checkAuthenticationStatus()

        } catch {
            print("❌ Amplify configuration error: \(error)")
            await MainActor.run {
                initializationError = """
                ❌ Amplify configuration failed:
                Error: \(error.localizedDescription)

                Troubleshooting:
                1. Ensure amplifyconfiguration.json is in your project
                2. Check that it's added to your app target in Xcode  
                3. Verify the JSON format is valid
                4. If using API_KEY auth, ensure the key is set
                """
                print(initializationError ?? "Unknown error")
            }
        }
    }
}

// MARK: - Notification Handler
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    
    private override init() {
        super.init()
    }
    
    // Handle notification actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.actionIdentifier
        
        switch identifier {
        case "DISMISS_ACTION":
            // Remove the notification from the notification center
            center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
            print("✅ Notification dismissed")
            
        case "SNOOZE_ACTION":
            // Snooze the notification for 15 minutes
            guard let content = response.notification.request.content.mutableCopy() as? UNMutableNotificationContent else {
                print("❌ Failed to create mutable notification content")
                completionHandler()
                return
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false)
            let request = UNNotificationRequest(
                identifier: "snoozed_\(response.notification.request.identifier)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Failed to snooze notification: \(error)")
                } else {
                    print("✅ Notification snoozed for 15 minutes")
                }
            }
            
        default:
            // Handle default tap action
            print("📱 Notification tapped: \(response.notification.request.content.title)")
        }
        
        completionHandler()
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
