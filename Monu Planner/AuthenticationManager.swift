import Foundation
import Amplify
import GoogleSignIn

final class AuthenticationManager: ObservableObject {
    // MARK: - Published state
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var displayName: String? = nil
    @Published var userEmail: String? = nil
    @Published var isSigningOut = false   // NEW

    // Reference to calendar sync manager for user isolation
    private var calendarSyncManager: CalendarSyncManager?

    // MARK: - Setup
    func setCalendarSyncManager(_ manager: CalendarSyncManager) async {
        calendarSyncManager = manager
    }

    // MARK: - Session / status
    func checkAuthenticationStatus() async {
        print("🔍 Checking authentication status...")
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            print("Session fetched, isSignedIn: \(session.isSignedIn)")

            if session.isSignedIn {
                let user = try await Amplify.Auth.getCurrentUser()
                print("Current Amplify user: \(user.username)")

                // Load stored display name
                let storedName = UserDefaults.standard.string(forKey: "monu_name")

                // Store email if username looks like an email
                if user.username.contains("@") {
                    UserDefaults.standard.set(user.username, forKey: "user_email")
                    print("📧 Stored email from username: \(user.username)")
                }

                await fetchAndStoreEmail()

                await MainActor.run {
                    self.isAuthenticated = true
                    self.currentUser = user
                    self.displayName = storedName
                }

                // Set current app user for Google Calendar isolation
                if let email = UserDefaults.standard.string(forKey: "user_email") {
                    await self.calendarSyncManager?.setCurrentAppUser(email)
                }
            } else {
                // No valid session — ensure Google is signed out too
                if GIDSignIn.sharedInstance.currentUser != nil {
                    print("🔄 No Amplify session but Google user exists, signing out from Google…")
                    GIDSignIn.sharedInstance.signOut()
                }

                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.displayName = nil
                }
            }
        } catch {
            print("Auth check failed:", error)
            await MainActor.run {
                self.isAuthenticated = false
                self.errorMessage = error.localizedDescription
                self.hasError = true
            }
        }
    }

    func restoreSession() async {
        print("🔄 Attempting to restore session...")
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if session.isSignedIn {
                let user = try await Amplify.Auth.getCurrentUser()
                let storedName = UserDefaults.standard.string(forKey: "monu_name")

                if user.username.contains("@") {
                    UserDefaults.standard.set(user.username, forKey: "user_email")
                    print("📧 Stored email from username: \(user.username)")
                }
                await fetchAndStoreEmail()

                await MainActor.run {
                    self.isAuthenticated = true
                    self.currentUser = user
                    self.displayName = storedName
                    print("✅ Session restored successfully")
                }

                if let email = UserDefaults.standard.string(forKey: "user_email") {
                    await self.calendarSyncManager?.setCurrentAppUser(email)
                }
            } else {
                await MainActor.run {
                    self.isAuthenticated = false
                    print("❌ No valid session to restore")
                }
            }
        } catch {
            print("❌ Session restoration failed: \(error)")
            await MainActor.run {
                self.isAuthenticated = false
            }
        }
    }

    func saveDisplayName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "monu_name")
        displayName = name
    }

    func clearError() {
        hasError = false
        errorMessage = ""
    }

    // MARK: - Helpers
    private func fetchAndStoreEmail() async {
        do {
            let attrs = try await Amplify.Auth.fetchUserAttributes()
            if let emailAttr = attrs.first(where: { $0.key == .email }), !emailAttr.value.isEmpty {
                UserDefaults.standard.set(emailAttr.value, forKey: "user_email")
                await MainActor.run { self.userEmail = emailAttr.value }
                print("📧 Stored email from attributes: \(emailAttr.value)")
            }
        } catch {
            print("⚠️ fetchUserAttributes failed: \(error)")
        }
    }

    // MARK: - Sign out (complete)
    /// Fully signs out: Google -> Cognito (server + local tokens) -> clear app state
    func signOut(navigationManager: NavigationContainer.NavigationManager? = nil) async {
        await MainActor.run { isSigningOut = true }
        do {
            // 1) Google sign-out (safe if not signed in)
            GIDSignIn.sharedInstance.signOut()
            print("🚪 Signed out from Google")

            // 2) Cognito sign-out with revoke + invalidate
            try await Amplify.Auth.signOut(
                options: .init(globalSignOut: true)
            )
            print("🚪 Amplify global sign-out + invalidate tokens succeeded")

            // 3) Clear calendar isolation
            await self.calendarSyncManager?.setCurrentAppUser(nil)

            // 4) Verify SDK state and clear local data
            let session = try await Amplify.Auth.fetchAuthSession()
            await MainActor.run {
                self.isAuthenticated = session.isSignedIn
                self.currentUser = nil
                self.displayName = nil
                self.userEmail = nil
                UserDefaults.standard.removeObject(forKey: "monu_name")
                UserDefaults.standard.removeObject(forKey: "user_email")
                print(self.isAuthenticated ? "⚠️ SDK still says signed in" : "✅ Fully signed out")
            }
        } catch {
            print("Sign out error: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
                self.hasError = true
                self.isAuthenticated = false // fall back to logged-out UI
            }
        }
        await MainActor.run { isSigningOut = false }
    }
}

