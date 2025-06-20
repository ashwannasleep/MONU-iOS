import SwiftUI
import UserNotifications

class NotificationHelper {
    static let shared = NotificationHelper()
    private let notificationManager = NotificationManager.shared
    
    private init() {}
    
    // MARK: - Habit Tracking Notifications
    func scheduleHabitReminder(for habitName: String, at time: Date) {
        guard notificationManager.isAuthorized && notificationManager.notificationSettings.habitReminders else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "✨ Habit Check-in"
        content.body = "Don't forget to check off '\(habitName)'"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "habit_\(habitName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule habit reminder: \(error)")
            } else {
                print("✅ Habit reminder scheduled for \(habitName)")
            }
        }
    }
    
    // MARK: - Daily Task Reminders
    func scheduleTaskReminder(for taskName: String, at time: Date) {
        guard notificationManager.isAuthorized && notificationManager.notificationSettings.dailyReminders else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🌿 Task Reminder"
        content.body = "Time to work on: \(taskName)"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: "task_\(taskName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule task reminder: \(error)")
            } else {
                print("✅ Task reminder scheduled for \(taskName)")
            }
        }
    }
    
    // MARK: - Goal Reminders
    func scheduleGoalReminder(for goalName: String, frequency: GoalFrequency) {
        guard notificationManager.isAuthorized && notificationManager.notificationSettings.goalReminders else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Goal Check-in"
        content.body = "Review your progress on: \(goalName)"
        content.sound = .default
        content.badge = 1
        
        var components = DateComponents()
        
        switch frequency {
        case .daily:
            components.hour = 9
            components.minute = 0
        case .weekly:
            components.weekday = 1 // Sunday
            components.hour = 10
            components.minute = 0
        case .monthly:
            components.day = 1
            components.hour = 10
            components.minute = 0
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "goal_\(goalName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule goal reminder: \(error)")
            } else {
                print("✅ Goal reminder scheduled for \(goalName)")
            }
        }
    }
    
    // MARK: - Bucket List Reminders
    func scheduleBucketListReminder(for itemName: String, dueDate: Date?) {
        guard notificationManager.isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🌟 Bucket List Reminder"
        content.body = "Don't forget about: \(itemName)"
        content.sound = .default
        content.badge = 1
        
        var trigger: UNNotificationTrigger
        
        if let dueDate = dueDate {
            // Schedule for specific due date
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            // Schedule for 1 week from now as a general reminder
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7 * 24 * 60 * 60, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: "bucket_\(itemName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule bucket list reminder: \(error)")
            } else {
                print("✅ Bucket list reminder scheduled for \(itemName)")
            }
        }
    }
    
    // MARK: - Mindfulness Reminders
    func scheduleMindfulnessReminder(at time: Date) {
        guard notificationManager.isAuthorized && notificationManager.notificationSettings.mindfulnessReminders else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🧘‍♀️ Mindfulness Moment"
        content.body = "Take a deep breath and center yourself"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "mindfulness_daily", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule mindfulness reminder: \(error)")
            } else {
                print("✅ Mindfulness reminder scheduled")
            }
        }
    }
    
    // MARK: - Weekly Progress Summary
    func scheduleWeeklyProgressReminder() {
        guard notificationManager.isAuthorized && notificationManager.notificationSettings.weeklyProgress else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📊 Weekly Progress Report"
        content.body = "See how you've progressed this week and plan for the next"
        content.sound = .default
        content.badge = 1
        
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
    
    // MARK: - Custom Motivational Messages
    func scheduleMotivationalMessage(message: String, at time: Date) {
        guard notificationManager.isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💫 MONU"
        content.body = message
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: "motivational_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule motivational message: \(error)")
            } else {
                print("✅ Motivational message scheduled")
            }
        }
    }
    
    // MARK: - Clear Specific Notifications
    func clearHabitReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["habit_reminder"])
    }
    
    func clearTaskReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["task_reminder"])
    }
    
    func clearGoalReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["goal_reminder"])
    }
    
    // MARK: - Check Notification Status
    func checkNotificationStatus() -> Bool {
        return notificationManager.isAuthorized
    }
}

// MARK: - Goal Frequency Enum
enum GoalFrequency {
    case daily
    case weekly
    case monthly
}

// MARK: - Notification Categories
extension NotificationHelper {
    func setupNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Mark Complete",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 15 min",
            options: []
        )
        
        let habitCategory = UNNotificationCategory(
            identifier: "HABIT_CATEGORY",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_CATEGORY",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([habitCategory, taskCategory])
    }
} 