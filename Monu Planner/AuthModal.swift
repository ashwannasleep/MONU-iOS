import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import GoogleSignIn

struct AuthModal: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var mode: AuthMode
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var resetCode = ""
    @State private var newPassword = ""
    @State private var message = ""
    @State private var loading = false
    
    let onSignIn: (String, String) -> Void
    let onSignUp: (String, String, String) -> Void
    let onClose: () -> Void
    
    enum AuthMode: String, CaseIterable {
        case signIn = "Sign In"
        case signUp = "Sign Up"
        case forgotPassword = "Forgot Password"
        case resetPassword = "Reset Password"
    }
    
    init(
        initialMode: AuthMode = .signIn,
        onSignIn: @escaping (String, String) -> Void,
        onSignUp: @escaping (String, String, String) -> Void,
        onClose: @escaping () -> Void
    ) {
        self._mode = State(initialValue: initialMode)
        self.onSignIn = onSignIn
        self.onSignUp = onSignUp
        self.onClose = onClose
    }
    
    var body: some View {
        ZStack {
            // Overlay background
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                    onClose()
                }
            
            // Modal content
            modalContent
                .background(themeManager.colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red: 0.97, green: 0.96, blue: 0.94)) // #f7f5ef
                .cornerRadius(32)
                .shadow(color: Color.black.opacity(0.1), radius: 25, x: 0, y: 25)
                .padding(.horizontal, 16)
                .scaleEffect(1.0)
                .animation(.easeOut(duration: 0.25), value: mode)
        }
        .onChange(of: mode) { oldValue, newValue in
            message = ""
        }
    }
    
    private var modalContent: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Spacer()
                Button("×") {
                    dismiss()
                    onClose()
                }
                .font(.title2)
                .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.27, green: 0.27, blue: 0.27))
                .background(Color.clear)
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
            
            // Title
            Text(mode.rawValue)
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                .padding(.bottom, 20)
                .padding(.top, -4)
            
            // Form content
            VStack(spacing: 12) {
                formContent
                
                // Google Sign-In button (for sign in mode)
                if mode == .signIn {
                    VStack(spacing: 12) {
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("or")
                                .font(.custom("Georgia", size: 12))
                                .foregroundColor(.secondary)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.secondary.opacity(0.3))
                        }
                        
                        Button(action: handleGoogleSignIn) {
                            HStack(spacing: 8) {
                                Image(systemName: "globe")
                                    .font(.system(size: 16))
                                Text("Continue with Google")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(themeManager.colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(themeManager.colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(loading)
                    }
                    .padding(.top, 8)
                }
                
                // Submit button (when applicable)
                if shouldShowSubmitButton {
                    AuthButton(
                        title: submitButtonTitle,
                        loading: loading,
                        action: handleSubmit
                    )
                    .padding(.top, 4)
                }
                
                // Toggle links
                VStack(spacing: 6) {
                    if mode == .signIn {
                        Button("Forgot Password?") {
                            resetAll()
                            mode = .forgotPassword
                        }
                        .authLinkStyle()
                    }
                    
                    HStack {
                        Text(mode == .signIn ? "Don't have an account?" : "Already have an account?")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.23, green: 0.23, blue: 0.23))
                        
                        Button(mode == .signIn ? "Sign Up" : "Sign In") {
                            resetAll()
                            mode = mode == .signIn ? .signUp : .signIn
                        }
                        .authLinkStyle()
                    }
                }
                .padding(.top, 8)
                
                // Message display
                if !message.isEmpty {
                    Text(message)
                        .font(.custom("Georgia", size: 13))
                        .foregroundColor(message.contains("successfully") || message.contains("sent") ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: 360)
        .frame(minWidth: 280)
    }
    
    @ViewBuilder
    private var formContent: some View {
        VStack(spacing: 12) {
            // Name field for sign up
            if mode == .signUp {
                AuthTextField(
                    placeholder: "Name",
                    text: $fullName,
                    keyboardType: .default
                )
            }
            
            // Email field (not shown in reset password mode)
            if mode != .resetPassword {
                AuthTextField(
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress
                )
            }
            
            // Password field for sign in/sign up
            if mode == .signIn || mode == .signUp {
                AuthTextField(
                    placeholder: "Password",
                    text: $password,
                    isSecure: true
                )
            }
            
            // Forgot password info and button
            if mode == .forgotPassword {
                Text("We'll send a reset code to your email.")
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.23, green: 0.23, blue: 0.23))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                
                AuthButton(
                    title: loading ? "Sending…" : "Send Code",
                    loading: loading,
                    action: handleSendCode
                )
            }
            
            // Reset password fields
            if mode == .resetPassword {
                Text("Enter the code sent to \(email) and your new password:")
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.23, green: 0.23, blue: 0.23))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                
                AuthTextField(
                    placeholder: "Reset Code",
                    text: $resetCode,
                    keyboardType: .default
                )
                
                AuthTextField(
                    placeholder: "New Password",
                    text: $newPassword,
                    isSecure: true
                )
            }
        }
    }
    
    private var shouldShowSubmitButton: Bool {
        mode == .signIn || mode == .signUp || mode == .resetPassword
    }
    
    private var submitButtonTitle: String {
        if loading {
            return "Please wait…"
        }
        
        switch mode {
        case .signIn:
            return "Sign In"
        case .signUp:
            return "Sign Up"
        case .resetPassword:
            return "Reset Password"
        case .forgotPassword:
            return "" // Handled separately
        }
    }
    
    private func resetAll() {
        email = ""
        password = ""
        fullName = ""
        resetCode = ""
        newPassword = ""
        message = ""
    }
    
    private func handleSendCode() {
        guard !email.isEmpty else {
            message = "Please enter your email address"
            return
        }
        
        Task {
            await MainActor.run {
                loading = true
                message = ""
            }
            
            do {
                let _ = try await Amplify.Auth.resetPassword(for: email.trimmingCharacters(in: .whitespacesAndNewlines))
                await MainActor.run {
                    mode = .resetPassword
                    message = "Code sent! Check your email."
                    loading = false
                }
            } catch {
                await MainActor.run {
                    message = error.localizedDescription
                    loading = false
                }
            }
        }
    }
    
    private func handleSubmit() {
        Task {
            await MainActor.run {
                loading = true
                message = ""
            }
            
            do {
                switch mode {
                case .signIn:
                    await MainActor.run {
                        loading = false
                        onSignIn(email.trimmingCharacters(in: .whitespacesAndNewlines), password)
                        dismiss()
                        onClose()
                    }
                    
                case .signUp:
                    await MainActor.run {
                        loading = false
                        onSignUp(
                            email.trimmingCharacters(in: .whitespacesAndNewlines),
                            password,
                            fullName.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        dismiss()
                        onClose()
                    }
                    
                case .forgotPassword:
                    let _ = try await Amplify.Auth.resetPassword(for: email.trimmingCharacters(in: .whitespacesAndNewlines))
                    await MainActor.run {
                        message = "Code sent! Check your email."
                        mode = .resetPassword
                        loading = false
                    }
                    
                case .resetPassword:
                    let _ = try await Amplify.Auth.confirmResetPassword(
                        for: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        with: newPassword,
                        confirmationCode: resetCode.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    await MainActor.run {
                        message = "Password reset successfully! You can now sign in."
                        mode = .signIn
                        password = ""
                        newPassword = ""
                        resetCode = ""
                        loading = false
                    }
                }
            } catch {
                await MainActor.run {
                    message = error.localizedDescription
                    loading = false
                }
            }
        }
    }
    
    // MARK: - Google Sign-In
    private func handleGoogleSignIn() {
        Task {
            await MainActor.run {
                loading = true
                message = ""
            }
            
            do {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first else {
                    await MainActor.run {
                        message = "Unable to present Google Sign-In"
                        loading = false
                    }
                    return
                }
                
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: window.rootViewController!)
                
                let user = result.user
                guard let idToken = user.idToken?.tokenString else {
                    await MainActor.run {
                        message = "Failed to get user token from Google"
                        loading = false
                    }
                    return
                }
                
                // Sign in to Amplify with Google token
                let amplifyResult = try await Amplify.Auth.signInWithWebUI(for: .google)
                
                // Save the user's name and email
                if let userName = user.profile?.name {
                    UserDefaults.standard.set(userName, forKey: "monu_name")
                }
                if let userEmail = user.profile?.email {
                    UserDefaults.standard.set(userEmail, forKey: "user_email")
                }
                
                await MainActor.run {
                    loading = false
                    message = "Successfully signed in with Google!"
                    dismiss()
                    onClose()
                }
                
            } catch {
                await MainActor.run {
                    message = "Google Sign-In failed: \(error.localizedDescription)"
                    loading = false
                }
            }
        }
    }
}

// MARK: - Auth Text Field Component
struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: AuthKeyboardType = .default
    var isSecure: Bool = false
    
    enum AuthKeyboardType {
        case `default`
        case emailAddress
    }
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        textFieldView
            .font(.custom("Georgia", size: 15))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(themeManager.colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.84, green: 0.83, blue: 0.8), lineWidth: 2) // #d6d3cd
            )
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 2)
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

// MARK: - Auth Button Component
struct AuthButton: View {
    let title: String
    let loading: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Georgia", size: 15))
                .fontWeight(.semibold)
                .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.1, green: 0.1, blue: 0.1))
                .frame(maxWidth: 180)
                .frame(minHeight: 40)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color(red: 0.78, green: 0.75, blue: 0.7)) // #c7bfb2
                .cornerRadius(20)
        }
        .disabled(loading)
        .opacity(loading ? 0.7 : 1.0)
        .buttonStyle(AuthButtonStyle())
    }
}

struct AuthButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Link Style Extension
extension Button {
    func authLinkStyle() -> some View {
        self
            .font(.custom("Georgia", size: 14))
            .fontWeight(.medium)
            .foregroundColor(Color(red: 0.23, green: 0.23, blue: 0.23))
            .underline()
    }
}


// MARK: - Preview
#Preview {
    AuthModal(
        initialMode: .signIn,
        onSignIn: { email, password in
            print("Sign in: \(email)")
        },
        onSignUp: { email, password, name in
            print("Sign up: \(email), \(name)")
        },
        onClose: {
            print("Modal closed")
        }
    )
}
