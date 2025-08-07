import SwiftUI
import Amplify

// MARK: - Habit Categories (Research-based)
enum HabitCategory: String, CaseIterable {
    case health = "health"
    case productivity = "productivity"
    case learning = "learning"
    case relationships = "relationships"
    case mindfulness = "mindfulness"
    case finance = "finance"
    case creativity = "creativity"
    case environment = "environment"
    
    var displayName: String {
        switch self {
        case .health: return "Health & Fitness"
        case .productivity: return "Productivity"
        case .learning: return "Learning & Growth"
        case .relationships: return "Relationships"
        case .mindfulness: return "Mindfulness"
        case .finance: return "Finance"
        case .creativity: return "Creativity"
        case .environment: return "Environment"
        }
    }
    
    var emoji: String {
        switch self {
        case .health: return "heart.fill"
        case .productivity: return "bolt.fill"
        case .learning: return "book.fill"
        case .relationships: return "heart"
        case .mindfulness: return "leaf.fill"
        case .finance: return "dollarsign.circle.fill"
        case .creativity: return "paintbrush.fill"
        case .environment: return "globe"
        }
    }
    
    var color: String {
        switch self {
        case .health: return "health"
        case .productivity: return "productivity"
        case .learning: return "learning"
        case .relationships: return "relationships"
        case .mindfulness: return "mindfulness"
        case .finance: return "finance"
        case .creativity: return "creativity"
        case .environment: return "environment"
        }
    }
}

// MARK: - Habit Difficulty Levels
enum HabitDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Takes 1-2 minutes"
        case .medium: return "Takes 5-15 minutes"
        case .hard: return "Takes 15+ minutes"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Habit Frequency Types
enum HabitFrequency: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .custom: return "Custom"
        }
    }
}

// MARK: - Fixed HabitItem Model (Compatible with Amplify)
struct HabitItem: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var icon: String
    var mood: String // Using mood instead of category since it exists in Amplify model
    var days: [String]
    var description: String
    var time: String
    var plan: String
    var log: [String: Bool]
    var color: String
    var owner: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    // Computed properties for enhanced features
    var category: String {
        get { mood } // Use mood field to store category
        set { mood = newValue }
    }
    
    var difficulty: String {
        get { plan.contains("easy") ? "easy" : plan.contains("hard") ? "hard" : "medium" }
        set { 
            if plan.isEmpty {
                plan = "Difficulty: \(newValue)"
            } else {
                plan = plan.replacingOccurrences(of: "Difficulty: [^\\s]+", with: "Difficulty: \(newValue)", options: .regularExpression)
            }
        }
    }
    
    var frequency: String {
        get { days.count == 7 ? "daily" : days.count == 1 ? "weekly" : "custom" }
        set { 
            switch newValue {
            case "daily":
                days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case "weekly":
                days = ["Mon"]
            case "monthly":
                days = ["1st"]
            default:
                break
            }
        }
    }
    
    var habitStack: String {
        get { description.contains("After") ? description : "" }
        set { 
            if !newValue.isEmpty {
                description = "After \(newValue), I will \(name)"
            }
        }
    }
    
    var cue: String {
        get { time.isEmpty ? "" : "At \(time)" }
        set { time = newValue }
    }
    
    var reward: String {
        get { plan.contains("reward") ? plan : "" }
        set { 
            if !newValue.isEmpty {
                plan = plan.isEmpty ? "Reward: \(newValue)" : plan + " | Reward: \(newValue)"
            }
        }
    }
    
    var streak: Int {
        get {
            let sortedDates = log.keys.sorted()
            var currentStreak = 0
            for date in sortedDates.reversed() {
                if log[date] == true {
                    currentStreak += 1
                } else {
                    break
                }
            }
            return currentStreak
        }
        set { /* Read-only computed property */ }
    }
    
    var totalCompletions: Int {
        get { log.values.filter { $0 }.count }
        set { /* Read-only computed property */ }
    }

    init(id: String = UUID().uuidString, name: String = "", icon: String = "🌟", mood: String = "health", days: [String] = [], description: String = "", time: String = "", plan: String = "", log: [String: Bool] = [:], color: String = "neutral") {
        self.id = id
        self.name = name
        self.icon = icon
        self.mood = mood
        self.days = days
        self.description = description
        self.time = time
        self.plan = plan
        self.log = log
        self.color = color
        self.owner = nil
        self.createdAt = nil
        self.updatedAt = nil
    }
}

// MARK: - Fixed Amplify Conversion
extension HabitItem {
    init(apiModel: Habit) {
        self.id = apiModel.id
        self.name = apiModel.name
        self.icon = apiModel.icon ?? "🌟"
        self.mood = apiModel.mood ?? "health"
        self.days = apiModel.days?.compactMap { $0 } ?? []
        self.description = apiModel.description ?? ""
        self.time = apiModel.time ?? ""
        self.plan = apiModel.plan ?? ""
        
        // Convert log (string "Mon:true,Tue:false" -> [String: Bool])
        var logDict: [String: Bool] = [:]
        if let apiLog = apiModel.log, !apiLog.isEmpty {
            let entries = apiLog.split(separator: ",")
            for entry in entries {
                let parts = entry.split(separator: ":")
                if parts.count == 2 {
                    let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                    let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                    logDict[key] = value.lowercased() == "true"
                }
            }
        }
        self.log = logDict
        
        self.color = apiModel.color ?? "neutral"
        self.owner = apiModel.owner
        self.createdAt = apiModel.createdAt?.foundationDate
        self.updatedAt = apiModel.updatedAt?.foundationDate
    }

    func toAPIHabit() -> Habit {
        let logString = log.isEmpty ? nil : log.map { "\($0.key):\($0.value)" }.joined(separator: ",")
        return Habit(
            id: self.id,
            name: self.name,
            icon: self.icon.isEmpty ? nil : self.icon,
            mood: self.mood.isEmpty ? nil : self.mood,
            days: self.days.isEmpty ? nil : self.days,
            description: self.description.isEmpty ? nil : self.description,
            time: self.time.isEmpty ? nil : self.time,
            plan: self.plan.isEmpty ? nil : self.plan,
            log: logString,
            color: self.color.isEmpty ? nil : self.color,
            owner: self.owner
        )
    }
}

// MARK: - HabitTrackerView
struct HabitTrackerView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) private var scheme

    @State private var habits: [HabitItem] = []
    @State private var selectedHabit: HabitItem?
    @State private var selectedHabitIndex: Int?
    @State private var showHabitModal = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var selectedCategory: HabitCategory? = nil
    @State private var showCategoryFilter = false

    private var todayCompletionRate: Double {
        let today = getCurrentDayString()
        let completedToday = habits.filter { $0.log[today] == true }.count
        let scheduledToday = habits.filter { $0.days.contains(today) }.count
        return scheduledToday > 0 ? Double(completedToday) / Double(scheduledToday) : 0
    }
    
    private var filteredHabits: [HabitItem] {
        guard let category = selectedCategory else { return habits }
        return habits.filter { $0.category == category.rawValue }
    }
    
    private var totalStreak: Int {
        habits.reduce(0) { $0 + $1.streak }
    }
    
    private var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.totalCompletions }
    }
    
    private var backgroundColor: Color {
        scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white
    }
    
    private var secondaryBackgroundColor: Color {
        scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    
    private func dayBackgroundGradient(for day: String, habit: HabitItem) -> LinearGradient {
        if habit.days.contains(day) {
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            let backgroundColor = scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white
            return LinearGradient(
                gradient: Gradient(colors: [backgroundColor, backgroundColor]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    scheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.12) : Color(red: 0.98, green: 0.97, blue: 0.95),
                    scheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.16) : Color(red: 0.95, green: 0.94, blue: 0.92)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    modernHeader
                    modernProgressSection
                    modernStatsSection
                    modernCategoryFilter
                    modernHabitsSection
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showHabitModal) {
            if let habit = selectedHabit {
                ModernHabitModal(
                    habit: habit,
                    onSave: { updatedHabit in
                        saveHabit(updatedHabit)
                        showHabitModal = false
                    },
                    onDelete: selectedHabitIndex != nil ? {
                        deleteHabit()
                        showHabitModal = false
                    } : nil,
                    onClose: {
                        showHabitModal = false
                    }
                )
            }
        }
        .onAppear { fetchHabits() }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Modern Header
    private var modernHeader: some View {
        VStack(spacing: 0) {
            Button { navigationManager.navigateToRoot() } label: {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(scheme == .dark ? .white : .black)
            }
            .buttonStyle(.plain)
            .padding(.top, 48)
            .padding(.bottom, 8)
            
            Text("Build lasting habits for success")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }

    // MARK: - Modern Progress Section
    private var modernProgressSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(languageManager.localizedString(.todayProgress))
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text("\(Int(todayCompletionRate * 100))% complete")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(
                            scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.9, green: 0.9, blue: 0.92),
                            lineWidth: 8
                        )
                    
                    Circle()
                        .trim(from: 0, to: todayCompletionRate)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.0), value: todayCompletionRate)
                }
                .frame(width: 60, height: 60)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Modern Stats Section
    private var modernStatsSection: some View {
        HStack(spacing: 16) {
            ModernStatCard(
                title: "Total Streak",
                value: "\(totalStreak)",
                icon: "🔥",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            ModernStatCard(
                title: "Completions",
                value: "\(totalCompletions)",
                icon: "✅",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.mint]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            ModernStatCard(
                title: "Active Habits",
                value: "\(habits.count)",
                icon: "📊",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Modern Category Filter
    private var modernCategoryFilter: some View {
        VStack(spacing: 16) {
            HStack {
                Text(languageManager.localizedString(.filterByCategory))
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Spacer()
                
                Button(action: { showCategoryFilter.toggle() }) {
                    HStack(spacing: 8) {
                        Text(selectedCategory?.displayName ?? languageManager.localizedString(.allCategories))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(showCategoryFilter ? 180 : 0))
                            .animation(.easeInOut(duration: 0.2), value: showCategoryFilter)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if showCategoryFilter {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(HabitCategory.allCases, id: \.self) { category in
                        ModernCategoryFilterButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: {
                                selectedCategory = selectedCategory == category ? nil : category
                                showCategoryFilter = false
                            }
                        )
                    }
                }
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Modern Habits Section
    private var modernHabitsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Your Habits")
                    .font(.custom("Georgia", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Spacer()
                
                Button(action: {
                    selectedHabit = HabitItem()
                    selectedHabitIndex = nil
                    showHabitModal = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Add Habit")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            
            if filteredHabits.isEmpty {
                ModernEmptyHabitsView()
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(Array(filteredHabits.enumerated()), id: \.element.id) { index, habit in
                        ModernHabitRow(
                            habit: habit,
                            onToggle: { toggleHabit(habit) },
                            onEdit: {
                                selectedHabit = habit
                                selectedHabitIndex = index
                                showHabitModal = true
                            }
                        )
                    }
                }
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Helper Methods
    private func getCurrentDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: Date())
    }
    
    private func toggleHabit(_ habit: HabitItem) {
        let today = getCurrentDayString()
        var updatedHabit = habit
        
        // Ensure the log dictionary exists and toggle the value
        let currentValue = updatedHabit.log[today] ?? false
        updatedHabit.log[today] = !currentValue
        
        // Save the updated habit
        saveHabit(updatedHabit)
    }
    
    private func fetchHabits() {
        guard authManager.isAuthenticated else { return }
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                let result = try await Amplify.API.query(request: .list(Habit.self))
                await MainActor.run {
                    switch result {
                    case .success(let items):
                        self.habits = items.map { HabitItem(apiModel: $0) }
                        self.errorMessage = ""
                        self.showError = false
                    case .failure(let error):
                        self.errorMessage = "Failed to load habits: \(error.localizedDescription)"
                        self.showError = true
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load habits: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func saveHabit(_ habit: HabitItem) {
        Task {
            do {
                let apiHabit = habit.toAPIHabit()
                
                // Check if habit exists to determine create vs update
                let existingIndex = self.habits.firstIndex(where: { $0.id == habit.id })
                
                let result: GraphQLResponse<Habit>
                if existingIndex != nil {
                    // Update existing habit
                    result = try await Amplify.API.mutate(request: .update(apiHabit))
                } else {
                    // Create new habit
                    result = try await Amplify.API.mutate(request: .create(apiHabit))
                }
                
                await MainActor.run {
                    switch result {
                    case .success(let savedHabit):
                        let habitItem = HabitItem(apiModel: savedHabit)
                        if let index = existingIndex {
                            self.habits[index] = habitItem
                        } else {
                            self.habits.append(habitItem)
                        }
                        // Clear any previous errors
                        self.errorMessage = ""
                        self.showError = false
                    case .failure(let error):
                        self.errorMessage = "Failed to save habit: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to save habit: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func deleteHabit() {
        guard let index = selectedHabitIndex, index < habits.count else { 
            errorMessage = "Invalid habit selection"
            showError = true
            return 
        }
        let habit = habits[index]
        
        Task {
            do {
                let apiHabit = habit.toAPIHabit()
                let result = try await Amplify.API.mutate(request: .delete(apiHabit))
                await MainActor.run {
                    switch result {
                    case .success:
                        self.habits.remove(at: index)
                        self.errorMessage = ""
                        self.showError = false
                    case .failure(let error):
                        self.errorMessage = "Failed to delete habit: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to delete habit: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(value)
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct CategoryFilterButton: View {
    let category: HabitCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.emoji)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : .black))
                
                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : .black))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color(red: 0.95, green: 0.62, blue: 0.56) : (scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyHabitsView: View {
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No habits yet")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.medium)
                .foregroundColor(scheme == .dark ? .white : .black)
            
            Text("Start building your first habit to see your progress here.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct EnhancedHabitRow: View {
    let habit: HabitItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    private var category: HabitCategory? {
        HabitCategory(rawValue: habit.category)
    }
    
    private var difficulty: HabitDifficulty? {
        HabitDifficulty(rawValue: habit.difficulty)
    }
    
    private var isCompletedToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let today = formatter.string(from: Date())
        return habit.log[today] == true
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon and Category
            VStack(spacing: 4) {
                Image(systemName: habit.icon)
                    .font(.system(size: 24))
                    .foregroundColor(scheme == .dark ? .white : .black)
                
                if let category = category {
                    Image(systemName: category.emoji)
                        .font(.system(size: 12))
                        .foregroundColor(scheme == .dark ? .white : .black)
                }
            }
            
            // Habit Details
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.custom("Georgia", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(scheme == .dark ? .white : .black)
                
                HStack(spacing: 8) {
                    if let category = category {
                        Text(category.displayName)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    if let difficulty = difficulty {
                        Text(difficulty.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(difficulty.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(difficulty.color.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                // Streak info
                HStack(spacing: 4) {
                    Text("🔥 \(habit.streak)")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("✅ \(habit.totalCompletions)")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onToggle) {
                    Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isCompletedToday ? .green : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Modern UI Components

// MARK: - Modern Stat Card
struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 50, height: 50)
                    .shadow(color: Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(scheme == .dark ? .white : .black)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Modern Category Filter Button
struct ModernCategoryFilterButton: View {
    let category: HabitCategory
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var scheme
    
    private var backgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            let backgroundColor = scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white
            return LinearGradient(
                gradient: Gradient(colors: [backgroundColor, backgroundColor]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: category.emoji)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)))
                
                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundGradient)
                    .shadow(color: isSelected ? Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3) : Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Habit Row
struct ModernHabitRow: View {
    let habit: HabitItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    @Environment(\.colorScheme) private var scheme
    
    private var isCompletedToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let today = formatter.string(from: Date())
        return habit.log[today] == true
    }
    
    private var circleGradient: LinearGradient {
        if isCompletedToday {
            return LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.mint]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var secondaryBackgroundColor: Color {
        scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    
    private var backgroundColor: Color {
        scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon and completion status
            ZStack {
                Image(systemName: habit.icon)
                    .font(.system(size: 24))
                    .foregroundColor(scheme == .dark ? .white : .black)
                    .opacity(isCompletedToday ? 1.0 : 0.7)
            }
            .onTapGesture {
                onToggle()
            }
            
            // Habit details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(habit.name)
                        .font(.custom("Georgia", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                        .strikethrough(isCompletedToday)
                        .opacity(isCompletedToday ? 0.6 : 1.0)
                    
                    Spacer()
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack(spacing: 12) {
                    // Category badge
                    if let category = HabitCategory(rawValue: habit.category) {
                        HStack(spacing: 4) {
                            Image(systemName: category.emoji)
                                .font(.system(size: 12))
                                .foregroundColor(scheme == .dark ? .white : .black)
                            Text(category.displayName)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(secondaryBackgroundColor)
                        )
                    }
                    
                    // Streak badge
                    if habit.streak > 0 {
                        HStack(spacing: 4) {
                            Text("🔥")
                                .font(.system(size: 12))
                            Text("\(habit.streak)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.red.opacity(0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isCompletedToday ? Color.green.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

// MARK: - Modern Empty Habits View
struct ModernEmptyHabitsView: View {
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.1), Color(red: 0.98, green: 0.75, blue: 0.65).opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
            }
            
            VStack(spacing: 8) {
                Text("No habits yet")
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Text("Start building your first habit to see it here")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}

// MARK: - Modern Habit Modal
struct ModernHabitModal: View {
    @State var habit: HabitItem
    let onSave: (HabitItem) -> Void
    let onDelete: (() -> Void)?
    let onClose: () -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let icons = ["star.fill", "leaf.fill", "heart.fill", "book.fill", "figure.walk", "drop.fill", "target", "pencil", "paintbrush.fill", "music.note", "figure.stand", "brain.head.profile", "leaf", "cup.and.saucer.fill", "applelogo", "bed.double.fill", "bolt.fill", "heart", "dollarsign.circle.fill", "globe"]
    
    private var backgroundColor: Color {
        scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white
    }
    
    private var secondaryBackgroundColor: Color {
        scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    
    private func dayBackgroundGradient(for day: String) -> LinearGradient {
        if habit.days.contains(day) {
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            let backgroundColor = scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white
            return LinearGradient(
                gradient: Gradient(colors: [backgroundColor, backgroundColor]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private func dayForegroundColor(for day: String) -> Color {
        if habit.days.contains(day) {
            return .white
        } else {
            return scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
        }
    }
    
    private func dayShadowColor(for day: String) -> Color {
        if habit.days.contains(day) {
            return Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3)
        } else {
            return Color.black.opacity(0.05)
        }
    }
    
    private var textColor: Color {
        scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    private func iconBackgroundGradient(for icon: String) -> LinearGradient {
        if habit.icon == icon {
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            let backgroundColor = scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white
            return LinearGradient(
                gradient: Gradient(colors: [backgroundColor, backgroundColor]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private func iconShadowColor(for icon: String) -> Color {
        if habit.icon == icon {
            return Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3)
        } else {
            return Color.black.opacity(0.05)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        scheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.12) : Color(red: 0.98, green: 0.97, blue: 0.95),
                        scheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.16) : Color(red: 0.95, green: 0.94, blue: 0.92)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Basics Section
                        modernBasicsSection
                        
                        // Category & Difficulty Section
                        modernCategoryDifficultySection
                        
                        // Schedule Section
                        modernScheduleSection
                        
                        // Habit Stacking Section (Atomic Habits)
                        modernHabitStackingSection
                        
                        // Cue-Routine-Reward Section (The Power of Habit)
                        modernCueRoutineRewardSection
                        
                        // Details Section
                        modernDetailsSection
                        
                        // Delete Button
                        if onDelete != nil {
                            modernDeleteButton
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Habit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onClose() }
                        .foregroundColor(scheme == .dark ? .white : .black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(habit)
                    }
                    .disabled(habit.name.isEmpty)
                    .foregroundColor(habit.name.isEmpty ? .secondary : Color(red:0.95,green:0.62,blue:0.56))
                }
            }
        }
    }
    
    // MARK: - Modern Basics Section
    private var modernBasicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
                Text("Basic Information")
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)

            VStack(spacing: 16) {
                TextField("Habit name", text: $habit.name)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(backgroundColor)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Icon")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: { habit.icon = icon }) {
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(habit.icon == icon ? .white : (scheme == .dark ? .white : .black))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(iconBackgroundGradient(for: icon))
                                            .shadow(color: iconShadowColor(for: icon), radius: 6, x: 0, y: 3)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Modern Category & Difficulty Section
    private var modernCategoryDifficultySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category & Difficulty")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(textColor)

            VStack(spacing: 16) {
                // Category Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            ModernCategorySelectionButton(
                                category: category,
                                isSelected: habit.category == category.rawValue,
                                onTap: { habit.category = category.rawValue }
                            )
                        }
                    }
                }
                
                // Difficulty Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Difficulty Level")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(HabitDifficulty.allCases, id: \.self) { difficulty in
                            ModernDifficultySelectionButton(
                                difficulty: difficulty,
                                isSelected: habit.difficulty == difficulty.rawValue,
                                onTap: { habit.difficulty = difficulty.rawValue }
                            )
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Modern Schedule Section
    private var modernScheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Schedule")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))

            VStack(spacing: 16) {
                // Frequency Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequency")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                            ModernFrequencySelectionButton(
                                frequency: frequency,
                                isSelected: habit.frequency == frequency.rawValue,
                                onTap: { habit.frequency = frequency.rawValue }
                            )
                        }
                    }
                }
                
                // Days Selection (for custom frequency)
                if habit.frequency == "custom" {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Days")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(weekDays, id: \.self) { day in
                                Button(action: {
                                    if habit.days.contains(day) {
                                        habit.days.removeAll { $0 == day }
                                    } else {
                                        habit.days.append(day)
                                    }
                                }) {
                                    Text(String(day.prefix(1)))
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(dayBackgroundGradient(for: day))
                                        )
                                                .shadow(color: dayShadowColor(for: day), radius: 4, x: 0, y: 2)
                                        .foregroundColor(dayForegroundColor(for: day))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }

                TextField("Time (e.g., 7:00 AM)", text: $habit.time)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1)
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Modern Habit Stacking Section
    private var modernHabitStackingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Habit Stacking")
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text("💡 Atomic Habits")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.95, green: 0.95, blue: 0.97))
                    )
            }

            TextField("After [existing habit], I will [new habit]", text: $habit.habitStack)
                .font(.custom("Georgia", size: 16))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(backgroundColor)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1)
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Modern Cue-Routine-Reward Section
    private var modernCueRoutineRewardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cue-Routine-Reward")
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text("💡 Power of Habit")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(secondaryBackgroundColor)
                    )
            }

            VStack(spacing: 12) {
                TextField("Cue: What triggers this habit?", text: $habit.cue)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1)
                    )
                
                TextField("Reward: What reward after completion?", text: $habit.reward)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1)
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Modern Details Section
    private var modernDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Details")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))

            TextField("Any additional notes or details...", text: $habit.description, axis: .vertical)
                .font(.custom("Georgia", size: 16))
                .lineLimit(3...6)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1)
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Modern Delete Button
    private var modernDeleteButton: some View {
        Button(action: onDelete ?? {}) {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .medium))
                Text("Delete Habit")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Modern Selection Buttons
struct ModernCategorySelectionButton: View {
    let category: HabitCategory
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var scheme
    
    private var backgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            let backgroundColor = scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white
            return LinearGradient(
                gradient: Gradient(colors: [backgroundColor, backgroundColor]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.emoji)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)))
                
                Text(category.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)))
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundGradient)
                    )
                    .shadow(color: isSelected ? Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3) : Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernDifficultySelectionButton: View {
    let difficulty: HabitDifficulty
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var scheme
    
    private var difficultyBackgroundColor: Color {
        if isSelected {
            return difficulty.color
        } else {
            return scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(difficulty.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? .white : difficulty.color)
                
                Text(difficulty.description)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(difficultyBackgroundColor)
                    .shadow(color: isSelected ? difficulty.color.opacity(0.3) : Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernFrequencySelectionButton: View {
    let frequency: HabitFrequency
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var scheme
    
    private var frequencyBackgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            let backgroundColor = scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white
            return LinearGradient(
                gradient: Gradient(colors: [backgroundColor, backgroundColor]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(frequency.displayName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(frequencyBackgroundGradient)
                        .shadow(color: isSelected ? Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3) : Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Enhanced Habit Modal
struct EnhancedHabitModal: View {
    @State var habit: HabitItem
    let onSave: (HabitItem) -> Void
    let onDelete: (() -> Void)?
    let onClose: () -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let icons = ["star.fill", "leaf.fill", "heart.fill", "book.fill", "figure.walk", "drop.fill", "target", "pencil", "paintbrush.fill", "music.note", "figure.stand", "brain.head.profile", "leaf", "cup.and.saucer.fill", "applelogo", "bed.double.fill", "bolt.fill", "heart", "dollarsign.circle.fill", "globe"]
    
    var body: some View {
        NavigationView {
            ZStack {
                (scheme == .dark ? Color(red:0.12,green:0.12,blue:0.12) : Color(red:0.97,green:0.96,blue:0.94))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Basics Section
                        basicsSection
                        
                        // Category & Difficulty Section
                        categoryDifficultySection
                        
                        // Schedule Section
                        scheduleSection
                        
                        // Habit Stacking Section (Atomic Habits)
                        habitStackingSection
                        
                        // Cue-Routine-Reward Section (The Power of Habit)
                        cueRoutineRewardSection
                        
                        // Details Section
                        detailsSection
                        
                        // Delete Button
                        if onDelete != nil {
                            deleteButton
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Habit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onClose() }
                        .foregroundColor(scheme == .dark ? .white : .black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(habit)
                    }
                    .disabled(habit.name.isEmpty)
                    .foregroundColor(habit.name.isEmpty ? .secondary : Color(red:0.95,green:0.62,blue:0.56))
                }
            }
        }
    }
    
    // MARK: - Basics Section
    private var basicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(scheme == .dark ? .white : .black)

            VStack(spacing: 12) {
                TextField("Habit name", text: $habit.name)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Icon")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(habit.icon == icon ? .white : (scheme == .dark ? .white : .black))
                                .frame(width: 44, height: 44)
                                .background(habit.icon == icon ? Color(red:0.95,green:0.62,blue:0.56).opacity(0.2) : (scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98)))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(habit.icon == icon ? Color(red:0.95,green:0.62,blue:0.56) : Color.clear, lineWidth: 2))
                                .onTapGesture {
                                    habit.icon = icon
                                }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Category & Difficulty Section
    private var categoryDifficultySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category & Difficulty")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(scheme == .dark ? .white : .black)

            VStack(spacing: 12) {
                // Category Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            CategorySelectionButton(
                                category: category,
                                isSelected: habit.category == category.rawValue,
                                onTap: { habit.category = category.rawValue }
                            )
                        }
                    }
                }
                
                // Difficulty Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty Level")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(HabitDifficulty.allCases, id: \.self) { difficulty in
                            DifficultySelectionButton(
                                difficulty: difficulty,
                                isSelected: habit.difficulty == difficulty.rawValue,
                                onTap: { habit.difficulty = difficulty.rawValue }
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Schedule Section
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Schedule")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(scheme == .dark ? .white : .black)

            VStack(spacing: 12) {
                // Frequency Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                            FrequencySelectionButton(
                                frequency: frequency,
                                isSelected: habit.frequency == frequency.rawValue,
                                onTap: { habit.frequency = frequency.rawValue }
                            )
                        }
                    }
                }
                
                // Days Selection (for custom frequency)
                if habit.frequency == "custom" {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Days")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(.secondary)
                        HStack {
                            ForEach(weekDays, id: \.self) { day in
                                Text(String(day.prefix(1)))
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(width: 36, height: 36)
                                    .background(habit.days.contains(day) ? Color(red:0.95,green:0.62,blue:0.56) : (scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98)))
                                    .foregroundColor(habit.days.contains(day) ? .white : (scheme == .dark ? .white : .black))
                                    .cornerRadius(18)
                                    .onTapGesture {
                                        if habit.days.contains(day) {
                                            habit.days.removeAll { $0 == day }
                                        } else {
                                            habit.days.append(day)
                                        }
                                    }
                            }
                        }
                    }
                }

                TextField("Time (e.g., 7:00 AM)", text: $habit.time)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Habit Stacking Section (Atomic Habits)
    private var habitStackingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Habit Stacking")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(scheme == .dark ? .white : .black)
                
                Text("(Atomic Habits)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .italic()
            }

            VStack(spacing: 12) {
                Text("After I [existing habit], I will [new habit]")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
                
                TextField("e.g., After I brush my teeth, I will do 10 push-ups", text: $habit.habitStack)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Cue-Routine-Reward Section (The Power of Habit)
    private var cueRoutineRewardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Habit Loop")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(scheme == .dark ? .white : .black)
                
                Text("(The Power of Habit)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .italic()
            }

            VStack(spacing: 12) {
                // Cue
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cue (What triggers this habit?)")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    TextField("e.g., When I see my phone, When I feel stressed", text: $habit.cue)
                        .font(.custom("Georgia", size: 16))
                        .padding(16)
                        .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
                        .cornerRadius(12)
                }
                
                // Reward
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reward (What will you do after completing?)")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                    
                    TextField("e.g., Give myself a high-five, Take a break", text: $habit.reward)
                        .font(.custom("Georgia", size: 16))
                        .padding(16)
                        .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(scheme == .dark ? .white : .black)

            VStack(spacing: 12) {
                TextField("Description", text: $habit.description, axis: .vertical)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
                    .cornerRadius(12)
                    .lineLimit(3...6)

                TextField("How will you do it? (Tiny Habits method)", text: $habit.plan, axis: .vertical)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
                    .cornerRadius(12)
                    .lineLimit(3...6)
            }
        }
    }
    
    // MARK: - Delete Button
    private var deleteButton: some View {
        Button(action: { onDelete?() }) {
            Text("Delete Habit")
                .font(.custom("Georgia", size: 16))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(scheme == .dark ? Color(red:0.3,green:0.1,blue:0.1) : Color(red:0.99,green:0.95,blue:0.95))
                .cornerRadius(12)
        }
    }
}

// MARK: - Supporting Modal Views
struct CategorySelectionButton: View {
    let category: HabitCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.emoji)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : .black))
                
                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : .black))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color(red: 0.95, green: 0.62, blue: 0.56) : (scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DifficultySelectionButton: View {
    let difficulty: HabitDifficulty
    let isSelected: Bool
    let onTap: () -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(difficulty.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : difficulty.color)
                
                Text(difficulty.description)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? difficulty.color : (scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? difficulty.color : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FrequencySelectionButton: View {
    let frequency: HabitFrequency
    let isSelected: Bool
    let onTap: () -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Button(action: onTap) {
            Text(frequency.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : (scheme == .dark ? .white : .black))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color(red: 0.95, green: 0.62, blue: 0.56) : (scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color.white))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        HabitTrackerView()
            .environmentObject(NavigationContainer.NavigationManager())
    }
}
