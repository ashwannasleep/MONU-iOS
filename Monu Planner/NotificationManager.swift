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
        setupNotificationCategories()
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
        print("📅 Attempting to schedule daily reminder for \(time)")
        guard isAuthorized && notificationSettings.dailyReminders else { 
            print("❌ Daily reminder not scheduled: authorized=\(isAuthorized), enabled=\(notificationSettings.dailyReminders)")
            return 
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🌿 Time for your daily planning"
        content.body = "Take a moment to plan your day and set your intentions"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "DISMISSIBLE_CATEGORY"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // Ensure we have valid components for daily repetition
        var dailyComponents = DateComponents()
        dailyComponents.hour = components.hour
        dailyComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dailyComponents, repeats: true)
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
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "HABIT_CATEGORY"
        
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
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "DISMISSIBLE_CATEGORY"
        
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
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "DISMISSIBLE_CATEGORY"
        
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
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "DISMISSIBLE_CATEGORY"
        
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
        print("🔄 Updating all notifications...")
        print("📱 Authorization status: \(isAuthorized)")
        print("⚙️ Notification settings: \(notificationSettings)")
        
        // Remove all existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Removed all pending notifications")
        
        // Schedule based on user preferences
        if notificationSettings.dailyReminders {
            print("📅 Scheduling daily reminder for \(notificationSettings.dailyReminderTime)")
            scheduleDailyReminder(at: notificationSettings.dailyReminderTime)
        }
        
        if notificationSettings.habitReminders {
            print("🔄 Scheduling habit reminders")
            scheduleHabitReminders()
        }
        
        if notificationSettings.weeklyProgress {
            print("📊 Scheduling weekly progress")
            scheduleWeeklyProgress()
        }
        
        if notificationSettings.goalReminders {
            print("🎯 Scheduling goal reminders")
            scheduleGoalReminders()
        }
        
        if notificationSettings.mindfulnessReminders {
            print("🧘‍♀️ Scheduling mindfulness reminders")
            scheduleMindfulnessReminders()
        }
        
        // Don't call saveSettings() here to avoid recursive calls
        // Settings are already saved by the onChange modifier
        print("✅ Finished updating notifications")
    }
    
    // MARK: - Custom Notifications
    func scheduleCustomNotification(title: String, body: String, date: Date, identifier: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "DISMISSIBLE_CATEGORY"
        
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
    
    // MARK: - Test Notifications
    func scheduleTestNotification() {
        guard isAuthorized else { 
            print("❌ Cannot schedule test notification: not authorized")
            return 
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 Test Notification"
        content.body = "This is a test notification from MONU"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "DISMISSIBLE_CATEGORY"
        
        // Schedule for 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule test notification: \(error)")
            } else {
                print("✅ Test notification scheduled for 5 seconds from now")
            }
        }
    }
    
    // MARK: - Debug Methods
    func debugNotificationStatus() {
        print("🔍 Debugging notification status...")
        print("📱 Authorization status: \(isAuthorized)")
        print("⚙️ Settings: \(notificationSettings)")
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("📋 System notification settings:")
            print("   - Authorization status: \(settings.authorizationStatus.rawValue)")
            print("   - Alert setting: \(settings.alertSetting.rawValue)")
            print("   - Badge setting: \(settings.badgeSetting.rawValue)")
            print("   - Sound setting: \(settings.soundSetting.rawValue)")
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📝 Pending notifications (\(requests.count)):")
            for request in requests {
                print("   - ID: \(request.identifier)")
                print("     Title: \(request.content.title)")
                print("     Body: \(request.content.body)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("     Next trigger: \(trigger.nextTriggerDate()?.description ?? "nil")")
                }
            }
        }
    }
    
    // MARK: - Clear All Notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // MARK: - Notification Categories
    private func setupNotificationCategories() {
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 15 min",
            options: []
        )
        
        let dismissibleCategory = UNNotificationCategory(
            identifier: "DISMISSIBLE_CATEGORY",
            actions: [dismissAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        let habitCategory = UNNotificationCategory(
            identifier: "HABIT_CATEGORY",
            actions: [dismissAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_CATEGORY",
            actions: [dismissAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            dismissibleCategory,
            habitCategory,
            taskCategory
        ])
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