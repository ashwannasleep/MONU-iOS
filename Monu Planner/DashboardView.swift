import SwiftUI
import Amplify

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct DashboardView: View {
    @State private var bucketProgress: Int = 0
    @State private var dailyProgress: Int = 0
    @State private var yearlyProgress: Int = 0
    @State private var futureProgress: Int = 0
    @State private var loading: Bool = false
    @State private var error: String?
    @State private var isRefreshing: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(red:0.12,green:0.12,blue:0.12) : Color(red:0.97,green:0.96,blue:0.94))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    header
                    
                    // Error Alert
                    if let error = error {
                        Text(error)
                            .font(.system(size: 13, design: .serif))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(colorScheme == .dark ? Color.red.opacity(0.15) : Color.red.opacity(0.08))
                            .cornerRadius(10)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                    }
                    
                    // Progress Cards - Horizontal Row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            DashboardCard(
                                title: languageManager.localizedString(.todayTasks),
                                progress: dailyProgress,
                                progressColor: Color(red: 0.95, green: 0.62, blue: 0.56)
                            )
                            
                            DashboardCard(
                                title: languageManager.localizedString(.yearlyGoals),
                                progress: yearlyProgress,
                                progressColor: Color(red: 0.95, green: 0.62, blue: 0.56)
                            )
                            
                            DashboardCard(
                                title: languageManager.localizedString(.bucketList),
                                progress: bucketProgress,
                                progressColor: Color(red: 0.95, green: 0.62, blue: 0.56)
                            )
                            
                            DashboardCard(
                                title: languageManager.localizedString(.futureVision),
                                progress: futureProgress,
                                progressColor: Color(red: 0.95, green: 0.62, blue: 0.56)
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                    
                    // Focus Card
                    FocusCardView()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    
                    // AI Insights Section
                    AIInsightsSection()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadData()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Header View
    private var header: some View {
        VStack(spacing: 0) {
            Button { navigationManager.navigateToRoot() } label: {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .buttonStyle(.plain)
            .padding(.top, 48)
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
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await fetchBucket() }
            group.addTask { await fetchDaily() }
            group.addTask { await fetchYearly() }
            group.addTask { await fetchFuture() }
        }
        
        await MainActor.run {
            loading = false
        }
    }
    
    // MARK: - Data Fetching Functions
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
                    // Clear any previous errors if this succeeds
                    if self.error?.contains("bucket") == true {
                        self.error = nil
                    }
                }
            case .failure(let error):
                await MainActor.run {
                    self.error = "Failed to load bucket list: \(error.localizedDescription)"
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load bucket list: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchDaily() async {
        guard authManager.isAuthenticated else { return }
        
        do {
            let today = DateFormatter.yyyyMMdd.string(from: Date())
            let result = try await Amplify.API.query(request: .list(DailyTask.self, where: DailyTask.keys.date.eq(today)))
            switch result {
            case .success(let tasks):
                let completedTasks = tasks.filter { $0.done == true }.count
                let totalTasks = tasks.count
                let progress = totalTasks > 0 ? Int((Double(completedTasks) / Double(totalTasks)) * 100) : 0
                
                await MainActor.run {
                    self.dailyProgress = progress
                    // Clear any previous errors if this succeeds
                    if self.error?.contains("daily") == true {
                        self.error = nil
                    }
                }
            case .failure(let error):
                await MainActor.run {
                    self.error = "Failed to load daily tasks: \(error.localizedDescription)"
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load daily tasks: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchYearly() async {
        guard authManager.isAuthenticated else { return }
        
        do {
            let result = try await Amplify.API.query(request: .list(YearlyGoal.self))
            switch result {
            case .success(let goals):
                let completedGoals = goals.filter { $0.done == true }.count
                let totalGoals = goals.count
                let progress = totalGoals > 0 ? Int((Double(completedGoals) / Double(totalGoals)) * 100) : 0
                
                await MainActor.run {
                    self.yearlyProgress = progress
                    // Clear any previous errors if this succeeds
                    if self.error?.contains("yearly") == true {
                        self.error = nil
                    }
                }
            case .failure(let error):
                await MainActor.run {
                    self.error = "Failed to load yearly goals: \(error.localizedDescription)"
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load yearly goals: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchFuture() async {
        guard authManager.isAuthenticated else { return }
        
        do {
            let result = try await Amplify.API.query(request: .list(FutureGoal.self))
            switch result {
            case .success(let goals):
                let completedGoals = goals.filter { $0.done == true }.count
                let totalGoals = goals.count
                let progress = totalGoals > 0 ? Int((Double(completedGoals) / Double(totalGoals)) * 100) : 0
                
                await MainActor.run {
                    self.futureProgress = progress
                    // Clear any previous errors if this succeeds
                    if self.error?.contains("future") == true {
                        self.error = nil
                    }
                }
            case .failure(let error):
                await MainActor.run {
                    self.error = "Failed to load future goals: \(error.localizedDescription)"
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load future goals: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Dashboard Card
struct DashboardCard: View {
    let title: String
    let progress: Int
    let progressColor: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                .multilineTextAlignment(.center)
            
            ZStack {
                Circle()
                    .stroke(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 6)
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
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                    Text("%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                }
            }
        }
        .padding(16)
        .background(colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .frame(width: 120)
    }
}

// MARK: - Focus Card View
struct FocusCardView: View {
    @State private var weeklyStats = WeeklyStats(done: 0, total: 0)
    @State private var todayTasks: [DailyTask] = []
    @State private var isLoading = false
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(languageManager.localizedString(.todaysFocus))
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                Spacer()
            }
            
            Divider()
                .background(colorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.8, green: 0.8, blue: 0.8))
            
            // Content
            VStack(spacing: 16) {
                // Weekly Stats
                WeeklyStatsSection(stats: weeklyStats)
                
                // Today's Tasks
                TodaysFocusSection(tasks: todayTasks)
            }
        }
        .padding(20)
        .background(colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .onAppear {
            Task {
                isLoading = true
                await fetchWeeklyStats()
                await fetchTodayTasks()
                isLoading = false
            }
        }
    }
    
    // MARK: - Data Fetching
    private func fetchWeeklyStats() async {
        guard authManager.isAuthenticated else { return }
        
        do {
            let result = try await Amplify.API.query(
                request: .list(DailyTask.self)
            )
            switch result {
            case .success(let tasks):
                let weekStartDate = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
                let weekTasks = tasks.filter { task in
                    return task.date.foundationDate >= weekStartDate
                }
                
                let completedTasks = weekTasks.filter { $0.done == true }.count
                let totalTasks = weekTasks.count
                
                await MainActor.run {
                    self.weeklyStats = WeeklyStats(done: completedTasks, total: totalTasks)
                }
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
            let result = try await Amplify.API.query(
                request: .list(DailyTask.self, where: DailyTask.keys.date.eq(today))
            )
            switch result {
            case .success(let tasks):
                await MainActor.run {
                    self.todayTasks = Array(tasks.prefix(3))
                }
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
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(languageManager.localizedString(.thisWeek))
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))
                
                Text("\(stats.done) of \(stats.total) tasks")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
            }
            
            Spacer()
            
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 4)
                    .frame(width: 40, height: 40)
                
                if stats.total > 0 {
                    Circle()
                        .trim(from: 0, to: CGFloat(stats.done) / CGFloat(stats.total))
                        .stroke(Color(red: 0.95, green: 0.62, blue: 0.56), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                }
                
                Text("\(stats.total > 0 ? Int((Double(stats.done) / Double(stats.total)) * 100) : 0)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
            }
        }
    }
}

// MARK: - Today's Focus Section
struct TodaysFocusSection: View {
    let tasks: [DailyTask]
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Tasks")
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.5, green: 0.5, blue: 0.5))
            
            if tasks.isEmpty {
                Text(languageManager.localizedString(.noTasksToday))
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                    .italic()
            } else {
                VStack(spacing: 6) {
                    ForEach(tasks, id: \.id) { task in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(task.done == true ? Color.green : Color(red: 0.8, green: 0.8, blue: 0.8))
                                .frame(width: 6, height: 6)
                            
                            Text(task.text)
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                                .strikethrough(task.done == true)
                            
                            Spacer()
                        }
                    }
                    
                    if tasks.count >= 3 {
                        Text("+ \(tasks.count - 3) \(languageManager.localizedString(.moreTasks))")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
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

