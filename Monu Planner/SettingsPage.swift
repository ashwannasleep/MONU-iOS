import SwiftUI
import Amplify

struct SettingsPage: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var calendarSyncManager = CalendarSyncManager()
    @StateObject private var notificationManager = NotificationManager.shared

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
        themeManager.backgroundColor
    }
    
    private var textColor: Color {
        themeManager.textColor
    }
    
    private var accentColor: Color {
        themeManager.accentColor
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MONU Header
                header
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User Profile Section
                        userProfileSection
                        
                        // Theme Settings Section
                        themeSettingsSection
                        
                        // Calendar Settings Section
                        calendarSettingsSection
                        
                        // Notification Settings Section
                        notificationSettingsSection
                        
                        // App Info Section
                        appInfoSection
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showEditName) {
            editNameSheet
        }
        .sheet(isPresented: $showChangePassword) {
            changePasswordSheet
        }
        .alert("Message", isPresented: $showMessage) {
            Button("OK") { }
        } message: {
            Text(message)
        }
        .onAppear {
            // Refresh user data when settings page appears
            print("📧 Settings: Current user: \(authManager.currentUser?.username ?? "nil")")
            print("📧 Settings: UserDefaults email: \(UserDefaults.standard.string(forKey: "user_email") ?? "nil")")
        }
        .onChange(of: notificationManager.notificationSettings) { _ in
            notificationManager.saveSettings()
        }
    }
    
    // MARK: - Header View
    private var header: some View {
        VStack(spacing: 0) {
            Button { navigationManager.navigateToRoot() } label: {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textColor)
            }
            .buttonStyle(.plain)
            .padding(.top, 48)
            .padding(.bottom, 8)
            
            Text("Customize your experience")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }
    
    // MARK: - User Profile Section
    private var userProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textColor)
            
            VStack(spacing: 12) {
                // User Info
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.accentColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(getUserDisplayName())
                            .font(.custom("Georgia", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.textColor)
                        
                        Text(getUserEmail())
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                        
                        // Debug info (remove in production)
                        if getUserEmail() == "Not signed in" || getUserEmail().contains("No email found") {
                            Text("Tap to refresh email")
                                .font(.custom("Georgia", size: 12))
                                .foregroundColor(themeManager.accentColor)
                                .onTapGesture {
                                    // Force refresh by updating UserDefaults
                                    if let user = authManager.currentUser {
                                        UserDefaults.standard.set(user.username, forKey: "user_email")
                                    }
                                }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                
                // Edit Name Button
                Button(action: {
                    currentName = authManager.currentUser?.username ?? ""
                    newName = currentName
                    showEditName = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 24)
                        
                        Text("Edit Name")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(themeManager.cardBackgroundColor)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Change Password Button
                Button(action: {
                    showChangePassword = true
                }) {
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 24)
                        
                        Text("Change Password")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(themeManager.cardBackgroundColor)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    Task {
                        await authManager.signOut()
                        await MainActor.run {
                            // Clear navigation
                            navigationManager.navigationPath.removeAll()
                            
                            // Reset auth state
                            authManager.isAuthenticated = false
                            
                            // Clear user data
                            UserDefaults.standard.removeObject(forKey: "user_email")
                            UserDefaults.standard.removeObject(forKey: "monu_name")
                        }
                    }
                
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Sign Out")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(themeManager.cardBackgroundColor)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Theme Settings Section
    private var themeSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Theme")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textColor)
            
            VStack(spacing: 12) {
                // Dark Mode Toggle
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    Text("Dark Mode")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    Toggle("", isOn: $themeManager.isDarkMode)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                        .onChange(of: themeManager.isDarkMode) { _ in
                            themeManager.toggleTheme()
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                
                // Theme Color Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Accent Color")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(themeManager.textColor)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(ThemeColor.allCases, id: \.self) { color in
                            ThemeColorButton(
                                themeColor: color,
                                isSelected: themeManager.selectedThemeColor == color,
                                onTap: {
                                    themeManager.setThemeColor(color)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
            }
        }
    }
    

    
    // MARK: - Calendar Settings Section
    private var calendarSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calendar")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textColor)
            
            VStack(spacing: 12) {
                // Apple Calendar
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Apple Calendar")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Text(calendarSyncManager.useApple ? "Connected" : "Not connected")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $calendarSyncManager.useApple)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                
                // Google Calendar
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Google Calendar")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Text(calendarSyncManager.useGoogle ? "Connected" : "Not connected")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $calendarSyncManager.useGoogle)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Notification Settings Section
    private var notificationSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textColor)
            
            VStack(spacing: 12) {
                // Authorization Status
                HStack {
                    Image(systemName: notificationManager.isAuthorized ? "bell.fill" : "bell.slash")
                        .foregroundColor(notificationManager.isAuthorized ? .green : .orange)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(notificationManager.isAuthorized ? "Notifications Enabled" : "Notifications Disabled")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Text(notificationManager.isAuthorized ? "You'll receive helpful reminders" : "Enable notifications to get reminders")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    if !notificationManager.isAuthorized {
                        Button("Enable") {
                            Task {
                                await notificationManager.requestAuthorization()
                            }
                        }
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(themeManager.accentColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                
                // Daily Reminders
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "sunrise")
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Reminders")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(themeManager.textColor)
                            
                            Text("Plan your day ahead")
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationManager.notificationSettings.dailyReminders)
                            .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                            .disabled(!notificationManager.isAuthorized)
                    }
                    
                    if notificationManager.notificationSettings.dailyReminders {
                        HStack {
                            Text("Reminder Time")
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            Spacer()
                            
                            DatePicker("", selection: $notificationManager.notificationSettings.dailyReminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(themeManager.colorScheme)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                
                // Habit Reminders
                HStack {
                    Image(systemName: "repeat")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Habit Reminders")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Text("Track your daily habits")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationManager.notificationSettings.habitReminders)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                        .disabled(!notificationManager.isAuthorized)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                
                // Weekly Progress
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly Progress")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Text("Review your weekly achievements")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationManager.notificationSettings.weeklyProgress)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                        .disabled(!notificationManager.isAuthorized)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                
                // Goal Reminders
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Goal Reminders")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Text("Stay on track with your goals")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationManager.notificationSettings.goalReminders)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                        .disabled(!notificationManager.isAuthorized)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                
                // Mindfulness Reminders
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mindfulness Reminders")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(themeManager.textColor)
                        
                        Text("Take mindful breaks")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationManager.notificationSettings.mindfulnessReminders)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                        .disabled(!notificationManager.isAuthorized)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textColor)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Version")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(8)
                
                HStack {
                    Text("Build")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    Text("1")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Edit Name Sheet
    private var editNameSheet: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Edit Your Name")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textColor)
                    
                    TextField("Enter your name", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Georgia", size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(8)
                    
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            showEditName = false
                            newName = currentName
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(themeManager.textColor)
                        
                        Button("Save") {
                            Task {
                                await updateName()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(themeManager.accentColor)
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Change Password Sheet
    private var changePasswordSheet: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Change Password")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textColor)
                    
                    SecureField("Current Password", text: $oldPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Georgia", size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(8)
                    
                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Georgia", size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(8)
                    
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Georgia", size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(8)
                    
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            showChangePassword = false
                            oldPassword = ""
                            newPassword = ""
                            confirmPassword = ""
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(themeManager.textColor)
                        
                        Button("Change Password") {
                            Task {
                                await changePassword()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(themeManager.accentColor)
                        .disabled(newPassword.isEmpty || confirmPassword.isEmpty || oldPassword.isEmpty || newPassword != confirmPassword)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Helper Functions
    private func getUserDisplayName() -> String {
        // Use the stored display name from UserDefaults
        return UserDefaults.standard.string(forKey: "monu_name") ?? "User"
    }
    
    private func getUserEmail() -> String {
        guard let user = authManager.currentUser else { return "Not signed in" }
        
        // Try to get email from UserDefaults first (stored during sign-up/sign-in)
        if let storedEmail = UserDefaults.standard.string(forKey: "user_email"), !storedEmail.isEmpty {
            print("📧 Settings: Found email in UserDefaults: \(storedEmail)")
            return storedEmail
        }
        
        // Check if username looks like an email (contains @)
        if user.username.contains("@") {
            print("📧 Settings: Username appears to be email: \(user.username)")
            return user.username
        }
        
        // Fallback to username if no email is available
        print("📧 Settings: No email found, using username: \(user.username)")
        return user.username
    }
    private func updateName() async {
        isLoading = true
        
        do {
            // Update the stored name
            UserDefaults.standard.set(newName, forKey: "monu_name")
            
            await MainActor.run {
                message = "Name updated successfully!"
                showMessage = true
                showEditName = false
                isLoading = false
            }
        } catch {
            await MainActor.run {
                message = "Failed to update name: \(error.localizedDescription)"
                showMessage = true
                isLoading = false
            }
        }
    }
    
    private func changePassword() async {
        isLoading = true
        
        do {
            // Here you would implement the actual password change logic
            // For now, we'll just show a success message
            await MainActor.run {
                message = "Password change functionality will be implemented soon!"
                showMessage = true
                showChangePassword = false
                oldPassword = ""
                newPassword = ""
                confirmPassword = ""
                isLoading = false
            }
        } catch {
            await MainActor.run {
                message = "Failed to change password: \(error.localizedDescription)"
                showMessage = true
                isLoading = false
            }
        }
    }
}



// MARK: - Theme Color Button
struct ThemeColorButton: View {
    let themeColor: ThemeColor
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(themeColor.color)
                        .frame(width: 40, height: 40)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(themeColor.displayName)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(themeManager.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


