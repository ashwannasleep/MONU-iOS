import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

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
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture { dismiss(); onClose() }

            modalContent
                .background(themeManager.colorScheme == .dark
                            ? Color(red: 0.18, green: 0.18, blue: 0.18)
                            : Color(red: 0.97, green: 0.96, blue: 0.94))
                .cornerRadius(32)
                .shadow(color: Color.black.opacity(0.1), radius: 25, x: 0, y: 25)
                .padding(.horizontal, 16)
                .animation(.easeOut(duration: 0.25), value: mode)
        }
        .onChange(of: mode) { _ in message = "" }
    }

    private var modalContent: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("×") { dismiss(); onClose() }
                    .font(.title2)
                    .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.27, green: 0.27, blue: 0.27))
                    .padding(.top, 12)
                    .padding(.trailing, 12)
            }

            Text(mode.rawValue)
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                .padding(.bottom, 20)
                .padding(.top, -4)

            VStack(spacing: 12) {
                formContent

                if shouldShowSubmitButton {
                    AuthButton(title: submitButtonTitle, loading: loading, action: handleSubmit)
                        .opacity(isSubmitDisabled ? 0.6 : 1)
                        .disabled(loading || isSubmitDisabled)
                        .padding(.top, 4)
                }

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
                            mode = (mode == .signIn ? .signUp : .signIn)
                        }
                        .authLinkStyle()
                    }
                }
                .padding(.top, 8)

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
            if mode == .signUp {
                AuthTextField(placeholder: "Name", text: $fullName, keyboardType: .default)
            }
            if mode != .resetPassword {
                AuthTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
            }
            if mode == .signIn || mode == .signUp {
                AuthTextField(placeholder: "Password", text: $password, isSecure: true)
            }
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
                .disabled(loading || emailTrimmed.isEmpty)
                .opacity((loading || emailTrimmed.isEmpty) ? 0.6 : 1)
            }
            if mode == .resetPassword {
                Text("Enter the code sent to \(email) and your new password:")
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(themeManager.colorScheme == .dark ? .white : Color(red: 0.23, green: 0.23, blue: 0.23))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                AuthTextField(placeholder: "Reset Code", text: $resetCode, keyboardType: .default)
                AuthTextField(placeholder: "New Password", text: $newPassword, isSecure: true)
            }
        }
    }

    // MARK: - Computed
    private var shouldShowSubmitButton: Bool {
        mode == .signIn || mode == .signUp || mode == .resetPassword
    }

    private var submitButtonTitle: String {
        if loading { return "Please wait…" }
        switch mode {
        case .signIn: return "Sign In"
        case .signUp: return "Sign Up"
        case .resetPassword: return "Reset Password"
        case .forgotPassword: return ""
        }
    }

    private var isSubmitDisabled: Bool {
        switch mode {
        case .signIn:
            return emailTrimmed.isEmpty || password.isEmpty
        case .signUp:
            return emailTrimmed.isEmpty || password.isEmpty
        case .resetPassword:
            return emailTrimmed.isEmpty
                || resetCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || newPassword.isEmpty
        case .forgotPassword:
            return true
        }
    }

    private var emailTrimmed: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func resetAll() {
        email = ""; password = ""; fullName = ""; resetCode = ""; newPassword = ""; message = ""
    }

    // MARK: - Actions
    private func handleSendCode() {
        guard !emailTrimmed.isEmpty else {
            message = "Please enter your email address"
            return
        }
        Task {
            await MainActor.run { loading = true; message = "" }
            do {
                _ = try await Amplify.Auth.resetPassword(for: emailTrimmed)
                await MainActor.run {
                    mode = .resetPassword
                    message = "Code sent! Check your email."
                    loading = false
                }
            } catch {
                await MainActor.run {
                    message = messageForAuthError(error, context: .forgotPassword)
                    loading = false
                }
            }
        }
    }

    private func handleSubmit() {
        Task { await performSubmit() }
    }

    private func performSubmit() async {
        await MainActor.run { loading = true; message = "" }
        do {
            switch mode {
            case .signIn:
                let res = try await Amplify.Auth.signIn(username: emailTrimmed, password: password)
                if res.isSignedIn {
                    UserDefaults.standard.set(emailTrimmed, forKey: "user_email")
                    await MainActor.run {
                        loading = false
                        onSignIn(emailTrimmed, password)
                        dismiss(); onClose()
                    }
                } else {
                    await MainActor.run {
                        loading = false
                        message = "Sign in not completed. Please try again."
                    }
                }

            case .signUp:
                var attrs: [AuthUserAttribute] = [AuthUserAttribute(.email, value: emailTrimmed)]
                let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedName.isEmpty { attrs.append(AuthUserAttribute(.name, value: trimmedName)) }

                let options = AuthSignUpRequest.Options(userAttributes: attrs)
                let signUpRes = try await Amplify.Auth.signUp(
                    username: emailTrimmed,
                    password: password,
                    options: options
                )

                if !trimmedName.isEmpty { UserDefaults.standard.set(trimmedName, forKey: "monu_name") }
                UserDefaults.standard.set(emailTrimmed, forKey: "user_email")

                switch signUpRes.nextStep {
                case .confirmUser: // destination type varies by SDK; don't pattern-match fields
                    await MainActor.run {
                        loading = false
                        message = "We sent a verification code. Check your inbox or SMS and enter it to finish sign up."
                    }

                case .done:
                    let signInRes = try await Amplify.Auth.signIn(username: emailTrimmed, password: password)
                    await MainActor.run {
                        loading = false
                        if signInRes.isSignedIn {
                            onSignUp(emailTrimmed, password, trimmedName)
                            dismiss(); onClose()
                        } else {
                            message = "Account created. Please sign in."
                            mode = .signIn
                        }
                    }

                @unknown default:
                    await MainActor.run {
                        loading = false
                        message = "Check your email for a verification code to complete sign up."
                    }
                }

            case .forgotPassword:
                break // handled in handleSendCode()

            case .resetPassword:
                _ = try await Amplify.Auth.confirmResetPassword(
                    for: emailTrimmed,
                    with: newPassword,
                    confirmationCode: resetCode.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                await MainActor.run {
                    message = "Password reset successfully! You can now sign in."
                    mode = .signIn
                    password = ""; newPassword = ""; resetCode = ""
                    loading = false
                }
            }
        } catch {
            await MainActor.run {
                message = messageForAuthError(error, context: mode)
                loading = false
            }
        }
    }

    // MARK: - Error mapping
    private func messageForAuthError(_ error: Error, context: AuthMode) -> String {
        if let authError = error as? AuthError {
            switch authError {
            case .service(let message, let suggestion, let underlying):
                let full = [message, suggestion, underlying?.localizedDescription].compactMap { $0 }.joined(separator: " ")
                if full.localizedCaseInsensitiveContains("UsernameExistsException") {
                    return "An account with that email already exists. Try signing in."
                }
                if full.localizedCaseInsensitiveContains("UserNotFoundException") {
                    return "No account found for that email. Double-check it or sign up."
                }
                if full.localizedCaseInsensitiveContains("NotAuthorizedException")
                    || full.localizedCaseInsensitiveContains("incorrect username or password") {
                    return "Incorrect email or password. Try again or reset your password."
                }
                if full.localizedCaseInsensitiveContains("UserNotConfirmedException") {
                    return "Your email isn’t confirmed yet. Check your inbox for the verification code."
                }
                return message.isEmpty ? "Something went wrong. Please try again." : message

            case .invalidState:
                return "Something went wrong with the current auth state. Please try again."
            case .notAuthorized:
                return "Incorrect email or password. Try again or reset your password."
            default:
                return authError.errorDescription
            }
        }
        return error.localizedDescription.isEmpty ? "Unexpected error. Please try again." : error.localizedDescription
    }
}

// MARK: - Auth Text Field
struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: AuthKeyboardType = .default
    var isSecure: Bool = false

    enum AuthKeyboardType { case `default`, emailAddress }

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        textFieldView
            .font(.custom("Georgia", size: 15))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(themeManager.colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.84, green: 0.83, blue: 0.8), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 2)
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

// MARK: - Auth Button
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
                .background(Color(red: 0.78, green: 0.75, blue: 0.7))
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

// MARK: - Link Style
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
        onSignIn: { email, _ in print("Sign in: \(email)") },
        onSignUp: { email, _, name in print("Sign up: \(email), \(name)") },
        onClose: { print("Modal closed") }
    )
    .environmentObject(ThemeManager.shared)
}

