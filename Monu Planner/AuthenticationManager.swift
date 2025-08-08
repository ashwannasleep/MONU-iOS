import Foundation
import Amplify
import GoogleSignIn

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var displayName: String? = nil
    @Published var userEmail: String? = nil
    
    func checkAuthenticationStatus() {
        print("🔍 Checking authentication status...")
        Task {
            do {
                // Check Amplify session first (more reliable)
                let session = try await Amplify.Auth.fetchAuthSession()
                print("Session fetched, isSignedIn: \(session.isSignedIn)")
                
                if session.isSignedIn {
                    let user = try await Amplify.Auth.getCurrentUser()
                    print("Current Amplify user: \(user.username)")
                    
                    // Load stored display name from UserDefaults
                    let storedName = UserDefaults.standard.string(forKey: "monu_name")
                    
                    // Store email if username looks like an email
                    if user.username.contains("@") {
                        UserDefaults.standard.set(user.username, forKey: "user_email")
                        print("📧 Stored email from username: \(user.username)")
                    }
                    // Try to fetch verified email attribute
                    await fetchAndStoreEmail()
                    
                    await MainActor.run {
                        self.isAuthenticated = true
                        self.currentUser = user
                        self.displayName = storedName
                    }
                } else {
                    // No valid session - check if Google user exists and sign out if needed
                    let googleUser = GIDSignIn.sharedInstance.currentUser
                    if googleUser != nil {
                        print("🔄 No valid Amplify session but Google user exists, signing out from Google...")
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
    }
    


    func saveDisplayName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "monu_name")
        displayName = name
    }

    func clearError() {
        hasError = false
        errorMessage = ""
    }
    
    func restoreSession() {
        print("🔄 Attempting to restore session...")
        Task {
            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                if session.isSignedIn {
                    let user = try await Amplify.Auth.getCurrentUser()
                    let storedName = UserDefaults.standard.string(forKey: "monu_name")
                    
                    // Store email from username when present
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
    }

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

    func signOut(navigationManager: NavigationContainer.NavigationManager? = nil) {
        Task {
            do {
                // Sign out from Google first
                GIDSignIn.sharedInstance.signOut()
                print("🚪 Signed out from Google")
                
                // Then sign out from Amplify
                let result = await Amplify.Auth.signOut()
                print("🚪 Sign out result: \(result)")
                
                await MainActor.run {
                    // Clear authentication state
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.displayName = nil
                    
                    // Clear stored user data
                    UserDefaults.standard.removeObject(forKey: "monu_name")
                    
                    // Navigate back to landing page
                    if let navManager = navigationManager {
                        navManager.navigationPath.removeAll()
                    }
                }
            } catch {
                print("Sign out error: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
                    self.hasError = true
                }
            }
        }
    }
}
