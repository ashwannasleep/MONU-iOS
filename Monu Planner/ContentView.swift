import SwiftUI
import Amplify

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager

    var body: some View {
        ZStack {
            if let name = authManager.currentUser?.username {
                ChoosePageView()
            } else {
                Color(red: 0.97, green: 0.96, blue: 0.94)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 20) {
                            Text("MONU — this is your moment")
                                .font(.custom("Georgia", size: 24))
                                .padding(.top, 100)

                            AuthModal(
                                onSignIn: { email, password in
                                    Task {
                                        do {
                                            try await Amplify.Auth.signIn(username: email, password: password)
                                            await MainActor.run {
                                                authManager.checkAuthenticationStatus()
                                            }
                                        } catch {
                                            print("❌ Sign in failed: \(error)")
                                        }
                                    }
                                },
                                onSignUp: { email, password, name in
                                    Task {
                                        do {
                                            try await Amplify.Auth.signUp(
                                                username: email,
                                                password: password,
                                                options: .init(userAttributes: [.init(.name, value: name)])
                                            )
                                            print("✅ Sign up successful")
                                        } catch {
                                            print("❌ Sign up failed: \(error)")
                                        }
                                    }
                                },
                                onClose: {
                                    print("🛑 Auth modal closed")
                                }
                            )
                        }
                    )
            }
        }
    }
}
