import SwiftUI
import Amplify
import Foundation

// MARK: - YearlyPopupView with Per-Date Daily Task History
struct YearlyPopupView: View {
    @State private var selectedDate: Date
    @State private var newTaskTitle: String = ""
    @State private var selectedTaskDate: Date
    @State private var selectedTime: Date = Date()
    @State private var yearlyTasks: [YearlyPopupTask] = []
    @State private var allDailyTasks: [DailyTask] = []
    @State private var isLoading = false
    @State private var currentMonth: Date
    @State private var showingDatePicker = false
    @State private var showingTaskDatePicker = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager

    private let calendar = Calendar.current

    init(selectedDate: Date) {
        _selectedDate = State(initialValue: selectedDate)
        _selectedTaskDate = State(initialValue: selectedDate)
        _currentMonth = State(initialValue: selectedDate)
    }

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header with improved calendar
                        improvedCalendarHeader
                            .padding(.horizontal, 24)
                            .padding(.top, 60)

                        // Task input section
                        taskInputSection
                            .padding(.horizontal, 24)
                            .padding(.top, 24)

                        // Tasks sections (now only for the selected date)
                        tasksView
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            .padding(.bottom, 100) // Extra bottom padding for scroll
                    }
                }

                // Loading overlay
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: accentColor))

                        Text("Loading tasks...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(accentColor)
                }
            }
            .onAppear {
                fetchTasks()
            }
        }
    }

    // MARK: - Computed Properties
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.97, green: 0.96, blue: 0.94)
    }

    private var accentColor: Color {
        themeManager.accentColor
    }

    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : Color.white
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18)
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5)
    }

    // Key used for grouping dates (yyyy-MM-dd) for the currently selected day
    private var selectedDateKey: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: selectedTaskDate)
    }

    // Only the Daily Plan tasks that match the selected day
    private var dailyTasksForSelectedDate: [DailyTask] {
        allDailyTasks
            .filter { calendar.isDate($0.date.foundationDate, inSameDayAs: selectedTaskDate) }
            .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }

    // Group daily tasks by date (kept for the DailyTasksGroupView header formatting)
    private var groupedDailyTasksForSelectedDate: [(String, [DailyTask])] {
        dailyTasksForSelectedDate.isEmpty ? [] : [(selectedDateKey, dailyTasksForSelectedDate)]
    }

    // MARK: - Improved Calendar Header
    private var improvedCalendarHeader: some View {
        VStack(spacing: 20) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(accentColor)
                }

                Spacer()

                // Month/Year title - clickable
                Button(action: { showingDatePicker = true }) {
                    Text(currentMonth, formatter: monthYearFormatter)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(textColor)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(accentColor)
                }
            }
            .padding(.horizontal, 8)

            // Improved calendar card
            VStack(spacing: 16) {
                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(secondaryTextColor)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Clickable calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(generateCalendarGrid(for: currentMonth), id: \.self) { date in
                        if let date = date {
                            Button(action: { selectDate(date) }) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(getDateTextColor(for: date))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(getDateBackgroundColor(for: date))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Color.clear
                                .frame(width: 36, height: 36)
                        }
                    }
                }
            }
            .padding(20)
            .background(cardBackgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(selectedDate: $currentMonth, mode: .month)
        }
    }

    // MARK: - Fixed Calendar Helper Functions
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }

    private func selectDate(_ date: Date) {
        selectedTaskDate = date
        selectedDate = date
        fetchTasks() // Refresh tasks when date changes (kept; UI now filters by day)
    }

    private func getDateTextColor(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: selectedTaskDate) {
            return .white
        } else if calendar.isDate(date, inSameDayAs: Date()) {
            return accentColor
        } else {
            return textColor
        }
    }

    private func getDateBackgroundColor(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: selectedTaskDate) {
            return Color(red: 0.2, green: 0.6, blue: 0.8) // Selected day
        } else if calendar.isDate(date, inSameDayAs: Date()) {
            return Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.2) // Today
        } else {
            return Color.clear
        }
    }

    private func generateCalendarGrid(for month: Date) -> [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start ?? month
        let endOfMonth = calendar.dateInterval(of: .month, for: month)?.end ?? month

        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: endOfMonth)?.end ?? endOfMonth

        var dates: [Date?] = []
        var currentDate = startOfWeek

        while currentDate < endOfWeek {
            if calendar.isDate(currentDate, equalTo: startOfMonth, toGranularity: .month) {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return dates
    }

    // MARK: - Task Input Section
    private var taskInputSection: some View {
        VStack(spacing: 16) {
            // Section title
            HStack {
                Text("Add Task")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(textColor)
                Spacer()
            }

            // Input card
            VStack(spacing: 16) {
                // Task title input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Title")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(secondaryTextColor)

                    TextField("Enter task title...", text: $newTaskTitle)
                        .font(.system(size: 16))
                        .padding(16)
                        .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(red: 0.98, green: 0.98, blue: 0.98))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                        )
                }

                // Date and time pickers
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(secondaryTextColor)

                        Button(action: { showingTaskDatePicker = true }) {
                            HStack {
                                Text(selectedTaskDate, formatter: dateFormatter)
                                    .font(.system(size: 16))
                                    .foregroundColor(textColor)
                                Spacer()
                                Image(systemName: "calendar")
                                    .font(.system(size: 14))
                                    .foregroundColor(accentColor)
                            }
                            .padding(12)
                            .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(red: 0.98, green: 0.98, blue: 0.98))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(secondaryTextColor)

                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(red: 0.98, green: 0.98, blue: 0.98))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                }

                // Add button
                Button(action: addTask) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                        Text("Add Task")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(newTaskTitle.isEmpty ? Color.gray : accentColor)
                    .cornerRadius(12)
                }
                .disabled(newTaskTitle.isEmpty)
            }
            .padding(20)
            .background(cardBackgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .padding(.bottom, 8)
        .sheet(isPresented: $showingTaskDatePicker) {
            DatePickerView(selectedDate: $selectedTaskDate, mode: .date)
        }
    }

    // MARK: - Tasks View (Per-Day History)
    private var tasksView: some View {
        VStack(spacing: 16) {
            // Section title
            HStack {
                Text("Task History")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(textColor)
                Spacer()
            }

            VStack(spacing: 20) {
                // Daily Tasks Section - Only for the selected day
                if !dailyTasksForSelectedDate.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Daily Plan Tasks")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(textColor)
                            Spacer()
                            Text("\(dailyTasksForSelectedDate.count) total")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(8)
                        }

                        ForEach(groupedDailyTasksForSelectedDate, id: \.0) { dateString, tasksForDate in
                            DailyTasksGroupView(
                                dateString: dateString,
                                tasks: tasksForDate,
                                onToggle: toggleDailyTaskDone,
                                onDelete: deleteDailyTask,
                                colorScheme: colorScheme
                            )
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                } else {
                    // Empty state for daily tasks
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))

                        Text("No daily tasks for this date")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)

                        Text("Pick a date above or add a task to get started")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                }

                // Yearly Tasks Section (unchanged)
                HStack(alignment: .top, spacing: 16) {
                    // To Do section
                    ImprovedTaskSectionView(
                        title: "\("Yearly Tasks") - \("To Do")",
                        tasks: yearlyTasks.filter { !($0.done ?? false) },
                        backgroundColor: colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(red: 0.95, green: 0.97, blue: 1.0),
                        onToggle: toggleYearlyTaskDone,
                        onDelete: deleteYearlyTask,
                        colorScheme: colorScheme
                    )

                    // Completed section
                    ImprovedTaskSectionView(
                        title: "\("Yearly Tasks") - \("Completed")",
                        tasks: yearlyTasks.filter { $0.done ?? false },
                        backgroundColor: colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(red: 0.97, green: 0.97, blue: 0.97),
                        onToggle: toggleYearlyTaskDone,
                        onDelete: deleteYearlyTask,
                        colorScheme: colorScheme
                    )
                }
            }
        }
    }

    // MARK: - Amplify Functions
    private func fetchTasks() {
        guard !isLoading else { return } // Prevent multiple simultaneous requests

        isLoading = true

        Task {
            do {
                // Fetch yearly tasks for the current month
                let monthString = monthString(from: currentMonth)
                let yearlyResult = try await Amplify.API.query(request: .list(YearlyPopupTask.self)).get()

                // Fetch ALL daily tasks (client filters by selected date)
                let dailyResult = try await Amplify.API.query(
                    request: .list(DailyTask.self)
                ).get()

                await MainActor.run {
                    self.yearlyTasks = yearlyResult.filter { $0.month == monthString }

                    // Store all daily tasks (sorted newest first; UI filters to the selected day)
                    self.allDailyTasks = Array(dailyResult).sorted { t1, t2 in
                        t1.date.foundationDate > t2.date.foundationDate
                    }

                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }

        // Create daily task with time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: selectedTime)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedTaskDate)

        let newDailyTask = DailyTask(
            date: try! Temporal.Date(iso8601String: dateString),
            text: newTaskTitle,
            time: timeString,
            order: dailyTasksForSelectedDate.count, // order within the selected day
            done: false,
            owner: nil
        )

        Task {
            do {
                let result = try await Amplify.API.mutate(request: .create(newDailyTask)).get()
                await MainActor.run {
                    // Insert only affects the selected day collection visually
                    self.allDailyTasks.insert(result, at: 0)
                    self.newTaskTitle = ""
                    self.selectedTime = Date()
                }
            } catch {
                // Task creation failed silently
            }
        }
    }

    private func toggleYearlyTaskDone(_ task: YearlyPopupTask) {
        var updatedTask = task
        updatedTask.done = !(task.done ?? false)

        Task {
            do {
                let result = try await Amplify.API.mutate(request: .update(updatedTask)).get()
                await MainActor.run {
                    if let index = self.yearlyTasks.firstIndex(where: { $0.id == task.id }) {
                        self.yearlyTasks[index] = result
                    }
                }
            } catch {
                // Task toggle failed silently
            }
        }
    }

    private func deleteYearlyTask(_ task: YearlyPopupTask) {
        Task {
            do {
                _ = try await Amplify.API.mutate(request: .delete(task))
                await MainActor.run {
                    self.yearlyTasks.removeAll { $0.id == task.id }
                }
            } catch {
                // Task deletion failed silently
            }
        }
    }

    private func toggleDailyTaskDone(_ task: DailyTask) {
        var updatedTask = task
        updatedTask.done = !(task.done ?? false)

        Task {
            do {
                let result = try await Amplify.API.mutate(request: .update(updatedTask)).get()
                await MainActor.run {
                    if let index = self.allDailyTasks.firstIndex(where: { $0.id == task.id }) {
                        self.allDailyTasks[index] = result
                    }
                }
            } catch {
                // Task toggle failed silently
            }
        }
    }

    private func deleteDailyTask(_ task: DailyTask) {
        Task {
            do {
                _ = try await Amplify.API.mutate(request: .delete(task))
                await MainActor.run {
                    self.allDailyTasks.removeAll { $0.id == task.id }
                }
            } catch {
                // Task deletion failed silently
            }
        }
    }

    // MARK: - Helper Functions
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }

    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
}

// MARK: - DailyTasksGroupView Component
struct DailyTasksGroupView: View {
    let dateString: String
    let tasks: [DailyTask]
    let onToggle: (DailyTask) -> Void
    let onDelete: (DailyTask) -> Void
    let colorScheme: ColorScheme
    @EnvironmentObject var themeManager: ThemeManager

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()

            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                displayFormatter.dateFormat = "EEEE, MMM dd"
                return displayFormatter.string(from: date)
            }
        }
        return dateString
    }

    private var completedCount: Int {
        tasks.filter { $0.done == true }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header with progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))

                    Text("\(completedCount)/\(tasks.count) completed")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 3)
                        .frame(width: 24, height: 24)

                    Circle()
                        .trim(from: 0, to: tasks.isEmpty ? 0 : CGFloat(completedCount) / CGFloat(tasks.count))
                        .stroke(themeManager.accentColor, lineWidth: 3)
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: completedCount)
                }
            }
            .padding(.bottom, 8)

            // Tasks for this date
            ForEach(tasks.sorted { ($0.order ?? 0) < ($1.order ?? 0) }, id: \.id) { task in
                DailyTaskRow(
                    task: task,
                    onToggle: onToggle,
                    onDelete: onDelete,
                    colorScheme: colorScheme
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(red: 0.98, green: 0.98, blue: 0.98))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - DailyTaskRow Component
struct DailyTaskRow: View {
    let task: DailyTask
    let onToggle: (DailyTask) -> Void
    let onDelete: (DailyTask) -> Void
    let colorScheme: ColorScheme
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { onToggle(task) }) {
                Image(systemName: task.done == true ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(task.done == true ? themeManager.accentColor : .gray)
            }
            .buttonStyle(PlainButtonStyle())

            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.text)
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                    .strikethrough(task.done == true)
                    .opacity(task.done == true ? 0.6 : 1.0)

                if let time = task.time, !time.isEmpty {
                    Text(time)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Delete button
            Button(action: { onDelete(task) }) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}

// MARK: - DatePickerView Component
struct DatePickerView: View {
    @Binding var selectedDate: Date
    let mode: DatePickerMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    enum DatePickerMode {
        case date
        case month
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if mode == .date {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                } else {
                    DatePicker("Select Month", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle(mode == .date ? "Select Date" : "Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Improved TaskSectionView
struct ImprovedTaskSectionView: View {
    let title: String
    let tasks: [YearlyPopupTask]
    let backgroundColor: Color
    let onToggle: (YearlyPopupTask) -> Void
    let onDelete: (YearlyPopupTask) -> Void
    let colorScheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))

                Spacer()

                Text("\(tasks.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
            }

            // Tasks list
            if tasks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: title.contains("To Do") ? "checklist" : "checkmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)

                    Text(title.contains("To Do") ? "No tasks yet" : "No completed tasks")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(tasks, id: \.id) { task in
                        ImprovedYearlyTaskRow(
                            task: task,
                            onToggle: onToggle,
                            onDelete: onDelete,
                            colorScheme: colorScheme
                        )
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Improved YearlyTaskRow
struct ImprovedYearlyTaskRow: View {
    let task: YearlyPopupTask
    let onToggle: (YearlyPopupTask) -> Void
    let onDelete: (YearlyPopupTask) -> Void
    let colorScheme: ColorScheme
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            // Toggle button
            Button(action: { onToggle(task) }) {
                Image(systemName: task.done ?? false ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.done ?? false ? themeManager.accentColor : .secondary)
            }
            .buttonStyle(PlainButtonStyle())

            // Task title
            Text(task.title)
                .font(.system(size: 15, weight: .medium))
                .strikethrough(task.done ?? false, color: .secondary)
                .foregroundColor(task.done ?? false ? .secondary : (colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18)))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()

            // Delete button
            Button(action: { onDelete(task) }) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
        .cornerRadius(8)
    }
}

