import SwiftUI
import Amplify

// MARK: - Calendar Connection Sheet
struct CalendarConnectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var sync: CalendarSyncManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Connect Your Calendars")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Choose which calendars to sync with MONU")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    // Apple Calendar
                    Button(action: {
                        Task {
                            await sync.connectApple()
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.orange)
                            Text("Apple Calendar")
                                .fontWeight(.medium)
                            Spacer()
                            if sync.useApple {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeManager.accentColor)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .disabled(sync.isLoading)
                    
                    // Google Calendar
                    Button(action: {
                        Task {
                            await sync.connectGoogle()
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(themeManager.accentColor)
                            Text("Google Calendar")
                                .fontWeight(.medium)
                            Spacer()
                            if sync.useGoogle {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeManager.accentColor)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .disabled(sync.isLoading)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Add Event Sheet
struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var sync: CalendarSyncManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var eventStartTime = Date()
    @State private var eventEndTime = Date().addingTimeInterval(3600)
    @State private var isAllDay = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Event Title", text: $eventTitle)
                    
                    DatePicker("Date", selection: $eventDate, displayedComponents: .date)
                    
                    Toggle("All Day", isOn: $isAllDay)
                    
                    if !isAllDay {
                        DatePicker("Start Time", selection: $eventStartTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $eventEndTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(eventTitle.isEmpty || isLoading)
                }
            }
        }
    }
    
    private func saveEvent() {
        isLoading = true
        
        // Combine date and time
        let calendar = Calendar.current
        let startDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: eventStartTime),
                                        minute: calendar.component(.minute, from: eventStartTime),
                                        second: 0, of: eventDate) ?? eventDate
        
        let endDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: eventEndTime),
                                      minute: calendar.component(.minute, from: eventEndTime),
                                      second: 0, of: eventDate) ?? eventDate
        
        Task {
            do {
                let newEvent = CalendarEvent(
                    id: UUID().uuidString,
                    title: eventTitle,
                    start: startDateTime,
                    end: endDateTime,
                    isAllDay: isAllDay,
                    provider: .apple // Default to Apple Calendar
                )
                try await sync.add(newEvent)
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Event Detail Sheet
struct EventDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let event: CalendarEvent
    @ObservedObject var sync: CalendarSyncManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    private var providerColor: Color {
        event.provider == .apple ? .orange : themeManager.accentColor
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Event Title
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // Event Details
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(providerColor)
                            Text(event.provider == .apple ? "Apple Calendar" : "Google Calendar")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            if event.isAllDay {
                                Text("All Day")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(timeFormatter.string(from: event.start)) - \(timeFormatter.string(from: event.end))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.secondary)
                            Text(dateFormatter.string(from: event.start))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Task Row Component
struct TaskRow: View {
    let task: DailyTask
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Task status
                Image(systemName: task.done == true ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.done == true ? themeManager.accentColor : .secondary)
                
                // Task content
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.text)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(task.done == true ? .secondary : .primary)
                        .strikethrough(task.done == true)
                        .lineLimit(2)
                    
                    if let time = task.time, !time.isEmpty {
                        Text(time)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Task indicator
                Image(systemName: "checklist")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.accentColor)
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 