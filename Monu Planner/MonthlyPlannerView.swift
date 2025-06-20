import SwiftUI

// MARK: - Calendar View Mode Enum
enum CalendarViewMode: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
}

// MARK: - Main Monthly Planner View
struct MonthlyPlannerView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject private var sync = CalendarSyncManager()
    
    @State private var currentDate = Date()
    @State private var viewMode: CalendarViewMode = .month
    @State private var showingConnectionSheet = false
    @State private var showingAddEvent = false
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    
    // MARK: – Theme helpers
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12)
                             : Color(red: 0.97, green: 0.96, blue: 0.94)
    }
    private var textColor: Color {
        colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94)
                             : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : .white
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        connectionStatusSection
                            .padding(.horizontal, 20)
                        
                        if sync.hasAnyConnection {
                            viewModeSelector
                                .padding(.horizontal, 20)
                            
                            calendarView
                                .padding(.horizontal, 20)
                        } else {
                            welcomeSection
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingConnectionSheet) {
            CalendarConnectionSheet(sync: sync)
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventSheet(sync: sync)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailSheet(event: event, sync: sync)
        }
        .task {
            // Auto-connect to available calendars
            await sync.autoConnect()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            Button(action: {
                navigationManager.navigateToRoot()
            }) {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 48)
            .padding(.bottom, 8)
            
            Text("Your schedule, your flow 📅")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }

    // MARK: – Connection Status Section
    private var connectionStatusSection: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: sync.hasAnyConnection ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(sync.hasAnyConnection ? .green : .orange)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sync.hasAnyConnection ? "Connected" : "Not Connected")
                            .font(.custom("Georgia", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(textColor)
                        
                        HStack(spacing: 8) {
                            if sync.useApple {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text("Apple")
                                        .font(.custom("Georgia", size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if sync.useGoogle {
                                HStack(spacing: 4) {
                                    Image(systemName: "globe")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    Text("Google")
                                        .font(.custom("Georgia", size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if !sync.hasAnyConnection {
                                Text("Tap to connect calendars")
                                    .font(.custom("Georgia", size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if sync.hasAnyConnection {
                            Text("\(sync.events.count) events synced")
                                .font(.custom("Georgia", size: 12))
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }
                
                Spacer()
                
                if sync.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if let errorMessage = sync.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(errorMessage)
                        .font(.custom("Georgia", size: 12))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .onTapGesture {
            if !sync.hasAnyConnection {
                showingConnectionSheet = true
            }
        }
    }
    
    // MARK: – Welcome Section (when no calendars connected)
    private var welcomeSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Connect Your Calendars")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
            
            Text("Connect to Apple Calendar or Google Calendar to sync your events and stay organized.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: {
                showingConnectionSheet = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
        )
    }
    
    // MARK: – View Mode Selector
    private var viewModeSelector: some View {
        HStack {
            HStack(spacing: 0) {
                ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                    Button(action: {
                        viewMode = mode
                    }) {
                        Text(mode.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(viewMode == mode ? .white : textColor)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(viewMode == mode ? Color.blue : Color.clear)
                            )
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            Button(action: {
                Task {
                    await sync.reSync()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .disabled(sync.isLoading)
        }
    }
    
    // MARK: – Calendar View
    private var calendarView: some View {
        VStack {
            switch viewMode {
            case .month:
                SimpleMonthCalendarView(
                    currentDate: $currentDate,
                    events: sync.events,
                    onDateTap: { date in
                        // Show add event sheet for selected date
                        showingAddEvent = true
                    },
                    onEventTap: { event in
                        // Show event detail sheet
                        selectedEvent = event
                        showingEventDetail = true
                    }
                )
            case .week:
                Text("Week View")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(40)
            case .day:
                Text("Day View")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(40)
            }
        }
        .padding(20)
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Simple Month Calendar View
struct SimpleMonthCalendarView: View {
    @Binding var currentDate: Date
    let events: [CalendarEvent]
    let onDateTap: (Date) -> Void
    let onEventTap: (CalendarEvent) -> Void
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(currentDate: Binding<Date>, events: [CalendarEvent], onDateTap: @escaping (Date) -> Void, onEventTap: @escaping (CalendarEvent) -> Void) {
        self._currentDate = currentDate
        self.events = events
        self.onDateTap = onDateTap
        self.onEventTap = onEventTap
        dateFormatter.dateFormat = "MMMM yyyy"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Days of week
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid with events
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        let dayEvents = getEventsForDate(date)
                        DayCell(
                            date: date,
                            events: dayEvents,
                            isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                            isToday: calendar.isDateInToday(date),
                            onDateTap: { onDateTap(date) },
                            onEventTap: onEventTap
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getEventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.start, inSameDayAs: date)
        }
    }
    
    private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

// MARK: - Day Cell Component
struct DayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let isCurrentMonth: Bool
    let isToday: Bool
    let onDateTap: () -> Void
    let onEventTap: (CalendarEvent) -> Void
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 2) {
            // Date number
            Button(action: onDateTap) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(isToday ? Color.blue.opacity(0.2) : Color.clear)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Events (up to 2 visible)
            VStack(spacing: 1) {
                ForEach(Array(events.prefix(2).enumerated()), id: \.offset) { index, event in
                    Button(action: { onEventTap(event) }) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(event.provider == .apple ? Color.orange : Color.blue)
                            .frame(height: 3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if events.count > 2 {
                    Text("•••")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 40, height: 50)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .gray
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
}

// MARK: - Calendar Connection Sheet
struct CalendarConnectionSheet: View {
    @ObservedObject var sync: CalendarSyncManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
                    
                    Text("Connect Your Calendars")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.semibold)
                    
                    Text("Choose which calendar services you'd like to connect to sync your events.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                
                VStack(spacing: 20) {
                    // Apple Calendar Option
                    CalendarConnectionButton(
                        title: "Apple Calendar",
                        subtitle: "iCloud & local calendars",
                        icon: "calendar",
                        color: .orange,
                        isConnected: sync.useApple,
                        isLoading: sync.isLoading,
                        action: {
                            Task {
                                if sync.useApple {
                                    await sync.disconnectApple()
                                } else {
                                    await sync.connectApple()
                                }
                            }
                        }
                    )
                    
                    // Google Calendar Option
                    CalendarConnectionButton(
                        title: "Google Calendar",
                        subtitle: "Gmail & Google Workspace",
                        icon: "globe",
                        color: .blue,
                        isConnected: sync.useGoogle,
                        isLoading: sync.isLoading,
                        action: {
                            Task {
                                if sync.useGoogle {
                                    await sync.disconnectGoogle()
                                } else {
                                    await sync.connectGoogle()
                                }
                            }
                        }
                    )
                }
                .padding(.horizontal, 24)
                
                if let errorMessage = sync.errorMessage {
                    Text(errorMessage)
                        .font(.custom("Georgia", size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .background(colorScheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.1) : Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Calendar Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Georgia", size: 16))
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Calendar Connection Button
struct CalendarConnectionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isConnected: Bool
    let isLoading: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.1))
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Georgia", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.custom("Georgia", size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        VStack(alignment: .trailing, spacing: 4) {
                            Image(systemName: isConnected ? "checkmark.circle.fill" : "plus.circle")
                                .font(.title3)
                                .foregroundColor(isConnected ? .green : color)
                            
                            Text(isConnected ? "Connected" : "Connect")
                                .font(.custom("Georgia", size: 10))
                                .foregroundColor(isConnected ? .green : .secondary)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.15) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isConnected ? color.opacity(0.5) : Color.secondary.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
}

// MARK: - Add Event Sheet
struct AddEventSheet: View {
    @ObservedObject var sync: CalendarSyncManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var isAllDay = false
    @State private var selectedProvider: Source = .apple
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Event Details")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    TextField("Event Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("All Day", isOn: $isAllDay)
                    
                    DatePicker("Start", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                    
                    DatePicker("End", selection: $endDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Save to")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    Picker("Calendar", selection: $selectedProvider) {
                        if sync.useApple {
                            Text("Apple Calendar").tag(Source.apple)
                        }
                        if sync.useGoogle {
                            Text("Google Calendar").tag(Source.google)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
            }
            .navigationTitle("New Event")
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
                    .disabled(title.isEmpty || isLoading)
                }
            }
        }
        .onAppear {
            // Set default provider
            if sync.useApple && !sync.useGoogle {
                selectedProvider = .apple
            } else if sync.useGoogle && !sync.useApple {
                selectedProvider = .google
            } else if sync.useApple {
                selectedProvider = .apple
            }
        }
    }
    
    private func saveEvent() {
        isLoading = true
        
        let event = CalendarEvent(
            title: title,
            start: startDate,
            end: endDate,
            isAllDay: isAllDay,
            provider: selectedProvider
        )
        
        Task {
            do {
                try await sync.add(event)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to save event: \(error)")
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Event Detail Sheet
struct EventDetailSheet: View {
    let event: CalendarEvent
    @ObservedObject var sync: CalendarSyncManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedStartDate: Date
    @State private var editedEndDate: Date
    @State private var editedIsAllDay: Bool
    @State private var isLoading = false
    @State private var showingDeleteAlert = false
    
    init(event: CalendarEvent, sync: CalendarSyncManager) {
        self.event = event
        self.sync = sync
        self._editedTitle = State(initialValue: event.title)
        self._editedStartDate = State(initialValue: event.start)
        self._editedEndDate = State(initialValue: event.end)
        self._editedIsAllDay = State(initialValue: event.isAllDay)
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Event Details")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    if isEditing {
                        TextField("Title", text: $editedTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Toggle("All Day", isOn: $editedIsAllDay)
                        
                        DatePicker("Start", selection: $editedStartDate, displayedComponents: editedIsAllDay ? [.date] : [.date, .hourAndMinute])
                        
                        DatePicker("End", selection: $editedEndDate, displayedComponents: editedIsAllDay ? [.date] : [.date, .hourAndMinute])
                    } else {
                        HStack {
                            Text("Title")
                            Spacer()
                            Text(event.title)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Calendar")
                            Spacer()
                            Text(event.provider.rawValue)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Start")
                            Spacer()
                            if event.isAllDay {
                                Text(event.start, style: .date)
                                    .foregroundColor(.secondary)
                            } else {
                                VStack(alignment: .trailing) {
                                    Text(event.start, style: .date)
                                        .foregroundColor(.secondary)
                                    Text(event.start, style: .time)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        HStack {
                            Text("End")
                            Spacer()
                            if event.isAllDay {
                                Text(event.end, style: .date)
                                    .foregroundColor(.secondary)
                            } else {
                                VStack(alignment: .trailing) {
                                    Text(event.end, style: .date)
                                        .foregroundColor(.secondary)
                                    Text(event.end, style: .time)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        if event.isAllDay {
                            HStack {
                                Text("All Day")
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding()
                
                if !isEditing {
                    VStack(spacing: 12) {
                        Button("Edit Event") {
                            isEditing = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Delete Event") {
                            showingDeleteAlert = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Event" : "Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Cancel" : "Done") {
                        if isEditing {
                            // Reset changes
                            editedTitle = event.title
                            editedStartDate = event.start
                            editedEndDate = event.end
                            editedIsAllDay = event.isAllDay
                            isEditing = false
                        } else {
                            dismiss()
                        }
                    }
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveChanges()
                        }
                        .disabled(editedTitle.isEmpty || isLoading)
                    }
                }
            }
        }
        .alert("Delete Event", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteEvent()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
    }
    
    private func saveChanges() {
        isLoading = true
        
        let updatedEvent = CalendarEvent(
            id: event.id,
            title: editedTitle,
            start: editedStartDate,
            end: editedEndDate,
            isAllDay: editedIsAllDay,
            provider: event.provider
        )
        
        Task {
            do {
                try await sync.update(updatedEvent)
                await MainActor.run {
                    isEditing = false
                }
            } catch {
                print("Failed to update event: \(error)")
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func deleteEvent() {
        isLoading = true
        
        Task {
            do {
                try await sync.delete(event)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to delete event: \(error)")
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
