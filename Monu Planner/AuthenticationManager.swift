import Foundation
import Amplify

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var displayName: String? = nil
    
    func checkAuthenticationStatus() {
        print("🔍 Checking authentication status...")
        Task {
            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                print("Session fetched, isSignedIn: \(session.isSignedIn)")

                await MainActor.run {
                    self.isAuthenticated = session.isSignedIn
                }

                if session.isSignedIn {
                    let user = try await Amplify.Auth.getCurrentUser()
                    print("Current user: \(user.username)")

                    // Load stored display name from UserDefaults
                    let storedName = UserDefaults.standard.string(forKey: "monu_name")

                    await MainActor.run {
                        self.currentUser = user
                        self.displayName = storedName
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

    func signOut(navigationManager: NavigationContainer.NavigationManager? = nil) {
        Task {
            do {
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
