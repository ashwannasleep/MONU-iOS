import SwiftUI
import Amplify

class AIInsightsManager: ObservableObject {
    static let shared = AIInsightsManager()
    
    @Published var currentInsights: [AIInsight] = []
    @Published var isLoading = false
    @Published var lastUpdated = Date()
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Generate Insights
    func generateInsights() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let insights = try await analyzeUserDataWithResearch()
            
            await MainActor.run {
                self.currentInsights = insights
                self.lastUpdated = Date()
                self.isLoading = false
            }
        } catch {
            print("❌ Failed to generate insights: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to generate insights. Please try again."
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Enhanced Analysis with Research-Based Insights
    private func analyzeUserDataWithResearch() async throws -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // Fetch all user data with error handling
        let tasks = try await fetchDailyTasks()
        let habits = try await fetchHabits()
        let goals = try await fetchYearlyGoals()
        let bucketItems = try await fetchBucketItems()
        let futureGoals = try await fetchFutureGoals()
        
        // Research-based analysis with null safety
        insights.append(contentsOf: analyzeAtomicHabitsPatterns(tasks, habits))
        insights.append(contentsOf: analyzeHabitLoopPatterns(habits))
        insights.append(contentsOf: analyzeTinyHabitsImplementation(habits))
        insights.append(contentsOf: analyzeKeystoneHabits(habits, tasks))
        insights.append(contentsOf: analyzeEnvironmentDesign(habits, tasks))
        insights.append(contentsOf: analyzeIdentityBasedGoals(goals, futureGoals))
        insights.append(contentsOf: analyzeMotivationWaves(tasks, habits))
        insights.append(contentsOf: analyzeHabitStackingOpportunities(habits))
        insights.append(contentsOf: analyzeCelebrationPatterns(habits))
        insights.append(contentsOf: generateResearchBasedTips(tasks, habits, goals))
        
        // Ensure we always return some insights, even if data is empty
        if insights.isEmpty {
            insights.append(generateDefaultInsight())
        }
        
        return insights.shuffled().prefix(6).map { $0 } // Return top 6 insights
    }
    
    // MARK: - Data Fetching with Error Handling
    private func fetchDailyTasks() async throws -> [DailyTask] {
        do {
            let result = try await Amplify.API.query(request: .list(DailyTask.self))
            switch result {
            case .success(let tasks):
                return Array(tasks)
            case .failure(let error):
                print("❌ Failed to fetch daily tasks: \(error)")
                return []
            }
        } catch {
            print("❌ Error fetching daily tasks: \(error)")
            return []
        }
    }
    
    private func fetchHabits() async throws -> [Habit] {
        do {
            let result = try await Amplify.API.query(request: .list(Habit.self))
            switch result {
            case .success(let habits):
                return Array(habits)
            case .failure(let error):
                print("❌ Failed to fetch habits: \(error)")
                return []
            }
        } catch {
            print("❌ Error fetching habits: \(error)")
            return []
        }
    }
    
    private func fetchYearlyGoals() async throws -> [YearlyGoal] {
        do {
            let result = try await Amplify.API.query(request: .list(YearlyGoal.self))
            switch result {
            case .success(let goals):
                return Array(goals)
            case .failure(let error):
                print("❌ Failed to fetch yearly goals: \(error)")
                return []
            }
        } catch {
            print("❌ Error fetching yearly goals: \(error)")
            return []
        }
    }
    
    private func fetchBucketItems() async throws -> [BucketItem] {
        do {
            let result = try await Amplify.API.query(request: .list(BucketItem.self))
            switch result {
            case .success(let items):
                return Array(items)
            case .failure(let error):
                print("❌ Failed to fetch bucket items: \(error)")
                return []
            }
        } catch {
            print("❌ Error fetching bucket items: \(error)")
            return []
        }
    }
    
    private func fetchFutureGoals() async throws -> [FutureGoal] {
        do {
            let result = try await Amplify.API.query(request: .list(FutureGoal.self))
            switch result {
            case .success(let goals):
                return Array(goals)
            case .failure(let error):
                print("❌ Failed to fetch future goals: \(error)")
                return []
            }
        } catch {
            print("❌ Error fetching future goals: \(error)")
            return []
        }
    }
    
    // MARK: - Atomic Habits Analysis (James Clear) - Fixed for null safety
    private func analyzeAtomicHabitsPatterns(_ tasks: [DailyTask], _ habits: [Habit]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // Safe analysis with null checking
        let totalHabits = habits.count
        
        if totalHabits == 0 {
            insights.append(AIInsight(
                type: .habit,
                title: "Start Your Habit Journey",
                message: "From 'Atomic Habits': You haven't created any habits yet. Start with one tiny habit that takes 30 seconds. Success breeds success.",
                icon: "🌱",
                priority: .high,
                source: "Atomic Habits by James Clear",
                actionable: "Add your first habit today"
            ))
            return insights
        }
        
        // Analyze habit stacking implementation (using available fields)
        let habitsWithDescription = habits.filter { $0.description != nil && !$0.description!.isEmpty }
        let habitsWithoutDescription = habits.filter { $0.description == nil || $0.description!.isEmpty }
        
        if habitsWithoutDescription.count > habitsWithDescription.count {
            insights.append(AIInsight(
                type: .habit,
                title: "Habit Stacking Opportunity",
                message: "From 'Atomic Habits': \(habitsWithoutDescription.count) of your \(totalHabits) habits lack detailed descriptions. Try linking new habits to existing ones. Example: 'After I brush my teeth, I will do 10 push-ups.'",
                icon: "🔗",
                priority: .high,
                source: "Atomic Habits by James Clear",
                actionable: "Add habit stacking to your existing habits"
            ))
        }
        
        // Analyze environment design using available fields
        let habitsWithTime = habits.filter { $0.time != nil && !$0.time!.isEmpty }
        if habitsWithTime.count < totalHabits / 2 {
            insights.append(AIInsight(
                type: .planning,
                title: "Environment Design",
                message: "From 'Atomic Habits': Only \(habitsWithTime.count) of your \(totalHabits) habits have specific times. Make good habits obvious by scheduling them at specific times.",
                icon: "👁️",
                priority: .medium,
                source: "Atomic Habits by James Clear",
                actionable: "Add specific times to your habits"
            ))
        }
        
        return insights
    }
    
    // MARK: - Habit Loop Analysis (Charles Duhigg) - Fixed for null safety
    private func analyzeHabitLoopPatterns(_ habits: [Habit]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        let totalHabits = habits.count
        if totalHabits == 0 { return insights }
        
        // Analyze cue-routine-reward patterns using available fields
        let habitsWithPlan = habits.filter { $0.plan != nil && !$0.plan!.isEmpty }
        let habitsWithoutPlan = habits.filter { $0.plan == nil || $0.plan!.isEmpty }
        
        if habitsWithoutPlan.count > habitsWithPlan.count {
            insights.append(AIInsight(
                type: .habit,
                title: "Missing Reward System",
                message: "From 'The Power of Habit': \(habitsWithoutPlan.count) of your \(totalHabits) habits lack detailed plans. The habit loop needs a clear plan to stick. Try adding specific rewards after completing habits.",
                icon: "🎉",
                priority: .high,
                source: "The Power of Habit by Charles Duhigg",
                actionable: "Add detailed plans to your habits"
            ))
        }
        
        // Analyze keystone habits using available fields
        let morningHabits = habits.filter { habit in
            guard let time = habit.time else { return false }
            return time.contains("AM") || time.contains("morning") || time.contains("7") || time.contains("8") || time.contains("9")
        }
        
        if morningHabits.count == 0 {
            insights.append(AIInsight(
                type: .habit,
                title: "Keystone Habit Effect",
                message: "From 'The Power of Habit': You have no morning habits. Morning routines are keystone habits that trigger other positive changes. Consider adding a simple morning habit.",
                icon: "⚡",
                priority: .medium,
                source: "The Power of Habit by Charles Duhigg",
                actionable: "Add a morning keystone habit"
            ))
        }
        
        return insights
    }
    
    // MARK: - Tiny Habits Analysis (BJ Fogg) - Fixed for null safety
    private func analyzeTinyHabitsImplementation(_ habits: [Habit]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        let totalHabits = habits.count
        if totalHabits == 0 { return insights }
        
        // Analyze habit complexity using description length
        let complexHabits = habits.filter { habit in
            guard let description = habit.description else { return false }
            return description.count > 50 // Consider long descriptions as complex
        }
        
        let simpleHabits = habits.filter { habit in
            guard let description = habit.description else { return true }
            return description.count <= 30 // Consider short descriptions as simple
        }
        
        if complexHabits.count > simpleHabits.count {
            insights.append(AIInsight(
                type: .habit,
                title: "Start Tiny",
                message: "From 'Tiny Habits': You have more complex habits than simple ones. Start with tiny habits that take 30 seconds. Success breeds success.",
                icon: "🌱",
                priority: .high,
                source: "Tiny Habits by BJ Fogg",
                actionable: "Add one tiny habit this week"
            ))
        }
        
        // Analyze celebration patterns using available fields
        let habitsWithCelebration = habits.filter { habit in
            guard let plan = habit.plan else { return false }
            return plan.contains("celebrate") || plan.contains("awesome") || plan.contains("high five")
        }
        
        if habitsWithCelebration.count == 0 {
            insights.append(AIInsight(
                type: .motivation,
                title: "Celebration Missing",
                message: "From 'Tiny Habits': None of your habits include celebration. Celebration wires your brain for success. After completing a habit, say 'I'm awesome!'",
                icon: "🎊",
                priority: .medium,
                source: "Tiny Habits by BJ Fogg",
                actionable: "Add celebration to your habit completion"
            ))
        }
        
        return insights
    }
    
    // MARK: - Keystone Habits Analysis - Fixed for null safety
    private func analyzeKeystoneHabits(_ habits: [Habit], _ tasks: [DailyTask]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // Look for potential keystone habits using available fields
        let morningHabits = habits.filter { habit in
            guard let time = habit.time else { return false }
            return time.contains("AM") || time.contains("morning") || time.contains("7") || time.contains("8") || time.contains("9")
        }
        
        if morningHabits.count == 0 && habits.count > 0 {
            insights.append(AIInsight(
                type: .planning,
                title: "Keystone Habit Opportunity",
                message: "From research: Morning routines are keystone habits that trigger other positive changes. Consider adding a simple morning habit like 'drink water' or 'make bed'.",
                icon: "🌅",
                priority: .medium,
                source: "Habit Research",
                actionable: "Add a morning keystone habit"
            ))
        }
        
        return insights
    }
    
    // MARK: - Environment Design Analysis - Fixed for null safety
    private func analyzeEnvironmentDesign(_ habits: [Habit], _ tasks: [DailyTask]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // Analyze task completion patterns by time
        let morningTasks = tasks.filter { task in
            guard let time = task.time else { return false }
            return time.contains("AM") || time.contains("morning")
        }
        
        let eveningTasks = tasks.filter { task in
            guard let time = task.time else { return false }
            return time.contains("PM") || time.contains("evening")
        }
        
        if eveningTasks.count > morningTasks.count * 2 && tasks.count > 0 {
            insights.append(AIInsight(
                type: .planning,
                title: "Environment Optimization",
                message: "From 'Atomic Habits': You schedule more tasks in the evening. Consider your energy levels - most people are more productive in the morning.",
                icon: "⚡",
                priority: .medium,
                source: "Atomic Habits by James Clear",
                actionable: "Move important tasks to morning"
            ))
        }
        
        return insights
    }
    
    // MARK: - Identity-Based Goals Analysis - Fixed for null safety
    private func analyzeIdentityBasedGoals(_ goals: [YearlyGoal], _ futureGoals: [FutureGoal]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        let totalGoals = goals.count + futureGoals.count
        
        if totalGoals == 0 {
            insights.append(AIInsight(
                type: .planning,
                title: "Start Goal Setting",
                message: "From 'Atomic Habits': You haven't set any goals yet. Identity-based goals work better. Instead of 'I want to exercise,' think 'I am someone who exercises.'",
                icon: "🎯",
                priority: .high,
                source: "Atomic Habits by James Clear",
                actionable: "Add your first goal today"
            ))
            return insights
        }
        
        // Analyze goal completion patterns using available fields
        let completedGoals = goals.filter { $0.done == true }
        let yearlyGoalsCount = goals.count
        
        if yearlyGoalsCount > 0 {
            let completionRate = Double(completedGoals.count) / Double(yearlyGoalsCount)
            
            if completionRate < 0.3 {
                insights.append(AIInsight(
                    type: .planning,
                    title: "Goal Achievement Strategy",
                    message: "From 'Atomic Habits': You've completed \(completedGoals.count) of \(yearlyGoalsCount) goals. Focus on systems over goals. Break down large goals into smaller, actionable steps.",
                    icon: "🎯",
                    priority: .high,
                    source: "Atomic Habits by James Clear",
                    actionable: "Break down your goals into smaller steps"
                ))
            } else if completionRate > 0.7 {
                insights.append(AIInsight(
                    type: .motivation,
                    title: "Goal Momentum",
                    message: "From research: You're completing \(Int(completionRate * 100))% of your goals - excellent progress! This is the perfect time to set more challenging goals.",
                    icon: "🚀",
                    priority: .medium,
                    source: "Goal Achievement Research",
                    actionable: "Set one more challenging goal"
                ))
            }
        }
        
        return insights
    }
    
    // MARK: - Motivation Waves Analysis - Fixed for null safety
    private func analyzeMotivationWaves(_ tasks: [DailyTask], _ habits: [Habit]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // Analyze completion patterns
        let completedTasks = tasks.filter { $0.done == true }
        let totalTasks = tasks.count
        
        if totalTasks > 0 {
            let completionRate = Double(completedTasks.count) / Double(totalTasks)
            
            if completionRate < 0.4 {
                insights.append(AIInsight(
                    type: .motivation,
                    title: "Motivation Wave",
                    message: "From 'Atomic Habits': Your completion rate is \(Int(completionRate * 100))%. Motivation comes in waves. Focus on systems over goals.",
                    icon: "🌊",
                    priority: .high,
                    source: "Atomic Habits by James Clear",
                    actionable: "Focus on building 1-2 key habits"
                ))
            } else if completionRate > 0.8 {
                insights.append(AIInsight(
                    type: .motivation,
                    title: "Momentum Building",
                    message: "From research: You're completing \(Int(completionRate * 100))% of tasks - excellent momentum! This is the perfect time to add a new challenging habit.",
                    icon: "🚀",
                    priority: .high,
                    source: "Habit Research",
                    actionable: "Add one new challenging habit"
                ))
            }
        }
        
        return insights
    }
    
    // MARK: - Habit Stacking Opportunities - Fixed for null safety
    private func analyzeHabitStackingOpportunities(_ habits: [Habit]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // Find habits that could be stacked using available fields
        let habitsWithTime = habits.filter { $0.time != nil && !$0.time!.isEmpty }
        let habitsWithoutTime = habits.filter { $0.time == nil || $0.time!.isEmpty }
        
        if habitsWithoutTime.count > 0 && habitsWithTime.count > 0 {
            insights.append(AIInsight(
                type: .planning,
                title: "Habit Stacking Opportunity",
                message: "From 'Atomic Habits': You have \(habitsWithoutTime.count) habits without specific times. Try habit stacking: 'After [existing habit], I will [new habit].'",
                icon: "🔗",
                priority: .medium,
                source: "Atomic Habits by James Clear",
                actionable: "Stack new habits onto existing ones"
            ))
        }
        
        return insights
    }
    
    // MARK: - Celebration Patterns Analysis - Fixed for null safety
    private func analyzeCelebrationPatterns(_ habits: [Habit]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // Check for celebration in plans using available fields
        let habitsWithCelebration = habits.filter { habit in
            guard let plan = habit.plan else { return false }
            return plan.contains("celebrate") || plan.contains("awesome") || plan.contains("high five")
        }
        
        if habitsWithCelebration.count == 0 && habits.count > 0 {
            insights.append(AIInsight(
                type: .motivation,
                title: "Missing Celebration",
                message: "From 'Tiny Habits': None of your habits include celebration. Celebration is crucial for habit formation. After completing a habit, celebrate immediately.",
                icon: "🎊",
                priority: .medium,
                source: "Tiny Habits by BJ Fogg",
                actionable: "Add celebration to your habit completion"
            ))
        }
        
        return insights
    }
    
    // MARK: - Research-Based Tips - Fixed for null safety
    private func generateResearchBasedTips(_ tasks: [DailyTask], _ habits: [Habit], _ goals: [YearlyGoal]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // Time-based insights
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            insights.append(AIInsight(
                type: .motivation,
                title: "Morning Momentum",
                message: "From research: The first 2 hours of your day set the tone. Use this time for your most important task. Your willpower is highest in the morning.",
                icon: "🌅",
                priority: .medium,
                source: "Productivity Research",
                actionable: "Schedule your most important task for morning"
            ))
        } else if hour > 18 {
            insights.append(AIInsight(
                type: .motivation,
                title: "Evening Reflection",
                message: "From 'Atomic Habits': Take 5 minutes to reflect on your day. What went well? What could you improve tomorrow? Reflection builds self-awareness.",
                icon: "🌙",
                priority: .medium,
                source: "Atomic Habits by James Clear",
                actionable: "Spend 5 minutes reflecting on your day"
            ))
        }
        
        // Data-driven insights
        let totalActivities = tasks.count + habits.count + goals.count
        
        if totalActivities == 0 {
            insights.append(AIInsight(
                type: .motivation,
                title: "Start Small",
                message: "From 'Tiny Habits': You're starting fresh! Begin with one tiny habit that takes 30 seconds. Success breeds success.",
                icon: "🌱",
                priority: .high,
                source: "Tiny Habits by BJ Fogg",
                actionable: "Add one tiny habit today"
            ))
        } else if totalActivities > 15 {
            insights.append(AIInsight(
                type: .planning,
                title: "Focus on Systems",
                message: "From 'Atomic Habits': You have \(totalActivities) activities planned. Focus on systems over goals. Build habits that work even when motivation is low.",
                icon: "⚙️",
                priority: .medium,
                source: "Atomic Habits by James Clear",
                actionable: "Review and prioritize your top 3 habits"
            ))
        }
        
        return insights
    }
    
    // MARK: - Default Insight for Empty Data
    private func generateDefaultInsight() -> AIInsight {
        return AIInsight(
            type: .motivation,
            title: "Welcome to MONU",
            message: "From 'Atomic Habits': Start your journey with one tiny habit. Remember, every expert was once a beginner. Small steps lead to big changes.",
            icon: "🌟",
            priority: .high,
            source: "Atomic Habits by James Clear",
            actionable: "Add your first habit or goal today"
        )
    }
}

// MARK: - Enhanced AI Insight Model
struct AIInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let icon: String
    let priority: InsightPriority
    let source: String
    let actionable: String
    let timestamp = Date()
    
    enum InsightType {
        case productivity
        case motivation
        case planning
        case habit
        case goal
    }
    
    enum InsightPriority {
        case low
        case medium
        case high
    }
} 