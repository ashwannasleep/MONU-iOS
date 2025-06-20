import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import GoogleSignIn

@main
struct MonuPlannerApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var navigationManager: NavigationContainer.NavigationManager
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var notificationOnboarding = NotificationOnboardingManager.shared
    @StateObject private var aiInsightsManager = AIInsightsManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var amplifyConfigured = false
    @State private var initializationError: String?

    static var hasConfiguredAmplify = false

    init() {
        _navigationManager = StateObject(wrappedValue: NavigationContainer.NavigationManager())
        configureGoogleSignIn()
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
                    LandingPageView()
                        .environmentObject(authManager)
                        .environmentObject(navigationManager)
                        .environmentObject(notificationManager)
                        .environmentObject(notificationOnboarding)
                        .environmentObject(aiInsightsManager)
                        .environmentObject(languageManager)
                        .navigationDestination(for: NavigationContainer.NavigationTypes.NavigationDestination.self) { destination in
                            destinationView(for: destination)
                        }
                        .sheet(isPresented: $notificationOnboarding.shouldShowOnboarding) {
                            NotificationOnboardingView()
                                .environmentObject(notificationOnboarding)
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

    // MARK: - Google Sign-In
    private func configureGoogleSignIn() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("⚠️ GoogleService-Info.plist not found or CLIENT_ID missing")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        print("✅ Google Sign-In configured with client ID")
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
                .environmentObject(languageManager)
        case .choose:
            ChoosePageView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .dashboard:
            DashboardView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .yearlyOverview:
            YearlyOverviewView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .monthlyPlanner:
            MonthlyPlannerView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .dailyPlan:
            DailyPlanView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .habitTracker:
            HabitTrackerView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .futureVision:
            FutureVisionView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .bucketList:
            BucketListView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .pomodoro:
            PomodoroView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .userGuide:
            UserGuideView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        case .settings:
            SettingsPage()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(notificationManager)
                .environmentObject(aiInsightsManager)
                .environmentObject(languageManager)
        }
    }

    // MARK: - Amplify Configuration
    private func configureAmplify() async {
        print("⚡️ Starting Amplify configuration...")
        
        guard !Self.hasConfiguredAmplify else {
            print("⚠️ Amplify already configured, skipping...")
            await MainActor.run {
                amplifyConfigured = true
                authManager.checkAuthenticationStatus()
            }
            return
        }

        do {
            if let configPath = Bundle.main.path(forResource: "amplifyconfiguration", ofType: "json") {
                print("✅ Found config file at: \(configPath)")
            } else {
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

            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()

            Self.hasConfiguredAmplify = true

            await MainActor.run {
                amplifyConfigured = true
                authManager.checkAuthenticationStatus()
                print("✅ Amplify configured successfully")
            }

        } catch {
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
                print(initializationError!)
            }
        }
    }
}

