import SwiftUI
import Amplify

// MARK: - YearlyOverviewView with Amplify Integration
struct YearlyOverviewView: View {
    @State private var selectedMonth: String? = nil
    @State private var yearlyGoals: [YearlyGoal] = []
    @State private var isLoading = false
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var themeManager: ThemeManager

    private let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var completed: Int {
        yearlyGoals.filter { $0.done == true }.count
    }
    
    private var progress: Int {
        yearlyGoals.isEmpty ? 0 : Int((Double(completed) / Double(yearlyGoals.count)) * 100)
    }

    var body: some View {
        ScrollViewReader(scrollOffset: $scrollOffset) { _ in
            VStack(spacing: 0) {
                // MONU Header
                headerView
                
                // Progress Bar
                progressView
                
                // Goal Cards
                goalCardsView
                
                // Calendar Grid
                monthlyGridView
            }
            
            // Back to Top Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    BackToTopButton(scrollOffset: $scrollOffset) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            scrollOffset = 0
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(backgroundColorView)
        .sheet(item: selectedMonthBinding) { monthWrapper in
            YearlyPopupView(selectedDate: dateForMonth(monthWrapper.value))
                .environmentObject(themeManager)
        }
        .onAppear {
            fetchYearlyGoals()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton()
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 48)
            
            Button(action: {
                navigationManager.navigate(to: .choose)
            }) {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(headerTextColor)
            }
            .padding(.bottom, 8)

            Text("Plan your year with intention ✦")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }
    
    private var progressView: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 999)
                    .fill(Color(red: 0.87, green: 0.87, blue: 0.87))
                    .frame(height: 10)

                RoundedRectangle(cornerRadius: 999)
                    .fill(progressGradient)
                    .frame(width: progressWidth, height: 10)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
            .frame(maxWidth: 300)

            Text("\(progress)% complete")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 32)
    }
    
    private var goalCardsView: some View {
        VStack(spacing: 12) {
            if isLoading {
                ForEach(0..<5, id: \.self) { _ in
                    goalCardPlaceholder
                }
            } else {
                // Ensure exactly 5 goals are shown
                ForEach(allGoalsForDisplay, id: \.id) { goal in
                    YearlyGoalCardView(
                        goal: goal,
                        colorScheme: colorScheme,
                        onToggleDone: { toggleGoalDone(goal) },
                        onUpdateTitle: { newTitle in updateGoalTitle(goal, newTitle: newTitle) }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
    }
    
    private var goalCardPlaceholder: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 24, height: 24)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(cardBackground)
    }
    
    private var monthlyGridView: some View {
        LazyVGrid(columns: gridColumns, spacing: 24) {
            ForEach(months, id: \.self) { month in
                MonthCardView(month: month) {
                    selectedMonth = month
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    // MARK: - Computed Properties
    
    private var headerTextColor: Color {
        colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    
    private var backgroundColorView: Color {
        colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.97, green: 0.96, blue: 0.94)
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                themeManager.accentColor,
                themeManager.accentColor.opacity(0.7)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var progressWidth: CGFloat {
        CGFloat(progress) / 100 * 300
    }
    
    private var sortedGoals: [YearlyGoal] {
        yearlyGoals.sorted(by: { ($0.order ?? 0) < ($1.order ?? 0) })
    }
    
    // Ensure we always have exactly 5 goals to display
    private var allGoalsForDisplay: [YearlyGoal] {
        var displayGoals = sortedGoals
        
        // If we have fewer than 5 goals, create temporary ones for display
        while displayGoals.count < 5 {
            let tempGoal = YearlyGoal(
                year: currentYear,
                title: "",
                order: displayGoals.count,
                done: false
            )
            displayGoals.append(tempGoal)
        }
        
        return Array(displayGoals.prefix(5))
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 24),
            GridItem(.flexible(), spacing: 24)
        ]
    }
    
    private var selectedMonthBinding: Binding<IdentifiableString?> {
        Binding<IdentifiableString?>(
            get: { selectedMonth.map(IdentifiableString.init) },
            set: { selectedMonth = $0?.value }
        )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : Color.white)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Amplify Functions
    
    private func fetchYearlyGoals() {
        isLoading = true
        Task {
            do {
                let result = try await Amplify.API.query(request: .list(YearlyGoal.self)).get()
                DispatchQueue.main.async {
                    self.yearlyGoals = result.filter { $0.year == self.currentYear }
                    self.isLoading = false
                    
                    // Create default goals if none exist
                    if self.yearlyGoals.isEmpty {
                        self.createDefaultGoals()
                    }
                }
            } catch {
                print("Error fetching yearly goals: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.createDefaultGoals()
                }
            }
        }
    }
    
    private func createDefaultGoals() {
        Task {
            for index in 0..<5 {
                let newGoal = YearlyGoal(
                    year: currentYear,
                    title: "",
                    order: index,
                    done: false
                )
                
                do {
                    let result = try await Amplify.API.mutate(request: .create(newGoal)).get()
                    DispatchQueue.main.async {
                        self.yearlyGoals.append(result)
                    }
                } catch {
                    print("Error creating default goal \(index): \(error)")
                }
            }
        }
    }
    
    private func toggleGoalDone(_ goal: YearlyGoal) {
        // If this is a temporary goal (no ID), create it first
        if goal.id.isEmpty {
            let newGoal = YearlyGoal(
                year: currentYear,
                title: goal.title,
                order: goal.order ?? 0,
                done: true
            )
            
            Task {
                do {
                    let result = try await Amplify.API.mutate(request: .create(newGoal)).get()
                    DispatchQueue.main.async {
                        self.yearlyGoals.append(result)
                    }
                } catch {
                    print("Error creating new goal: \(error)")
                }
            }
        } else {
            // Update existing goal
            var updatedGoal = goal
            updatedGoal.done = !(goal.done ?? false)
            
            Task {
                do {
                    let result = try await Amplify.API.mutate(request: .update(updatedGoal)).get()
                    DispatchQueue.main.async {
                        if let index = self.yearlyGoals.firstIndex(where: { $0.id == goal.id }) {
                            self.yearlyGoals[index] = result
                        }
                    }
                } catch {
                    print("Error toggling goal done: \(error)")
                }
            }
        }
    }
    
    private func updateGoalTitle(_ goal: YearlyGoal, newTitle: String) {
        // If this is a temporary goal (no ID), create it first
        if goal.id.isEmpty {
            let newGoal = YearlyGoal(
                year: currentYear,
                title: newTitle,
                order: goal.order ?? 0,
                done: false
            )
            
            Task {
                do {
                    let result = try await Amplify.API.mutate(request: .create(newGoal)).get()
                    DispatchQueue.main.async {
                        self.yearlyGoals.append(result)
                    }
                } catch {
                    print("Error creating new goal: \(error)")
                }
            }
        } else {
            // Update existing goal
            var updatedGoal = goal
            updatedGoal.title = newTitle
            
            Task {
                do {
                    let result = try await Amplify.API.mutate(request: .update(updatedGoal)).get()
                    DispatchQueue.main.async {
                        if let index = self.yearlyGoals.firstIndex(where: { $0.id == goal.id }) {
                            self.yearlyGoals[index] = result
                        }
                    }
                } catch {
                    print("Error updating goal title: \(error)")
                }
            }
        }
    }
    
    private func dateForMonth(_ monthName: String) -> Date {
        let monthIndex = Calendar.current.monthSymbols.firstIndex(of: monthName) ?? 0
        return Calendar.current.date(from: DateComponents(year: currentYear, month: monthIndex + 1, day: 1)) ?? Date()
    }
}

// MARK: - YearlyGoalCardView
struct YearlyGoalCardView: View {
    let goal: YearlyGoal
    let colorScheme: ColorScheme
    let onToggleDone: () -> Void
    let onUpdateTitle: (String) -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggleDone) {
                Image(systemName: goal.done == true ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                                            .foregroundColor(goal.done == true ? themeManager.accentColor : Color.gray)
            }

            TextField("Goal \((goal.order ?? 0) + 1)", text: titleBinding)
                .font(.system(size: 18, design: .serif))
                .foregroundColor(textColor)
                .strikethrough(goal.done == true)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(cardBackground)
    }
    
    private var titleBinding: Binding<String> {
        Binding(
            get: { goal.title },
            set: onUpdateTitle
        )
    }
    
    private var textColor: Color {
        if goal.done == true {
            return .secondary
        }
        return colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : Color.white)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - MonthCardView
struct MonthCardView: View {
    let month: String
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme

    private var monthData: (daysInMonth: Int, firstDayOfWeek: Int, monthIndex: Int) {
        let monthIndex = Calendar.current.monthSymbols.firstIndex(of: month) ?? 0
        let currentYear = Calendar.current.component(.year, from: Date())
        
        guard let date = Calendar.current.date(from: DateComponents(year: currentYear, month: monthIndex + 1, day: 1)) else {
            return (31, 0, monthIndex)
        }
        
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 31
        let firstDayOfWeek = Calendar.current.component(.weekday, from: date) - 1 // 0 = Sunday
        
        return (daysInMonth, firstDayOfWeek, monthIndex)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(month)
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .foregroundColor(textColor)

                // Calendar grid with proper day positioning
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                    ForEach(0..<42, id: \.self) { index in
                        let dayNumber = index - monthData.firstDayOfWeek + 1
                        
                        if dayNumber > 0 && dayNumber <= monthData.daysInMonth {
                            Text("\(dayNumber)")
                                .font(.system(size: 11))
                                .foregroundColor(dayTextColor)
                                .frame(width: 16, height: 16)
                        } else {
                            Text("")
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
    
    private var dayTextColor: Color {
        colorScheme == .dark ? Color(red: 0.8, green: 0.8, blue: 0.8) : Color(red: 0.27, green: 0.27, blue: 0.27)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : Color.white)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
    }
}

// MARK: - Supporting Types
struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}
