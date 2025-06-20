import SwiftUI
import Amplify

struct SettingsPage: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) private var colorScheme

    // Editing state
    @State private var showEditName = false
    @State private var showChangePassword = false
    @State private var newName = ""
    @State private var currentName = ""
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var message = ""
    @State private var showMessage = false
    
    // Computed colors for theming
    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.12, blue: 0.12)
            : Color(red: 0.97, green: 0.96, blue: 0.94)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    
    private var accentColor: Color {
        Color(red: 0.84, green: 0.80, blue: 0.76)
    }

    var body: some View {
        ZStack {
            // Full-screen Monu background
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Button(action: {
                    navigationManager.navigateToRoot() // Goes to Choose page
                }){
                    VStack(spacing: 4) {
                        Text(languageManager.localizedString(.appName))
                            .font(.system(size: 34, weight: .regular, design: .serif))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                        Text(languageManager.localizedString(.appTagline))
                            .font(.system(size: 16, design: .serif))
                            .italic()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top)

                // Theme section
                VStack(spacing: 12) {
                    Text(languageManager.localizedString(.theme))
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundColor(textColor)
                    HStack {
                        Text(isDarkMode ? languageManager.localizedString(.darkMode) : languageManager.localizedString(.lightMode))
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(textColor)
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.95, green: 0.62, blue: 0.56)))
                            .labelsHidden()
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 300)
                }
                .padding(.top, 30)

                // Language section
                VStack(spacing: 12) {
                    Text(languageManager.localizedString(.language))
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundColor(textColor)
                    
                    VStack(spacing: 8) {
                        ForEach(LanguageManager.Language.allCases, id: \.self) { language in
                            Button(action: {
                                languageManager.setLanguage(language)
                            }) {
                                HStack {
                                    Text(language.flag)
                                        .font(.system(size: 20))
                                    
                                    Text(language.displayName)
                                        .font(.system(size: 16, design: .serif))
                                        .foregroundColor(textColor)
                                    
                                    Spacer()
                                    
                                    if languageManager.currentLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
                                            .font(.system(size: 18))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(languageManager.currentLanguage == language ? Color(red: 0.95, green: 0.62, blue: 0.56) : accentColor, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(maxWidth: 300)
                }
                .padding(.top, 20)

                // Account section
                VStack(spacing: 16) {
                    Text(languageManager.localizedString(.account))
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundColor(textColor)
                        .padding(.top, 30)

                    if !currentName.isEmpty {
                        Text("Signed in as: \(currentName)")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(textColor.opacity(0.7))
                    }

                    // Change Name
                    Button {
                        newName = currentName
                        showEditName = true
                    } label: {
                        Label(languageManager.localizedString(.changeName), systemImage: "person.circle")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(textColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accentColor, lineWidth: 1)
                            )
                    }

                    // Change Password
                    Button {
                        showChangePassword = true
                    } label: {
                        Label(languageManager.localizedString(.changePassword), systemImage: "lock.circle")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(textColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accentColor, lineWidth: 1)
                            )
                    }

                    // Notifications
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label(languageManager.localizedString(.notifications), systemImage: "bell")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(textColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accentColor, lineWidth: 1)
                            )
                    }
                    
                    // Sign Out - Updated to use navigationManager
                    Button {
                        authManager.signOut(navigationManager: navigationManager)
                    } label: {
                        Label(languageManager.localizedString(.signOut), systemImage: "arrow.right.square")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(textColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accentColor, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: 350)

                Spacer()

                Link(languageManager.localizedString(.privacyPolicy),
                     destination: URL(string: "https://ashwannasleep.github.io/monu-privacy/")!)
                    .font(.system(size: 12, design: .serif))
                    .underline()
                    .foregroundColor(textColor.opacity(0.7))
                    .padding(.bottom)
            }
            .padding(20)

            // Overlays
            if showEditName { editNameOverlay }
            if showChangePassword { changePasswordOverlay }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear { loadCurrentUserName() }
        .alert("Message", isPresented: $showMessage) {
            Button("OK") { showMessage = false }
        } message: {
            Text(message)
        }
    }

    // MARK: - Edit Name Overlay
    private var editNameOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showEditName = false }

            VStack(spacing: 20) {
                Text(languageManager.localizedString(.changeName))
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(.black) // Always dark text in popup

                TextField("Enter new name", text: $newName)
                    .font(.system(size: 16, design: .serif))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .disableAutocorrection(true)

                HStack(spacing: 20) {
                    Button("Cancel") {
                        showEditName = false
                        newName = ""
                    }
                    .foregroundColor(.gray)

                    Button("Save") {
                        updateName()
                    }
                    .disabled(newName.isEmpty || newName == currentName || isLoading)
                    .foregroundColor(.blue)
                }
                .font(.system(size: 16, design: .serif))
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Change Password Overlay
    private var changePasswordOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isLoading {
                        showChangePassword = false
                        clearPasswordFields()
                    }
                }

            VStack(spacing: 16) {
                Text(languageManager.localizedString(.changePassword))
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(.black) // Always dark text in popup

                SecureField("Current password", text: $oldPassword)
                    .fieldStyle()
                SecureField("New password", text: $newPassword)
                    .fieldStyle()
                SecureField("Confirm new password", text: $confirmPassword)
                    .fieldStyle()

                if newPassword != confirmPassword && !confirmPassword.isEmpty {
                    Text("Passwords don't match")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(.red)
                }

                HStack(spacing: 20) {
                    Button("Cancel") {
                        showChangePassword = false
                        clearPasswordFields()
                    }
                    .disabled(isLoading)
                    .foregroundColor(.gray)

                    Button("Update") {
                        updatePassword()
                    }
                    .disabled(!isPasswordValid || isLoading)
                    .foregroundColor(.blue)
                }
                .font(.system(size: 16, design: .serif))
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Helpers
    private var isPasswordValid: Bool {
        !oldPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }

    private func loadCurrentUserName() {
        if let stored = UserDefaults.standard.string(forKey: "monu_name"), !stored.isEmpty {
            currentName = stored
            return
        }
        Task {
            do {
                let attrs = try await Amplify.Auth.fetchUserAttributes()
                if let name = attrs.first(where: { $0.key == .name })?.value {
                    await MainActor.run {
                        currentName = name
                        UserDefaults.standard.set(name, forKey: "monu_name")
                    }
                }
            } catch {
                print("Error loading user name: \(error)")
            }
        }
    }

    private func updateName() {
        isLoading = true
        Task {
            do {
                try await Amplify.Auth.update(userAttribute: AuthUserAttribute(.name, value: newName))
                await MainActor.run {
                    currentName = newName
                    UserDefaults.standard.set(newName, forKey: "monu_name")
                    message = "Name updated!"
                    showMessage = true
                    showEditName = false
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    message = error.localizedDescription
                    showMessage = true
                    isLoading = false
                }
            }
        }
    }

    private func updatePassword() {
        isLoading = true
        Task {
            do {
                try await Amplify.Auth.update(oldPassword: oldPassword, to: newPassword)
                await MainActor.run {
                    message = "Password updated!"
                    showMessage = true
                    showChangePassword = false
                    clearPasswordFields()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    message = error.localizedDescription
                    showMessage = true
                    isLoading = false
                }
            }
        }
    }

    private func clearPasswordFields() {
        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}

// MARK: - SecureField Styling
private extension SecureField where Label == Text {
    func fieldStyle() -> some View {
        self
            .font(.system(size: 16, design: .serif))
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
}


