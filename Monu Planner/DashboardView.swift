import SwiftUI
import Amplify

// MARK: - DateFormatter
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// MARK: - Dashboard View
struct DashboardView: View {
    @State private var bucketProgress: Int = 0
    @State private var dailyProgress: Int = 0
    @State private var yearlyProgress: Int = 0
    @State private var loading: Bool = false
    @State private var error: String?

    // anchor id for scrolling to top
    private let topAnchor = "dashboard-top-anchor"

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            SwiftUI.ScrollViewReader { proxy in
                ScrollView {
                    // Invisible top anchor
                    Color.clear
                        .frame(height: 1)
                        .id(topAnchor)

                    VStack(spacing: 0) {
                        // Header
                        header

                        // Error Alert
                        if let error = error {
                            Text(error)
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(.red)
                                .padding(.horizontal, LayoutHelper.responsivePadding(for: LayoutHelper.screenWidth))
                                .padding(.vertical, 12)
                                .background(themeManager.colorScheme == .dark ? Color.red.opacity(0.15) : Color.red.opacity(0.08))
                                .cornerRadius(10)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                        }

                        // Progress Cards - Fixed Layout
                        HStack(spacing: 12) {
                            DashboardCard(
                                title: "Today Tasks",
                                progress: dailyProgress,
                                progressColor: themeManager.accentColor
                            )
                            DashboardCard(
                                title: "Yearly Goals",
                                progress: yearlyProgress,
                                progressColor: themeManager.accentColor
                            )
                            DashboardCard(
                                title: "Bucket List",
                                progress: bucketProgress,
                                progressColor: themeManager.accentColor
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)

                        // Focus Card
                        FocusCardView()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                        // Weekly Tasks Pie (Finished / Unfinished / Expired)
                        WeeklyTasksPieCard()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                        // Optional: time allocation card
                        TimeAllocationTrackerCard()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 100)
                    }
                }
                .onAppear {
                    Task { await loadData() }
                }
                .onChange(of: authManager.isAuthenticated) { isAuthenticated in
                    if isAuthenticated {
                        Task { await loadData() }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Header View
    private var header: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton()
                Spacer()
            }
            .padding(.horizontal, LayoutHelper.responsivePadding(for: LayoutHelper.screenWidth))
            .padding(.top, LayoutHelper.isIPad ? 60 : 48)
            
            Button { navigationManager.navigateToRoot() } label: {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textColor)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)

            Text("Track your progress and achievements")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }

    // MARK: - Data Loading
    private func loadData() async {
        loading = true
        error = nil

        // Wait briefly for auth to settle
        var attempts = 0
        while !authManager.isAuthenticated && attempts < 10 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            attempts += 1
        }

        guard authManager.isAuthenticated else {
            await MainActor.run {
                self.error = "Please sign in to view dashboard"
                self.loading = false
            }
            return
        }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await fetchBucket() }
            group.addTask { await fetchDaily() }
            group.addTask { await fetchYearly() }
        }

        await MainActor.run { loading = false }
    }

    // MARK: - Data Fetching
    private func fetchBucket() async {
        guard authManager.isAuthenticated else { return }
        do {
            let result = try await Amplify.API.query(request: .list(BucketItem.self))
            switch result {
            case .success(let items):
                let completedItems = items.filter { $0.done == true }.count
                let totalItems = items.count
                let progress = totalItems > 0 ? Int((Double(completedItems) / Double(totalItems)) * 100) : 0
                await MainActor.run {
                    self.bucketProgress = progress
                    if self.error?.contains("bucket") == true { self.error = nil }
                }
            case .failure(let error):
                await MainActor.run { self.error = "Failed to load bucket list: \(error.localizedDescription)" }
            }
        } catch {
            await MainActor.run { self.error = "Failed to load bucket list: \(error.localizedDescription)" }
        }
    }

    private func fetchDaily() async {
        guard authManager.isAuthenticated else { return }
        do {
            let today = DateFormatter.yyyyMMdd.string(from: Date())
            let result = try await Amplify.API.query(request: .list(DailyTask.self))
            switch result {
            case .success(let tasks):
                let todayTasks = tasks.filter { String($0.date.iso8601String.prefix(10)) == today }
                let completedTasks = todayTasks.filter { $0.done == true }.count
                let totalTasks = todayTasks.count
                let progress = totalTasks > 0 ? Int((Double(completedTasks) / Double(totalTasks)) * 100) : 0
                await MainActor.run {
                    self.dailyProgress = progress
                    if self.error?.contains("daily") == true { self.error = nil }
                }
            case .failure(let error):
                await MainActor.run { self.error = "Failed to load daily tasks: \(error.localizedDescription)" }
            }
        } catch {
            await MainActor.run { self.error = "Failed to load daily tasks: \(error.localizedDescription)" }
        }
    }

    private func fetchYearly() async {
        guard authManager.isAuthenticated else { return }
        do {
            let result = try await Amplify.API.query(request: .list(YearlyGoal.self))
            switch result {
            case .success(let goals):
                let completed = goals.filter { $0.done == true }.count
                let total = goals.count
                let progress = total > 0 ? Int((Double(completed) / Double(total)) * 100) : 0
                await MainActor.run {
                    self.yearlyProgress = progress
                    if self.error?.contains("yearly") == true { self.error = nil }
                }
            case .failure(let error):
                await MainActor.run { self.error = "Failed to load yearly goals: \(error.localizedDescription)" }
            }
        } catch {
            await MainActor.run { self.error = "Failed to load yearly goals: \(error.localizedDescription)" }
        }
    }

}

// MARK: - Dashboard Card
struct DashboardCard: View {
    let title: String
    let progress: Int
    let progressColor: Color

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundColor(themeManager.textColor)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            ZStack {
                Circle()
                    .stroke(themeManager.colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 6)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: CGFloat(progress) / 100)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: progress)

                VStack(spacing: 0) {
                    Text("\(progress)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.textColor)
                    Text("%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                }
            }
        }
        .padding(16)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .frame(minWidth: 120, maxWidth: 140)
    }
}

// MARK: - Focus Card View
struct FocusCardView: View {
    @State private var weeklyStats = WeeklyStats(done: 0, total: 0)
    @State private var todayTasks: [DailyTask] = []
    @State private var isLoading = false

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Today Focus")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(themeManager.textColor)
                Spacer()
            }

            Divider()
                .background(themeManager.colorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.8, green: 0.8, blue: 0.8))

            // Content
            VStack(spacing: 16) {
                WeeklyStatsSection(stats: weeklyStats)
                TodaysFocusSection(tasks: todayTasks)
            }
        }
        .padding(20)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .onAppear {
            Task {
                isLoading = true
                var attempts = 0
                while !authManager.isAuthenticated && attempts < 10 {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    attempts += 1
                }
                await fetchWeeklyStats()
                await fetchTodayTasks()
                isLoading = false
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated && todayTasks.isEmpty {
                Task {
                    await fetchWeeklyStats()
                    await fetchTodayTasks()
                }
            }
        }
    }

    // MARK: - Data
    private func fetchWeeklyStats() async {
        guard authManager.isAuthenticated else { return }
        do {
            let result = try await Amplify.API.query(request: .list(DailyTask.self))
            switch result {
            case .success(let tasks):
                let weekStartDate = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
                let weekTasks = tasks.filter { $0.date.foundationDate >= weekStartDate }
                let completed = weekTasks.filter { $0.done == true }.count
                let total = weekTasks.count
                await MainActor.run { self.weeklyStats = WeeklyStats(done: completed, total: total) }
            case .failure(let error):
                print("Failed to fetch weekly stats: \(error)")
            }
        } catch {
            print("Error fetching weekly stats: \(error)")
        }
    }

    private func fetchTodayTasks() async {
        guard authManager.isAuthenticated else { return }
        do {
            let today = DateFormatter.yyyyMMdd.string(from: Date())
            let result = try await Amplify.API.query(request: .list(DailyTask.self))
            switch result {
            case .success(let tasks):
                let todayTasks = tasks.filter { String($0.date.iso8601String.prefix(10)) == today }
                await MainActor.run { self.todayTasks = Array(todayTasks.prefix(3)) }
            case .failure(let error):
                print("Failed to fetch today's tasks: \(error)")
            }
        } catch {
            print("Error fetching today's tasks: \(error)")
        }
    }
}

// MARK: - Weekly Stats Section
struct WeeklyStatsSection: View {
    let stats: WeeklyStats
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("This Week")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(themeManager.colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))
                Text("\(stats.done) of \(stats.total) tasks")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(themeManager.textColor)
            }
            Spacer()

            // Circular Progress
            ZStack {
                Circle()
                    .stroke(themeManager.colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 4)
                    .frame(width: 40, height: 40)

                if stats.total > 0 {
                    Circle()
                        .trim(from: 0, to: CGFloat(stats.done) / CGFloat(stats.total))
                        .stroke(themeManager.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                }

                Text("\(stats.total > 0 ? Int((Double(stats.done) / Double(stats.total)) * 100) : 0)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.textColor)
            }
        }
    }
}

// MARK: - Today's Focus Section
struct TodaysFocusSection: View {
    let tasks: [DailyTask]
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Tasks")
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundColor(themeManager.colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))

            if tasks.isEmpty {
                Text("No tasks for today")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(themeManager.colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                    .italic()
            } else {
                VStack(spacing: 6) {
                    ForEach(tasks, id: \.id) { task in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(task.done == true ? themeManager.accentColor : Color(red: 0.8, green: 0.8, blue: 0.8))
                                .frame(width: 6, height: 6)

                            Text(task.text)
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(themeManager.textColor)
                                .strikethrough(task.done == true)

                            Spacer()
                        }
                    }

                    if tasks.count >= 3 {
                        Text("+ \(tasks.count - 3) more")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(themeManager.colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                            .italic()
                    }
                }
            }
        }
    }
}

// MARK: - Weekly Stats Model
struct WeeklyStats {
    let done: Int
    let total: Int
}

// MARK: - Weekly Tasks Pie Card (Finished / Unfinished / Expired)
struct WeeklyTasksPieCard: View {
    @State private var finished: Int = 0
    @State private var unfinished: Int = 0
    @State private var expired: Int = 0
    @State private var useMinutes: Bool = false

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Weekly Tasks")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(themeManager.textColor)
                Spacer()
            }
            Divider()
                .background(themeManager.colorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.85, green: 0.85, blue: 0.85))

            HStack(spacing: 16) {
                PieChartView(segments: [
                    (themeManager.accentColor, Double(finished)),
                    (themeManager.accentColor.opacity(0.55), Double(unfinished)),
                    (Color.gray.opacity(0.5), Double(expired))
                ])
                .frame(width: 120, height: 120)

                VStack(alignment: .leading, spacing: 8) {
                    legendRow(color: themeManager.accentColor, title: "Finished", value: finished)
                    legendRow(color: themeManager.accentColor.opacity(0.55), title: "Unfinished", value: unfinished)
                    if expired > 0 {
                        legendRow(color: Color.gray.opacity(0.5), title: "Expired", value: expired)
                    }
                }
                Spacer()
            }
        }
        .padding(20)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .task { await loadWeekly() }
    }

    private func legendRow(color: Color, title: String, value: Int) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text("\(title): \(useMinutes ? formatHM(value) : "\(value)")")
                .font(.system(size: 13, design: .serif))
                .foregroundColor(themeManager.textColor)
        }
    }

    private func loadWeekly() async {
        guard authManager.isAuthenticated else { return }
        do {
            let result = try await Amplify.API.query(request: .list(DailyTask.self))
            if case .success(let tasks) = result {
                let cal = Calendar.current
                let weekStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
                let weekKeyRange = (0..<7).compactMap {
                    cal.date(byAdding: .day, value: $0, to: weekStart).map { DateFormatter.yyyyMMdd.string(from: $0) }
                }

                // Detect whether to use minutes or counts
                let hasDuration = tasks.contains { $0.duration?.isEmpty == false }
                self.useMinutes = hasDuration

                var finishedVal = 0
                var unfinishedVal = 0
                var expiredVal = 0

                for t in tasks {
                    let dateStr = String(t.date.iso8601String.prefix(10))
                    let isThisWeek = weekKeyRange.contains(dateStr)
                    let minutes = parseMinutes(t.duration)
                    let weight = hasDuration ? minutes : 1
                    if isThisWeek {
                        if t.done == true { finishedVal += weight } else { unfinishedVal += weight }
                    } else {
                        if let d = DateFormatter.yyyyMMdd.date(from: dateStr), d < weekStart, t.done != true {
                            expiredVal += weight
                        }
                    }
                }
                await MainActor.run {
                    self.finished = finishedVal
                    self.unfinished = unfinishedVal
                    self.expired = expiredVal
                }
            }
        } catch {
            // ignore for v1
        }
    }

    private func parseMinutes(_ duration: String?) -> Int {
        guard let duration = duration else { return 0 }
        var minutes = 0
        for p in duration.split(separator: " ") {
            if p.hasSuffix("h"), let h = Int(p.dropLast()) { minutes += h * 60 }
            if p.hasSuffix("m"), let m = Int(p.dropLast()) { minutes += m }
        }
        return minutes
    }

    private func formatHM(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return String(format: "%dh %dm", h, m) }
        return String(format: "%dm", m)
    }
}

// MARK: - Time Allocation Tracker
struct TimeAllocationTrackerCard: View {
    @State private var totalMinutesToday: Int = 0
    @State private var categoryMinutes: [(name: String, minutes: Int, color: Color)] = []

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Time Allocation Today")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(themeManager.textColor)
                Spacer()
            }
            Divider()
                .background(themeManager.colorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.85, green: 0.85, blue: 0.85))

            // Total
            HStack {
                Text("Total: \(formatHM(totalMinutesToday))")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
                Spacer()
            }

            // Pie + Legend
            HStack(spacing: 16) {
                PieChartView(segments: categoryMinutes.map { ($0.color, Double(max($0.minutes, 0))) })
                    .frame(width: 120, height: 120)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(categoryMinutes.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 8) {
                            Circle().fill(item.color).frame(width: 8, height: 8)
                            Text("\(item.name): \(formatHM(item.minutes))")
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(themeManager.textColor)
                        }
                    }
                }
                Spacer()
            }

            if let top = categoryMinutes.max(by: { $0.minutes < $1.minutes }) {
                Text("Tip: You’ve been focusing most on “\(top.name)”. Consider balancing with Health.")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .task { await loadTodayAllocation() }
    }

    private func loadTodayAllocation() async {
        guard authManager.isAuthenticated else { return }
        do {
            let today = DateFormatter.yyyyMMdd.string(from: Date())
            let result = try await Amplify.API.query(request: .list(DailyTask.self))
            if case .success(let tasks) = result {
                let todays = tasks.filter { $0.date.iso8601String.hasPrefix(today) }
                var total = 0
                var buckets: [String: Int] = [:]
                for t in todays {
                    let minutes = parseMinutes(t.duration)
                    total += minutes
                    let cat = inferCategory(from: t.text)
                    buckets[cat, default: 0] += minutes
                }
                await MainActor.run {
                    self.totalMinutesToday = total
                    let palette: [Color] = [
                        themeManager.accentColor,
                        themeManager.accentColor.opacity(0.8),
                        themeManager.accentColor.opacity(0.6),
                        themeManager.accentColor.opacity(0.4)
                    ]
                    let sorted = buckets.sorted { $0.value > $1.value }
                    self.categoryMinutes = Array(sorted.enumerated()).map { idx, kv in
                        (kv.key, kv.value, palette[min(idx, palette.count - 1)])
                    }
                }
            }
        } catch {
            // ignore in v1
        }
    }

    private func parseMinutes(_ duration: String?) -> Int {
        guard let duration = duration else { return 0 }
        var minutes = 0
        for p in duration.split(separator: " ") {
            if p.hasSuffix("h"), let h = Int(p.dropLast()) { minutes += h * 60 }
            if p.hasSuffix("m"), let m = Int(p.dropLast()) { minutes += m }
        }
        return minutes
    }

    private func inferCategory(from text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("work") || lower.contains("meeting") { return "Work" }
        if lower.contains("gym") || lower.contains("run") || lower.contains("yoga") { return "Health" }
        if lower.contains("study") || lower.contains("read") { return "Learning" }
        if lower.contains("family") || lower.contains("friends") { return "Personal" }
        return "Other"
    }

    private func formatHM(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return String(format: "%dh %dm", h, m) }
        return String(format: "%dm", m)
    }
}

// MARK: - Simple Pie Chart
struct PieChartView: View {
    let segments: [(Color, Double)]
    private var total: Double { max(segments.map { $0.1 }.reduce(0, +), 0.0001) }

    private var slices: [(start: Double, end: Double, color: Color)] {
        var result: [(Double, Double, Color)] = []
        var running: Double = 0
        for seg in segments {
            let value = max(seg.1, 0)
            let start = running
            let end = running + (value / total)
            result.append((start, end, seg.0))
            running = end
        }
        return result
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                ForEach(Array(slices.enumerated()), id: \.offset) { _, s in
                    PieSlice(startAngle: .degrees(s.start * 360), endAngle: .degrees(s.end * 360))
                        .fill(s.color)
                }
            }
            .frame(width: size, height: size)
        }
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        p.move(to: center)
        p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        p.closeSubpath()
        return p
    }
}

// MARK: - Floating "Back to Top"
struct BackToTopFAB: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 28, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .shadow(radius: 3)
    }
}

