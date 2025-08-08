import SwiftUI
import Amplify

// MARK: - Goal Category Enum
enum GoalCategory: String, CaseIterable {
    case health = "health"
    case relationships = "relationships"
    case growth = "growth"
    case travel = "travel"
    case environment = "environment"
    case career = "career"
    case finance = "finance"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var emoji: String {
        return ""
    }
}

// MARK: - FutureVisionView
struct FutureVisionView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date()) + 3
    @State private var goals: [GoalCategory: [FutureGoal]] = {
        var dict: [GoalCategory: [FutureGoal]] = [:]
        GoalCategory.allCases.forEach { category in
            dict[category] = []
        }
        return dict
    }()
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showYearPicker = false
    
    // Computed properties for theming
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.97, green: 0.96, blue: 0.94)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.97)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with proper spacing
                    headerView
                    
                    // Year Target Section
                    yearTargetSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    
                    // Goals Grid
                    goalsGridSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchGoals()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showYearPicker) {
            yearPickerSheet
        }
    }
    
    // MARK: - Header View
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
            
            Text("Your Future Vision")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }
    
    // MARK: - Year Target Section
    private var yearTargetSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("TO:")
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                
                Button(action: {
                    showYearPicker = true
                }) {
                    HStack(spacing: 4) {
                        Text("My future self in \(String(selectedYear))")
                            .font(.custom("Georgia", size: 18))
                            .italic()
                            .foregroundColor(textColor)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Year Picker Sheet
    private var yearPickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Your Future Year")
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(spacing: 8) {
                    Text("Year")
                        .font(.custom("Georgia", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Picker("Year", selection: $selectedYear) {
                        ForEach(2025...2100, id: \.self) { year in
                            Text(String(year))
                                .font(.custom("Georgia", size: 18))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showYearPicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Goals Grid Section
    private var goalsGridSection: some View {
        LazyVGrid(columns: gridColumns, spacing: 20) {
            ForEach(GoalCategory.allCases, id: \.self) { category in
                GoalCategoryCard(
                    category: category,
                    goals: goals[category] ?? [],
                    onGoalChange: { (index: Int, value: String) in
                        updateGoal(category: category, index: index, title: value)
                    },
                    onAddGoal: {
                        addGoal(category: category)
                    },
                    onDeleteGoal: { (index: Int) in
                        deleteGoal(category: category, index: index)
                    }
                )
            }
        }
    }
    
    // MARK: - Grid Columns
    private var gridColumns: [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 40 // Total horizontal padding
        let spacing: CGFloat = 20 // Space between columns
        let availableWidth = screenWidth - padding
        
        if screenWidth > 768 {
            // Desktop/iPad: 3 columns if wide enough, otherwise 2
            let columnCount = availableWidth > 900 ? 3 : 2
            return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
        } else {
            // Mobile: 1 column
            return [GridItem(.flexible())]
        }
    }
    
    // MARK: - Amplify Methods
    private func fetchGoals() {
        guard authManager.isAuthenticated else { return }
        
        isLoading = true
        Task {
            do {
                let result = try await Amplify.API.query(request: .list(FutureGoal.self))
                await MainActor.run {
                    switch result {
                    case .success(let items):
                        var organized: [GoalCategory: [FutureGoal]] = [:]
                        GoalCategory.allCases.forEach { category in
                            organized[category] = []
                        }
                        
                        items.forEach { item in
                            if let category = GoalCategory(rawValue: item.category) {
                                organized[category]?.append(item)
                            }
                        }
                        
                        self.goals = organized
                    case .failure(let error):
                        self.errorMessage = "Failed to load goals: \(error.localizedDescription)"
                        self.showError = true
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load goals: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func updateGoal(category: GoalCategory, index: Int, title: String) {
        guard index < (goals[category]?.count ?? 0) else { return }
        
        let goal = goals[category]?[index]
        guard let goal = goal else { return }
        
        Task {
            do {
                var updatedGoal = goal
                updatedGoal.title = title
                let result = try await Amplify.API.mutate(request: .update(updatedGoal))
                await MainActor.run {
                    switch result {
                    case .success(let savedGoal):
                        if let index = self.goals[category]?.firstIndex(where: { $0.id == goal.id }) {
                            self.goals[category]?[index] = savedGoal
                        }
                    case .failure(let error):
                        self.errorMessage = "Failed to update goal: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to update goal: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func addGoal(category: GoalCategory) {
        let newGoal = FutureGoal(
            category: category.rawValue,
            title: "",
            done: false
        )
        
        Task {
            do {
                let result = try await Amplify.API.mutate(request: .create(newGoal))
                await MainActor.run {
                    switch result {
                    case .success(let savedGoal):
                        if self.goals[category] == nil {
                            self.goals[category] = []
                        }
                        self.goals[category]?.append(savedGoal)
                    case .failure(let error):
                        self.errorMessage = "Failed to add goal: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to add goal: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func deleteGoal(category: GoalCategory, index: Int) {
        guard index < (goals[category]?.count ?? 0) else { return }
        
        let goal = goals[category]?[index]
        guard let goal = goal else { return }
        
        // Optimistically remove from UI
        goals[category]?.remove(at: index)
        
        Task {
            do {
                let result = try await Amplify.API.mutate(request: .delete(goal))
                await MainActor.run {
                    switch result {
                    case .success:
                        // Goal already removed from UI
                        break
                    case .failure(let error):
                        // Restore the goal in UI if deletion failed
                        self.goals[category]?.insert(goal, at: index)
                        self.errorMessage = "Failed to delete goal: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    // Restore the goal in UI if deletion failed
                    self.goals[category]?.insert(goal, at: index)
                    self.errorMessage = "Failed to delete goal: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
}

// MARK: - GoalCategoryCard
struct GoalCategoryCard: View {
    let category: GoalCategory
    let goals: [FutureGoal]
    let onGoalChange: (Int, String) -> Void
    let onAddGoal: () -> Void
    let onDeleteGoal: (Int) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.97)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Header
            HStack {
                Text(category.displayName)
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                
                Spacer()
            }
            
            // Goals List
            VStack(spacing: 12) {
                ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                    GoalInputRow(
                        goal: goal,
                        onTextChange: { newText in
                            onGoalChange(index, newText)
                        },
                        onDelete: {
                            onDeleteGoal(index)
                        }
                    )
                }
                
                // Add at least 3 empty slots for consistent height
                let emptySlots = max(0, 3 - goals.count)
                ForEach(0..<emptySlots, id: \.self) { _ in
                    EmptyGoalSlot()
                }
            }
            
            // Add Button
            Button(action: onAddGoal) {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                    Text("Add Goal")
                        .font(.custom("Georgia", size: 14))
                }
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color(red: 0.27, green: 0.27, blue: 0.27) : Color(red: 0.84, green: 0.81, blue: 0.78))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer() // Pushes content to top
        }
        .padding(20)
        .frame(height: 280) // Fixed height for uniform cards
        .frame(maxWidth: .infinity)
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - GoalInputRow
struct GoalInputRow: View {
    let goal: FutureGoal
    let onTextChange: (String) -> Void
    let onDelete: () -> Void
    
    @State private var goalText: String = ""
    @Environment(\.colorScheme) private var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            TextField("Enter your goal...", text: $goalText)
                .font(.custom("Georgia", size: 14))
                .italic()
                .foregroundColor(textColor)
                .textFieldStyle(PlainTextFieldStyle())
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary.opacity(0.4))
                        .offset(y: 6),
                    alignment: .bottom
                )
                .onChange(of: goalText) { _, newValue in
                    onTextChange(newValue)
                }
                .onAppear {
                    goalText = goal.title
                }
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color(red: 0.90, green: 0.64, blue: 0.62))
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 24)
    }
}

// MARK: - EmptyGoalSlot
struct EmptyGoalSlot: View {
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 24)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.2))
                    .offset(y: 6),
                alignment: .bottom
            )
    }
}

