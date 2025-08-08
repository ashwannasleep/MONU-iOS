import SwiftUI
import Amplify

// MARK: - Helper Functions
private func temporalDateToString(_ date: Temporal.Date) -> String {
    return date.iso8601String
}

// MARK: - Calendar View Mode Enum
enum CalendarViewMode: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
}

// MARK: - Main Monthly Planner View
struct MonthlyPlannerView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var sync = CalendarSyncManager()
    
    @State private var currentDate = Date()
    @State private var viewMode: CalendarViewMode = .month
    @State private var showingConnectionSheet = false
    @State private var showingAddEvent = false
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    @State private var dailyTasks: [DailyTask] = []
    
    // MARK: – Theme helpers
    private var backgroundColor: Color {
        themeManager.colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12)
                             : Color(red: 0.97, green: 0.96, blue: 0.94)
    }
    private var textColor: Color {
        themeManager.colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94)
                             : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    private var cardBackgroundColor: Color {
        themeManager.colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : .white
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
            await loadDailyTasks()
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
                .padding(.bottom, 32)
        }
    }
    
    private var connectionStatusSection: some View {
        HStack {
            if sync.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Connecting...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if sync.hasAnyConnection {
                HStack(spacing: 12) {
                    // Refresh button
                    Button(action: {
                        Task {
                            await sync.reSync()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(themeManager.accentColor)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Disconnect button
                    Button(action: {
                        showingConnectionSheet = true
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                Button(action: {
                    showingConnectionSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 16))
                        Text("Connect Calendar")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(themeManager.accentColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.accentColor.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
    }
    
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
                                    .fill(viewMode == mode ? themeManager.accentColor : Color.clear)
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
                    .foregroundColor(themeManager.accentColor)
            }
            .disabled(sync.isLoading)
        }
    }
    
    private var calendarView: some View {
        VStack(spacing: 16) {
            switch viewMode {
            case .month:
                MonthCalendarView(
                    currentDate: $currentDate,
                    events: sync.events,
                    tasks: dailyTasks,
                    onDateTap: { date in
                        showingAddEvent = true
                    },
                    onEventTap: { event in
                        selectedEvent = event
                        showingEventDetail = true
                    },
                    onTaskTap: { task in
                        print("Task tapped: \(task.text)")
                    }
                )
            case .week:
                WeekView(
                    currentDate: $currentDate,
                    events: sync.events,
                    tasks: dailyTasks,
                    onDateTap: { date in
                        showingAddEvent = true
                    },
                    onEventTap: { event in
                        selectedEvent = event
                        showingEventDetail = true
                    },
                    onTaskTap: { task in
                        print("Task tapped: \(task.text)")
                    }
                )
            case .day:
                DayView(
                    currentDate: $currentDate,
                    events: sync.events,
                    tasks: dailyTasks,
                    onDateTap: { date in
                        showingAddEvent = true
                    },
                    onEventTap: { event in
                        selectedEvent = event
                        showingEventDetail = true
                    },
                    onTaskTap: { task in
                        print("Task tapped: \(task.text)")
                    }
                )
            }
        }
    }
    
    // MARK: - Load Daily Tasks
    private func loadDailyTasks() async {
        do {
            let result = try await Amplify.API.query(request: .list(DailyTask.self)).get()
            await MainActor.run {
                // Only update if the data has actually changed
                let newTasks = Array(result)
                if self.dailyTasks.count != newTasks.count || 
                   !self.dailyTasks.elementsEqual(newTasks, by: { $0.id == $1.id }) {
                    self.dailyTasks = newTasks
                    print("📋 Loaded \(result.count) daily tasks for calendar")
                }
            }
        } catch {
            print("❌ Error loading daily tasks: \(error)")
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
                            .fill(themeManager.accentColor)
                    )
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
        )
    }
}

// MARK: - Simple Month Calendar View
struct SimpleMonthCalendarView: View {
    @Binding var currentDate: Date
    let events: [CalendarEvent]
    let tasks: [DailyTask]
    let onDateTap: (Date) -> Void
    let onEventTap: (CalendarEvent) -> Void
    let onTaskTap: (DailyTask) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(themeManager.accentColor)
                }
                
                Spacer()
                
                Text(currentDate, formatter: monthYearFormatter)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(calendarDays.indices, id: \.self) { index in
                    if let date = calendarDays[index] {
                        DayCell(
                            date: date,
                            events: getEventsForDate(date),
                            tasks: getTasksForDate(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                            isToday: calendar.isDate(date, inSameDayAs: Date()),
                            onDateTap: { onDateTap(date) },
                            onEventTap: onEventTap,
                            onTaskTap: onTaskTap
                        )
                        .id("\(date.timeIntervalSince1970)") // Stable ID based on date
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(20)
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var textColor: Color {
        themeManager.colorScheme == .dark ? Color.white : Color.black
    }
    
    private var cardBackgroundColor: Color {
        themeManager.colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color.white
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let endOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.end ?? currentDate
        
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: endOfMonth)?.end ?? endOfMonth
        
        var dates: [Date?] = []
        var dayDate = startOfWeek
        
        while dayDate < endOfWeek {
            if calendar.isDate(dayDate, equalTo: startOfMonth, toGranularity: .month) {
                dates.append(dayDate)
            } else {
                dates.append(nil)
            }
            dayDate = calendar.date(byAdding: .day, value: 1, to: dayDate) ?? dayDate
        }
        
        return dates
    }
    

    
    private func getEventsForDate(_ date: Date) -> [CalendarEvent] {
        // Match events that overlap the day interval (start before day end AND end after day start)
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        return events.filter { event in
            (event.start < endOfDay) && ((event.end ?? event.start) >= startOfDay)
        }.sorted { $0.start < $1.start }
    }
    
    private func getTasksForDate(_ date: Date) -> [DailyTask] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return tasks.filter { task in
            temporalDateToString(task.date).hasPrefix(dateString)
        }
    }
    
    private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    @Binding var currentDate: Date
    let events: [CalendarEvent]
    let tasks: [DailyTask]
    let onDateTap: (Date) -> Void
    let onEventTap: (CalendarEvent) -> Void
    let onTaskTap: (DailyTask) -> Void
    
    private let calendar = Calendar.current
    @EnvironmentObject var themeManager: ThemeManager
    
    // Stable calendar days computation
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let endOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.end ?? currentDate
        
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: endOfMonth)?.end ?? endOfMonth
        
        var dates: [Date?] = []
        var dayDate = startOfWeek
        
        while dayDate < endOfWeek {
            if calendar.isDate(dayDate, equalTo: startOfMonth, toGranularity: .month) {
                dates.append(dayDate)
            } else {
                dates.append(nil)
            }
            dayDate = calendar.date(byAdding: .day, value: 1, to: dayDate) ?? dayDate
        }
        
        return dates
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // iCal-style month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                }
                
                Spacer()
                
                Text(currentDate, formatter: monthYearFormatter)
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.textColor)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // iCal-style month grid
            VStack(spacing: 0) {
                // Day headers
                HStack(spacing: 0) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { dayName in
                        Text(dayName)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                    }
                }
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                    ForEach(calendarDays.indices, id: \.self) { index in
                        if let date = calendarDays[index] {
                            MonthDayCell(
                                date: date,
                                events: getEventsForDate(date),
                                tasks: getTasksForDate(date),
                                isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                                isToday: calendar.isDate(date, inSameDayAs: Date()),
                                onDateTap: { onDateTap(date) },
                                onEventTap: onEventTap,
                                onTaskTap: onTaskTap
                            )
                            .id("month-\(date.timeIntervalSince1970)") // Stable ID
                        } else {
                            Color.clear
                                .frame(height: 60)
                        }
                    }
                }
            }
        }
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private func getEventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.start, inSameDayAs: date)
        }
    }
    
    private func getTasksForDate(_ date: Date) -> [DailyTask] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return tasks.filter { task in
            temporalDateToString(task.date).hasPrefix(dateString)
        }
    }
    
    private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

// MARK: - Month Day Cell
struct MonthDayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let tasks: [DailyTask]
    let isCurrentMonth: Bool
    let isToday: Bool
    let onDateTap: () -> Void
    let onEventTap: (CalendarEvent) -> Void
    let onTaskTap: (DailyTask) -> Void
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 6) {
            // Date number - locked in place with stable rendering
            Button(action: onDateTap) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(getDateTextColor())
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(getDateBackgroundColor())
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // iCal-style colored dots only
            HStack(spacing: 4) {
                // Events dots
                ForEach(Array(events.prefix(3).enumerated()), id: \.offset) { index, event in
                    Button(action: { onEventTap(event) }) {
                        Circle()
                            .fill(event.provider == .apple ? Color.orange : themeManager.accentColor)
                            .frame(width: 6, height: 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Tasks dots
                ForEach(Array(tasks.prefix(2).enumerated()), id: \.offset) { index, task in
                    Button(action: { onTaskTap(task) }) {
                        Circle()
                            .fill(themeManager.accentColor)
                            .frame(width: 6, height: 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(height: 60)
        .opacity(isCurrentMonth ? 1.0 : 0.3)
        .padding(.horizontal, 2)
    }
    
    private func getDateTextColor() -> Color {
        if isToday {
            return .white
        } else if isCurrentMonth {
            return themeManager.textColor
        } else {
            return .secondary
        }
    }
    
    private func getDateBackgroundColor() -> Color {
        if isToday {
            return themeManager.accentColor
        } else {
            return Color.clear
        }
    }
}

// MARK: - Week View
struct WeekView: View {
    @Binding var currentDate: Date
    let events: [CalendarEvent]
    let tasks: [DailyTask]
    let onDateTap: (Date) -> Void
    let onEventTap: (CalendarEvent) -> Void
    let onTaskTap: (DailyTask) -> Void
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    @EnvironmentObject var themeManager: ThemeManager
    
    init(currentDate: Binding<Date>, events: [CalendarEvent], tasks: [DailyTask], onDateTap: @escaping (Date) -> Void, onEventTap: @escaping (CalendarEvent) -> Void, onTaskTap: @escaping (DailyTask) -> Void) {
        self._currentDate = currentDate
        self.events = events
        self.tasks = tasks
        self.onDateTap = onDateTap
        self.onEventTap = onEventTap
        self.onTaskTap = onTaskTap
        dateFormatter.dateFormat = "EEE"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // iCal-style header
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                }
                
                Spacer()
                
                Text(weekRangeText)
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.textColor)
                
                Spacer()
                
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // iCal-style week grid
            VStack(spacing: 0) {
                // Day headers (iCal style)
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        VStack(spacing: 6) {
                            Text(dateFormatter.string(from: day))
                                .font(.system(size: 13, weight: .medium, design: .default))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                            
                            // Date number
                            let date = getDateForDay(day)
                            Button(action: { onDateTap(date) }) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 18, weight: .medium, design: .default))
                                    .foregroundColor(getDateTextColor(for: date))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(getDateBackgroundColor(for: date))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(height: 60)
                        .background(
                            Rectangle()
                                .fill(Color.clear)
                                .border(
                                    Color.gray.opacity(0.2),
                                    width: 0.5
                                )
                        )
                    }
                }
                
                // Events list (titles visible, iCal style)
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        let date = getDateForDay(day)
                        let dayEvents = getEventsForDate(date)
                        
                        VStack(spacing: 4) {
                            // Show up to 4 events with titles
                            ForEach(Array(dayEvents.prefix(4).enumerated()), id: \.offset) { _, event in
                                Button(action: { onEventTap(event) }) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(event.provider == .apple ? Color.orange : themeManager.accentColor)
                                            .frame(width: 6, height: 6)
                                        Text(event.title)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(themeManager.textColor)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .background(
                            Rectangle()
                                .fill(Color.clear)
                                .border(
                                    Color.gray.opacity(0.2),
                                    width: 0.5
                                )
                        )
                    }
                }
            }
        }
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var weekDays: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.start ?? currentDate
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)
        }
    }
    
    private var weekRangeText: String {
        let start = weekDays.first ?? currentDate
        let end = weekDays.last ?? currentDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    private func getDateForDay(_ day: Date) -> Date {
        return day
    }
    
    private func getEventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.start, inSameDayAs: date)
        }
    }
    
    private func getTasksForDate(_ date: Date) -> [DailyTask] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return tasks.filter { task in
            temporalDateToString(task.date).hasPrefix(dateString)
        }
    }
    
    private func getDateTextColor(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: Date()) {
            return .white
        } else {
            return .primary
        }
    }
    
    private func getDateBackgroundColor(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: Date()) {
            return Color(red: 0.2, green: 0.6, blue: 0.8) // Subtle blue instead of pink
        } else {
            return Color.clear
        }
    }
    
    private func previousWeek() {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func nextWeek() {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
}

// MARK: - Day View
struct DayView: View {
    @Binding var currentDate: Date
    let events: [CalendarEvent]
    let tasks: [DailyTask]
    let onDateTap: (Date) -> Void
    let onEventTap: (CalendarEvent) -> Void
    let onTaskTap: (DailyTask) -> Void
    
    private let calendar = Calendar.current
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    @EnvironmentObject var themeManager: ThemeManager
    
    init(currentDate: Binding<Date>, events: [CalendarEvent], tasks: [DailyTask], onDateTap: @escaping (Date) -> Void, onEventTap: @escaping (CalendarEvent) -> Void, onTaskTap: @escaping (DailyTask) -> Void) {
        self._currentDate = currentDate
        self.events = events
        self.tasks = tasks
        self.onDateTap = onDateTap
        self.onEventTap = onEventTap
        self.onTaskTap = onTaskTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // iCal-style day header
            HStack {
                Button(action: previousDay) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(currentDate, formatter: dayFormatter)
                        .font(.system(size: 24, weight: .semibold, design: .default))
                        .foregroundColor(themeManager.textColor)
                    
                    Text(currentDate, formatter: dateFormatter)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: nextDay) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // iCal-style day content
            ScrollView {
                VStack(spacing: 0) {
                    // Events section
                    if !dayEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Events")
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                    .foregroundColor(themeManager.textColor)
                                
                                Spacer()
                                
                                Text("\(dayEvents.count)")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            ForEach(dayEvents, id: \.id) { event in
                                EventRow(event: event, onTap: { onEventTap(event) })
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                
                                if event.id != dayEvents.last?.id {
                                    Divider()
                                        .background(Color.gray.opacity(0.2))
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    
                    // Tasks section
                    if !dayTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Tasks")
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                    .foregroundColor(themeManager.textColor)
                                
                                Spacer()
                                
                                Text("\(dayTasks.count)")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            ForEach(dayTasks, id: \.id) { task in
                                TaskRow(task: task, onTap: { onTaskTap(task) })
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                
                                if task.id != dayTasks.last?.id {
                                    Divider()
                                        .background(Color.gray.opacity(0.2))
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    
                    // iCal-style empty state
                    if dayEvents.isEmpty && dayTasks.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary.opacity(0.4))
                            
                            VStack(spacing: 8) {
                                Text("No events or tasks")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .foregroundColor(themeManager.textColor)
                                
                                Text("Add events and tasks to see them here")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .background(themeManager.backgroundColor)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
    
    private var dayEvents: [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.start, inSameDayAs: currentDate)
        }.sorted { $0.start < $1.start }
    }
    
    private var dayTasks: [DailyTask] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        
        return tasks.filter { task in
            temporalDateToString(task.date).hasPrefix(dateString)
        }.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }
    
    private func previousDay() {
        if let newDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func nextDay() {
        if let newDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
}

// MARK: - Event Row
struct EventRow: View {
    let event: CalendarEvent
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Time indicator
                VStack(spacing: 4) {
                    Text(timeFormatter.string(from: event.start))
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundColor(.secondary)
                    
                    if !event.isAllDay {
                        Text(timeFormatter.string(from: event.end))
                            .font(.system(size: 10, weight: .medium, design: .default))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 60, alignment: .leading)
                
                // Event content
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if event.isAllDay {
                        Text("All Day")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Provider indicator
                Image(systemName: event.provider == .apple ? "calendar" : "globe")
                    .font(.system(size: 14))
                    .foregroundColor(event.provider == .apple ? .orange : themeManager.accentColor)
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Calendar Task Row
struct CalendarTaskRow: View {
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

// MARK: - Day Cell Component
struct DayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let tasks: [DailyTask]
    let isCurrentMonth: Bool
    let isToday: Bool
    let onDateTap: () -> Void
    let onEventTap: (CalendarEvent) -> Void
    let onTaskTap: (DailyTask) -> Void
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 4) {
            // Date number
            Button(action: onDateTap) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isToday ? Color(red: 0.2, green: 0.6, blue: 0.8) : Color.clear)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Events and Tasks indicators
            VStack(spacing: 2) {
                // Show events first (up to 3)
                ForEach(Array(events.prefix(3).enumerated()), id: \.offset) { index, event in
                    Button(action: { onEventTap(event) }) {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(event.provider == .apple ? Color.orange : themeManager.accentColor)
                                .frame(width: 6, height: 6)
                            Text(event.title)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Show tasks (up to 2)
                ForEach(Array(tasks.prefix(2).enumerated()), id: \.offset) { index, task in
                    Button(action: { onTaskTap(task) }) {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(themeManager.accentColor)
                                .frame(width: 6, height: 6)
                            Text(task.text)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(themeManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(height: 60)
        .opacity(isCurrentMonth ? 1.0 : 0.3)
        .padding(.horizontal, 2)
    }
    
    private var textColor: Color {
        if isToday {
            return themeManager.accentColor
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
} 