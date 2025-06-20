import SwiftUI
import UserNotifications
import Amplify

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var notificationSettings = NotificationSettings()
    
    private init() {
        loadSettings()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
            
            return granted
        } catch {
            print("❌ Notification authorization failed: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - Settings Management
    func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "notification_settings"),
           let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
            self.notificationSettings = settings
        }
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(notificationSettings) {
            UserDefaults.standard.set(data, forKey: "notification_settings")
        }
    }
    
    // MARK: - Daily Reminders
    func scheduleDailyReminder(at time: Date) {
        guard isAuthorized && notificationSettings.dailyReminders else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🌿 Time for your daily planning"
        content.body = "Take a moment to plan your day and set your intentions"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule daily reminder: \(error)")
            } else {
                print("✅ Daily reminder scheduled for \(time)")
            }
        }
    }
    
    // MARK: - Habit Reminders
    func scheduleHabitReminders() {
        guard isAuthorized && notificationSettings.habitReminders else { return }
        
        // Remove existing habit reminders
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["habit_reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "✨ Habit Check-in"
        content.body = "Don't forget to check off your daily habits"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 9 PM daily
        var components = DateComponents()
        components.hour = 21
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "habit_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule habit reminder: \(error)")
            } else {
                print("✅ Habit reminder scheduled")
            }
        }
    }
    
    // MARK: - Weekly Progress
    func scheduleWeeklyProgress() {
        guard isAuthorized && notificationSettings.weeklyProgress else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📊 Weekly Progress Report"
        content.body = "See how you've progressed this week and plan for the next"
        content.sound = .default
        content.badge = 1
        
        // Schedule for Sunday at 6 PM
        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 18
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_progress", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule weekly progress: \(error)")
            } else {
                print("✅ Weekly progress reminder scheduled")
            }
        }
    }
    
    // MARK: - Goal Reminders
    func scheduleGoalReminders() {
        guard isAuthorized && notificationSettings.goalReminders else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Goal Check-in"
        content.body = "Review your goals and track your progress"
        content.sound = .default
        content.badge = 1
        
        // Schedule for Saturday at 10 AM
        var components = DateComponents()
        components.weekday = 7 // Saturday
        components.hour = 10
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "goal_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule goal reminder: \(error)")
            } else {
                print("✅ Goal reminder scheduled")
            }
        }
    }
    
    // MARK: - Mindfulness Reminders
    func scheduleMindfulnessReminders() {
        guard isAuthorized && notificationSettings.mindfulnessReminders else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🧘‍♀️ Mindfulness Moment"
        content.body = "Take a deep breath and center yourself"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 3 PM daily
        var components = DateComponents()
        components.hour = 15
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "mindfulness_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule mindfulness reminder: \(error)")
            } else {
                print("✅ Mindfulness reminder scheduled")
            }
        }
    }
    
    // MARK: - Update All Notifications
    func updateAllNotifications() {
        // Remove all existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule based on user preferences
        if notificationSettings.dailyReminders {
            scheduleDailyReminder(at: notificationSettings.dailyReminderTime)
        }
        
        if notificationSettings.habitReminders {
            scheduleHabitReminders()
        }
        
        if notificationSettings.weeklyProgress {
            scheduleWeeklyProgress()
        }
        
        if notificationSettings.goalReminders {
            scheduleGoalReminders()
        }
        
        if notificationSettings.mindfulnessReminders {
            scheduleMindfulnessReminders()
        }
        
        saveSettings()
    }
    
    // MARK: - Custom Notifications
    func scheduleCustomNotification(title: String, body: String, date: Date, identifier: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule custom notification: \(error)")
            } else {
                print("✅ Custom notification scheduled: \(title)")
            }
        }
    }
    
    // MARK: - Clear All Notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

// MARK: - Notification Settings Model
struct NotificationSettings: Codable, Equatable {
    var dailyReminders: Bool = true
    var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    
    var habitReminders: Bool = true
    var weeklyProgress: Bool = true
    var goalReminders: Bool = true
    var mindfulnessReminders: Bool = false
    
    var quietHoursEnabled: Bool = false
    var quietHoursStart: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    var quietHoursEnd: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
} 