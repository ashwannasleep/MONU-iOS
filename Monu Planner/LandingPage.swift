import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

#if canImport(UIKit)
import UIKit
#endif

struct LandingPageView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var showQuote = false
    @State private var quote = ""
    @State private var showAuthModal = false
    @State private var authMode: AuthModal.AuthMode = .signIn
    @State private var showVerification = false
    @State private var verificationCode = ""
    @State private var signupUser = ""
    @State private var signupPassword = ""
    @State private var animateElements = false
    @State private var showQuoteAndButton = false
    @State private var isCheckingSession = true
    @State private var hasExistingSession = false

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

    // MARK: - Theming
    private var backgroundColor: Color { themeManager.backgroundColor }
    private var textColor: Color { themeManager.textColor }
    private var secondaryTextColor: Color { themeManager.secondaryTextColor }
    private var buttonBackgroundColor: Color { themeManager.buttonBackgroundColor }
    private var buttonBorderColor: Color { themeManager.buttonBorderColor }
    private var cardBackgroundColor: Color { themeManager.cardBackgroundColor }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.ignoresSafeArea()

                // Floating particles
                ForEach(0..<8, id: \.self) { index in
                    FloatingParticleView(
                        delay: Double(index) * 0.5,
                        isAnimating: animateElements
                    )
                }

                VStack(spacing: 20) {
                    Spacer()

                    // Main content container
                    VStack(spacing: 16) {
                        // Pixel MONU logo
                        VStack(spacing: 6) {
                            HStack(spacing: 2) {
                                PixelLetterView(letter: "M", delay: 0.0, isAnimating: animateElements)
                                PixelLetterView(letter: "O", delay: 0.1, isAnimating: animateElements)
                                PixelLetterView(letter: "N", delay: 0.2, isAnimating: animateElements)
                                PixelLetterView(letter: "U", delay: 0.3, isAnimating: animateElements)
                            }
                            Text("moment & you")
                                .font(.custom("Georgia", size: geometry.size.width < 400 ? 16 : 20))
                                .italic()
                                .foregroundColor(secondaryTextColor)
                                .opacity(animateElements ? 1 : 0)
                                .animation(.easeInOut(duration: 0.8).delay(0.4), value: animateElements)
                        }

                        Spacer().frame(height: 40)

                        // Content based on state
                        if isCheckingSession {
                            ProgressView()
                                .scaleEffect(0.8)
                                .opacity(0.6)
                        } else if showVerification {
                            verificationView
                        } else if authManager.isAuthenticated && showQuote {
                            quoteView
                        } else {
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
            .preferredColorScheme(themeManager.colorScheme)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) { animateElements = true }
            checkExistingSession()
        }
        #if os(iOS)
        .navigationBarBackButtonHidden(true)
        #endif
    }

    // MARK: - Subviews
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
            .disabled(authManager.isSigningOut || isCheckingSession)

            MonuButton(
                title: "Sign Up",
                backgroundColor: buttonBackgroundColor,
                borderColor: buttonBorderColor,
                textColor: textColor
            ) {
                authMode = .signUp
                showAuthModal = true
            }
            .disabled(authManager.isSigningOut || isCheckingSession)
        }
        .opacity(animateElements && !isCheckingSession && !hasExistingSession ? 1 : 0)
        .offset(y: animateElements && !isCheckingSession && !hasExistingSession ? 0 : 20)
        .animation(.easeInOut(duration: 0.8).delay(0.8),
                   value: animateElements && !isCheckingSession && !hasExistingSession)
    }

    private var quoteView: some View {
        VStack(spacing: 24) {
            Text(quote)
                .font(.custom("Georgia", size: 16))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .padding(.horizontal, 20)
                .opacity(showQuoteAndButton ? 1 : 0)
                .offset(y: showQuoteAndButton ? 0 : 20)
                .animation(.easeInOut(duration: 0.8), value: showQuoteAndButton)

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
            .opacity(showQuoteAndButton ? 1 : 0)
            .offset(y: showQuoteAndButton ? 0 : 20)
            .onAppear { print("🎯 Button appeared, showQuoteAndButton: \(showQuoteAndButton)") }
            .animation(.easeInOut(duration: 0.8).delay(0.3), value: showQuoteAndButton)
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

    // MARK: - Session flow
    private func checkExistingSession() {
        print("🔍 Checking existing session...")
        Task {
            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                print("🔍 Session found, isSignedIn: \(session.isSignedIn)")

                if session.isSignedIn {
                    let displayName = await getUserDisplayName()
                    await MainActor.run {
                        print("🔍 User is signed in, setting up authenticated state")
                        authManager.isAuthenticated = true
                        hasExistingSession = true
                        isCheckingSession = false
                        showQuoteAndPrepare(displayName)
                    }
                } else {
                    await MainActor.run {
                        print("🔍 No active session, showing auth buttons")
                        isCheckingSession = false
                        hasExistingSession = false
                    }
                }
            } catch {
                await MainActor.run {
                    print("🔍 Error checking session: \(error.localizedDescription)")
                    isCheckingSession = false
                    hasExistingSession = false
                }
            }
        }
    }

    private func getUserDisplayName() async -> String {
        if let storedName = UserDefaults.standard.string(forKey: "monu_name"),
           !storedName.isEmpty {
            return storedName
        }
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            let attributes = try await Amplify.Auth.fetchUserAttributes()

            for attribute in attributes where attribute.key == .name {
                let name = attribute.value
                UserDefaults.standard.set(name, forKey: "monu_name")
                return name
            }
            for attribute in attributes where attribute.key == .email {
                return attribute.value
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
        showQuote = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.8)) { showQuoteAndButton = true }
        }
        print("🎯 showQuote is now: \(showQuote), showQuoteAndButton will be: true")
    }

    // MARK: - Auth handlers
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
                    isCheckingSession = false
                    hasExistingSession = false
                }
            } catch {
                await MainActor.run {
                    isCheckingSession = false
                    hasExistingSession = false
                }
            }
        }
    }

    /// ✅ Guarded sign-in: checks session first to avoid "already signedIn state"
    private func handleSignIn(username: String, password: String) {
        Task {
            do {
                // Guard: skip signIn if SDK says we're already signed in
                let session = try await Amplify.Auth.fetchAuthSession()
                if session.isSignedIn {
                    let displayName = await getUserDisplayName()
                    await MainActor.run {
                        authManager.isAuthenticated = true
                        hasExistingSession = true
                        isCheckingSession = false
                        showQuoteAndPrepare(displayName.isEmpty ? username : displayName)
                    }
                    await authManager.checkAuthenticationStatus()
                    return
                }

                // Safe to sign in
                let result = try await Amplify.Auth.signIn(username: username, password: password)
                if result.isSignedIn {
                    let displayName = await getUserDisplayName()
                    await MainActor.run {
                        authManager.isAuthenticated = true
                        hasExistingSession = true
                        isCheckingSession = false
                        showQuoteAndPrepare(displayName.isEmpty ? username : displayName)
                    }
                    await authManager.checkAuthenticationStatus()
                }
            } catch {
                print("❌ Sign in failed: \(error.localizedDescription)")
                await MainActor.run {
                    isCheckingSession = false
                    hasExistingSession = false
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

                let _ = try await Amplify.Auth.signIn(username: signupUser, password: signupPassword)
                let displayName = UserDefaults.standard.string(forKey: "monu_name") ?? signupUser

                await MainActor.run {
                    authManager.isAuthenticated = true
                    hasExistingSession = true
                    isCheckingSession = false
                    showQuoteAndPrepare(displayName)
                }

                await authManager.checkAuthenticationStatus()

            } catch {
                if error.localizedDescription.contains("Current status is CONFIRMED") {
                    let _ = try? await Amplify.Auth.signIn(username: signupUser, password: signupPassword)
                    let displayName = UserDefaults.standard.string(forKey: "monu_name") ?? signupUser
                    await MainActor.run {
                        authManager.isAuthenticated = true
                        hasExistingSession = true
                        isCheckingSession = false
                        showQuoteAndPrepare(displayName)
                    }
                    await authManager.checkAuthenticationStatus()
                } else {
                    await MainActor.run {
                        isCheckingSession = false
                        hasExistingSession = false
                    }
                }
            }
        }
    }
}

// MARK: - Monu Button
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

// MARK: - Custom Text Field
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: KeyboardType = .default
    var isSecure: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    enum KeyboardType { case `default`, emailAddress }

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
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
    }

    @ViewBuilder
    private var textFieldView: some View {
        if isSecure {
            SecureField(placeholder, text: $text).disableAutocorrection(true)
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
        case .default: return .default
        case .emailAddress: return .emailAddress
        }
    }
    #endif
}

// MARK: - Pixel Letter
struct PixelLetterView: View {
    let letter: String
    let delay: Double
    let isAnimating: Bool

    @State private var isJumping = false
    @State private var showGlow = false
    @State private var isPulsing = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            Text(letter)
                .font(.custom("Georgia", size: 48))
                .fontWeight(.bold)
                .foregroundColor(themeManager.accentColor.opacity(0.3))
                .blur(radius: 8)
                .scaleEffect(showGlow ? 1.2 : 1.0)
                .opacity(showGlow ? 1 : 0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                           value: showGlow)

            Text(letter)
                .font(.custom("Georgia", size: 48))
                .fontWeight(.bold)
                .foregroundColor(themeManager.textColor)
                .scaleEffect(isJumping ? 1.1 : (isPulsing ? 1.05 : 1.0))
                .offset(y: isJumping ? -8 : 0)
                
        }
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1.0 : 0.5)
        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(delay), value: isAnimating)
        .onAppear {
            if isAnimating {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
                    isJumping = true
                    showGlow = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 1.5) {
                    isPulsing = true
                }
            }
        }
    }
}

// MARK: - Floating Particle
struct FloatingParticleView: View {
    let delay: Double
    let isAnimating: Bool

    @State private var offset = CGSize.zero
    @State private var opacity: Double = 0
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Circle()
            .fill(themeManager.accentColor.opacity(0.3))
            .frame(width: 4, height: 4)
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                if isAnimating {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                            offset = CGSize(width: CGFloat.random(in: -50...50),
                                            height: CGFloat.random(in: -100...100))
                            opacity = 1
                        }
                    }
                }
            }
    }
}

