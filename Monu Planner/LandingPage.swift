import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

#if canImport(UIKit)
import UIKit
#endif

struct LandingPageView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showQuote = false
    @State private var quote = ""
    @State private var showAuthModal = false
    @State private var authMode: AuthModal.AuthMode = .signIn
    @State private var showVerification = false
    @State private var verificationCode = ""
    @State private var signupUser = ""
    @State private var signupPassword = ""
    @State private var animateElements = false
    
    let quotes = [
        "Take your time, {name}.",
        "Everything starts here, {name}.",
        "Let today be gentle, {name}.",
        "{name}, the moment is yours.",
        "It's okay to go slow, {name}.",
        "This space belongs to you.",
        "Little steps, {name}, lasting change.",
        "This is where it begins, {name}.",
        "{name}, you've arrived."
    ]
    
    // MARK: - Computed properties for theming
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.97, green: 0.96, blue: 0.94)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.35, green: 0.35, blue: 0.35)
    }
    
    private var buttonBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.27, green: 0.27, blue: 0.27) : Color(red: 0.78, green: 0.75, blue: 0.7)
    }
    
    private var buttonBorderColor: Color {
        colorScheme == .dark ? Color(red: 0.4, green: 0.4, blue: 0.4) : Color(red: 0.08, green: 0.04, blue: 0.04)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : Color.white
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Main Content Container with scaling
                    VStack(spacing: 16) {
                        // Title and Subtitle
                        VStack(spacing: 8) {
                            Text("MONU")
                                .font(.custom("Georgia", size: geometry.size.width < 400 ? 40 : 48))
                                .fontWeight(.semibold)
                                .tracking(2)
                                .foregroundColor(textColor)
                            
                            Text("moment & you")
                                .font(.custom("Georgia", size: geometry.size.width < 400 ? 16 : 20))
                                .italic()
                                .foregroundColor(secondaryTextColor)
                        }
                        .scaleEffect(1.2)
                        .opacity(animateElements ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8), value: animateElements)
                        
                        Spacer().frame(height: 40)
                        
                        // Content based on state
                        if showVerification {
                            verificationView
                        } else if showQuote {
                            quoteView
                        } else if !showAuthModal {
                            authButtonsView
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showAuthModal) {
            AuthModal(
                initialMode: authMode == .signIn ? .signIn : .signUp,
                onSignIn: handleSignIn,
                onSignUp: handleSignUp,
                onClose: { showAuthModal = false }
            )
            .preferredColorScheme(colorScheme)
        }
        .onAppear {
            checkExistingSession()
            withAnimation(.easeInOut(duration: 0.5)) {
                animateElements = true
            }
        }
        #if os(iOS)
        .navigationBarBackButtonHidden(true)
        #endif
    }
    
    private var authButtonsView: some View {
        VStack(spacing: 20) {
            MonuButton(
                title: "Sign In",
                backgroundColor: buttonBackgroundColor,
                borderColor: buttonBorderColor,
                textColor: textColor
            ) {
                authMode = .signIn
                showAuthModal = true
            }
            
            MonuButton(
                title: "Sign Up",
                backgroundColor: buttonBackgroundColor,
                borderColor: buttonBorderColor,
                textColor: textColor
            ) {
                authMode = .signUp
                showAuthModal = true
            }
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 20)
        .animation(.easeInOut(duration: 0.8).delay(0.3), value: animateElements)
    }
    
    private var quoteView: some View {
        VStack(spacing: 24) {
            Text(quote)
                .font(.custom("Georgia", size: 16))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .padding(.horizontal, 20)
                .opacity(showQuote ? 1 : 0)
                .offset(y: showQuote ? 0 : 20)
                .animation(.easeInOut(duration: 0.8), value: showQuote)
            
            MonuButton(
                title: "Start Planning",
                backgroundColor: buttonBackgroundColor,
                borderColor: buttonBorderColor,
                textColor: textColor
            ) {
                print("🎯 Start Planning button tapped!")
                print("Current navigation path: \(navigationManager.navigationPath)")
                navigationManager.navigate(to: .choose)
                print("Navigation path after navigate: \(navigationManager.navigationPath)")
            }

            .opacity(showQuote ? 1 : 0)
            .offset(y: showQuote ? 0 : 20)
            .onAppear {
                print("🎯 Button appeared, showQuote: \(showQuote)")
            }
            .animation(.easeInOut(duration: 0.8).delay(0.3), value: showQuote)

        }
    }
    
    private var verificationView: some View {
        VStack(spacing: 20) {
            Text("We've sent a verification code to **\(signupUser)**. Please enter it:")
                .font(.custom("Georgia", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(secondaryTextColor)
                .padding(.horizontal, 20)
            
            TextField("Verification code", text: $verificationCode)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
                .background(cardBackgroundColor)
                .cornerRadius(12)
            
            MonuButton(
                title: "Verify",
                backgroundColor: buttonBackgroundColor,
                borderColor: buttonBorderColor,
                textColor: textColor
            ) {
                handleVerifyCode()
            }
        }
        .opacity(showVerification ? 1 : 0)
        .offset(y: showVerification ? 0 : 20)
        .animation(.easeInOut(duration: 0.5), value: showVerification)
    }
    
    private func checkExistingSession() {
        Task {
            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                if session.isSignedIn {
                    let displayName = await getUserDisplayName()
                    await MainActor.run {
                        authManager.isAuthenticated = true
                        authManager.checkAuthenticationStatus()
                        showQuoteAndPrepare(displayName)
                    }
                }
            } catch {
                // No active session
            }
        }
    }
    
    private func getUserDisplayName() async -> String {
        // Try to get stored name first
        if let storedName = UserDefaults.standard.string(forKey: "monu_name"),
           !storedName.isEmpty {
            return storedName
        }
        
        // Try to get from user attributes
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            
            for attribute in attributes {
                if attribute.key == .name {
                    let name = attribute.value
                    UserDefaults.standard.set(name, forKey: "monu_name")
                    return name
                }
            }
            
            // Fallback to email
            for attribute in attributes {
                if attribute.key == .email {
                    return attribute.value
                }
            }
            
            return user.username
        } catch {
            return "there"
        }
    }
    
    private func showQuoteAndPrepare(_ name: String) {
        showAuthModal = false
        showVerification = false
        
        UserDefaults.standard.set(name, forKey: "monu_name")
        
        let randomQuote = quotes.randomElement() ?? quotes[0]
        let personalizedQuote = randomQuote.contains("{name}")
            ? randomQuote.replacingOccurrences(of: "{name}", with: name)
            : "\(randomQuote) — \(name)"
        
        quote = personalizedQuote
        
        print("🎯 Setting showQuote to true")
        withAnimation(.easeInOut(duration: 0.5)) {
            showQuote = true
        }
        print("🎯 showQuote is now: \(showQuote)")
    }
    
    private func handleSignUp(username: String, password: String, name: String) {
        Task {
            do {
                _ = try await Amplify.Auth.signUp(
                    username: username,
                    password: password,
                    options: AuthSignUpRequest.Options(
                        userAttributes: [
                            AuthUserAttribute(.email, value: username),
                            AuthUserAttribute(.name, value: name)
                        ]
                    )
                )
                
                await MainActor.run {
                    signupUser = username
                    signupPassword = password
                    UserDefaults.standard.set(name, forKey: "monu_name")
                    showAuthModal = false
                    showVerification = true
                }
            } catch {
                await MainActor.run {
                   
                }
            }
        }
    }
    
    private func handleSignIn(username: String, password: String) {
        Task {
            do {
                let result = try await Amplify.Auth.signIn(username: username, password: password)
                if result.isSignedIn {
                    let displayName = await getUserDisplayName()
                    await MainActor.run {
                        authManager.isAuthenticated = true
                        authManager.checkAuthenticationStatus()
                        showQuoteAndPrepare(displayName.isEmpty ? username : displayName)
                    }
                }
            } catch {
                await MainActor.run {
                    
                }
            }
        }
    }
    
    private func handleVerifyCode() {
        Task {
            do {
                _ = try await Amplify.Auth.confirmSignUp(
                    for: signupUser,
                    confirmationCode: verificationCode.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                let displayName = UserDefaults.standard.string(forKey: "monu_name") ?? signupUser
                await MainActor.run {
                    showQuoteAndPrepare(displayName)
                }
                
                // Auto sign in after confirmation
                let _ = try await Amplify.Auth.signIn(username: signupUser, password: signupPassword)
                
                await MainActor.run {
                    authManager.isAuthenticated = true
                    authManager.checkAuthenticationStatus()
                }
                
            } catch {
                if error.localizedDescription.contains("Current status is CONFIRMED") {
                    // Already confirmed, just proceed
                    let displayName = UserDefaults.standard.string(forKey: "monu_name") ?? signupUser
                    await MainActor.run {
                        showQuoteAndPrepare(displayName)
                    }
                    
                    // Auto sign in after confirmation
                    let _ = try await Amplify.Auth.signIn(username: signupUser, password: signupPassword)
                    
                    await MainActor.run {
                        authManager.isAuthenticated = true
                        authManager.checkAuthenticationStatus()
                    }
                } else {
                    await MainActor.run {
                        
                    }
                }
            }
        }
    }
}

// MARK: - Monu Button Component with Dark Mode
struct MonuButton: View {
    let title: String
    let backgroundColor: Color
    let borderColor: Color
    let textColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Georgia", size: 16))
                .fontWeight(.black)
                .foregroundColor(textColor)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(borderColor, lineWidth: 1.5)
                )
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 1, y: 1)
        }
        .buttonStyle(MonuButtonStyle())
    }
}

struct MonuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Custom Text Field with Dark Mode
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: KeyboardType = .default
    var isSecure: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    enum KeyboardType {
        case `default`
        case emailAddress
    }
    
    private var fieldBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : Color.white
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)
    }
    
    var body: some View {
        textFieldView
            .font(.custom("Georgia", size: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(fieldBackgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
    
    @ViewBuilder
    private var textFieldView: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
                .disableAutocorrection(true)
        } else {
            TextField(placeholder, text: $text)
                .disableAutocorrection(true)
            #if canImport(UIKit)
                .keyboardType(uiKeyboardType)
            #endif
        }
    }
    
    #if canImport(UIKit)
    private var uiKeyboardType: UIKeyboardType {
        switch keyboardType {
        case .default:
            return .default
        case .emailAddress:
            return .emailAddress
        }
    }
    #endif
}

