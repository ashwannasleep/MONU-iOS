import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAuthorizationAlert = false
    @State private var showingTimePicker = false
    @State private var selectedTimeType: TimeType = .daily
    
    enum TimeType {
        case daily, quietStart, quietEnd
    }
    
    var body: some View {
        ZStack {
            // Background
            (colorScheme == .dark ? Color(red:0.12,green:0.12,blue:0.12) : Color(red:0.97,green:0.96,blue:0.94))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 6) {
                        Text("Notifications")
                            .font(.custom("Georgia", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                        
                        Text("Customize your reminders")
                            .font(.custom("Georgia", size: 14))
                            .italic()
                            .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Authorization Status
                    authorizationSection
                    
                    // Notification Types
                    VStack(spacing: 12) {
                        notificationSection(
                            title: "Daily Planning",
                            icon: "🌿",
                            description: "Plan your day ahead",
                            isEnabled: $notificationManager.notificationSettings.dailyReminders,
                            showTimePicker: true,
                            timeType: .daily
                        )
                        
                        notificationSection(
                            title: "Habit Check-ins",
                            icon: "✨",
                            description: "Track your daily habits",
                            isEnabled: $notificationManager.notificationSettings.habitReminders
                        )
                        
                        notificationSection(
                            title: "Weekly Progress",
                            icon: "📊",
                            description: "Weekly progress reports",
                            isEnabled: $notificationManager.notificationSettings.weeklyProgress
                        )
                        
                        notificationSection(
                            title: "Goal Reviews",
                            icon: "🎯",
                            description: "Regular goal check-ins",
                            isEnabled: $notificationManager.notificationSettings.goalReminders
                        )
                        
                        notificationSection(
                            title: "Mindfulness",
                            icon: "🧘‍♀️",
                            description: "Gentle pause reminders",
                            isEnabled: $notificationManager.notificationSettings.mindfulnessReminders
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Quiet Hours
                    quietHoursSection
                    
                    Spacer(minLength: 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
            }
        }
        .alert("Enable Notifications", isPresented: $showingAuthorizationAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To receive helpful reminders, please enable notifications in Settings.")
        }
        .sheet(isPresented: $showingTimePicker) {
            timePickerSheet
        }
    }
    
    // MARK: - Authorization Section
    private var authorizationSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(notificationManager.isAuthorized ? .green : .orange)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(notificationManager.isAuthorized ? "Notifications Enabled" : "Notifications Disabled")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                    
                    Text(notificationManager.isAuthorized ? "You'll receive helpful reminders" : "Enable notifications to get reminders")
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                }
                
                Spacer()
                
                if !notificationManager.isAuthorized {
                    Button("Enable") {
                        showingAuthorizationAlert = true
                    }
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
                }
            }
            .padding(16)
            .background(colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Notification Section
    private func notificationSection(
        title: String,
        icon: String,
        description: String,
        isEnabled: Binding<Bool>,
        showTimePicker: Bool = false,
        timeType: TimeType = .daily
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                    
                    Text(description)
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                }
                
                Spacer()
                
                Toggle("", isOn: isEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.95, green: 0.62, blue: 0.56)))
                    .disabled(!notificationManager.isAuthorized)
            }
            .padding(16)
            
            if showTimePicker && isEnabled.wrappedValue && notificationManager.isAuthorized {
                Divider()
                    .background(colorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.8, green: 0.8, blue: 0.8))
                
                Button(action: {
                    selectedTimeType = timeType
                    showingTimePicker = true
                }) {
                    HStack {
                        Text("Reminder Time")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))
                        
                        Spacer()
                        
                        Text(formatTime(notificationManager.notificationSettings.dailyReminderTime))
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Quiet Hours Section
    private var quietHoursSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quiet Hours")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                Spacer()
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                // Quiet Hours Toggle
                HStack(spacing: 12) {
                    Image(systemName: "moon.fill")
                        .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quiet Hours")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                        
                        Text("Pause notifications during quiet time")
                            .font(.system(size: 13, design: .serif))
                            .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationManager.notificationSettings.quietHoursEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.95, green: 0.62, blue: 0.56)))
                        .disabled(!notificationManager.isAuthorized)
                }
                .padding(16)
                
                if notificationManager.notificationSettings.quietHoursEnabled {
                    Divider()
                        .background(colorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.8, green: 0.8, blue: 0.8))
                    
                    VStack(spacing: 12) {
                        // Start Time
                        Button(action: {
                            selectedTimeType = .quietStart
                            showingTimePicker = true
                        }) {
                            HStack {
                                Text("Start Time")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))
                                
                                Spacer()
                                
                                Text(formatTime(notificationManager.notificationSettings.quietHoursStart))
                                    .font(.system(size: 14, weight: .medium, design: .serif))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        
                        // End Time
                        Button(action: {
                            selectedTimeType = .quietEnd
                            showingTimePicker = true
                        }) {
                            HStack {
                                Text("End Time")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))
                                
                                Spacer()
                                
                                Text(formatTime(notificationManager.notificationSettings.quietHoursEnd))
                                    .font(.system(size: 14, weight: .medium, design: .serif))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .background(colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Time Picker Sheet
    private var timePickerSheet: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color(red:0.12,green:0.12,blue:0.12) : Color(red:0.97,green:0.96,blue:0.94))
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text(selectedTimeType == .daily ? "Daily Reminder Time" : 
                         selectedTimeType == .quietStart ? "Quiet Hours Start" : "Quiet Hours End")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                        .padding(.top, 20)
                    
                    DatePicker("", selection: selectedTimeBinding, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        .background(colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingTimePicker = false
                    }
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        notificationManager.updateAllNotifications()
                        showingTimePicker = false
                    }
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private var selectedTimeBinding: Binding<Date> {
        switch selectedTimeType {
        case .daily:
            return $notificationManager.notificationSettings.dailyReminderTime
        case .quietStart:
            return $notificationManager.notificationSettings.quietHoursStart
        case .quietEnd:
            return $notificationManager.notificationSettings.quietHoursEnd
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 