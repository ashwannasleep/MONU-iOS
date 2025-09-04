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
        case .easy: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .medium: return Color(red: 0.9, green: 0.6, blue: 0.2)
        case .hard: return Color(red: 0.9, green: 0.3, blue: 0.3)
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

// MARK: - Fixed HabitItem Model with Enhanced Streak Logic
struct HabitItem: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var icon: String
    var mood: String
    var days: [String]
    var description: String
    var time: String
    var plan: String
    var log: [String: Bool]          // dateKey -> Bool
    var color: String
    var owner: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    // Prevent weekday pollution in logs
    private static let weekdayKeys: Set<String> = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    
    // Computed properties for enhanced features
    var category: String {
        get { mood }
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
    
    // MARK: - Date-based streak
    var streak: Int {
        get {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            var streak = 0
            var currentDate = today
            let maxDaysToCheck = 365
            
            for _ in 0..<maxDaysToCheck {
                let dayName = getDayName(for: currentDate)
                if days.contains(dayName) {
                    let dateKey = getDateKey(for: currentDate)
                    let isCompleted = log[dateKey] == true // ✅ date-only
                    if isCompleted {
                        streak += 1
                    } else {
                        break
                    }
                }
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            }
            return streak
        }
        set { /* read-only */ }
    }
    
    var totalCompletions: Int {
        get { log.values.filter { $0 }.count }
        set { /* read-only */ }
    }
    
    // MARK: - Helper Methods for Date Handling
    private func getDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func getDateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Enhanced Completion Tracking (date-only)
    mutating func toggleCompletion(for date: Date = Date()) {
        let dateKey = getDateKey(for: date)
        let currentValue = log[dateKey] ?? false
        log[dateKey] = !currentValue          // ✅ write date key only
    }
    
    func isCompleted(on date: Date = Date()) -> Bool {
        let dateKey = getDateKey(for: date)
        return log[dateKey] == true           // ✅ date-only
    }

    init(id: String = UUID().uuidString, name: String = "", icon: String = "star.fill", mood: String = "health", days: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], description: String = "", time: String = "", plan: String = "Difficulty: medium", log: [String: Bool] = [:], color: String = "neutral") {
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

// MARK: - Enhanced Amplify Conversion with Debugging
extension HabitItem {
    init(apiModel: Habit) {
        self.id = apiModel.id
        self.name = apiModel.name
        self.icon = apiModel.icon ?? "star.fill"
        self.mood = apiModel.mood ?? "health"
        self.days = apiModel.days?.compactMap { $0 } ?? ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        self.description = apiModel.description ?? ""
        self.time = apiModel.time ?? ""
        self.plan = apiModel.plan ?? "Difficulty: medium"
        
        // Parse JSON first; fallback to legacy CSV; drop weekday keys
        var logDict: [String: Bool] = [:]
        if let apiLog = apiModel.log, !apiLog.isEmpty {
            if let data = apiLog.data(using: .utf8),
               let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                for (k, v) in decoded {
                    if let b = v as? Bool { logDict[k] = b }
                    else if let s = v as? String { logDict[k] = (s as NSString).boolValue }
                    else if let n = v as? NSNumber { logDict[k] = n.boolValue }
                }
            } else {
                // Legacy "key:value,key:value"
                for entry in apiLog.split(separator: ",") {
                    let parts = entry.split(separator: ":")
                    if parts.count == 2 {
                        let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                        let val = String(parts[1]).trimmingCharacters(in: .whitespaces)
                        logDict[key] = val.lowercased() == "true"
                    }
                }
            }
            for wk in HabitItem.weekdayKeys { logDict.removeValue(forKey: wk) }
        }
        self.log = logDict
        
        self.color = apiModel.color ?? "neutral"
        self.owner = apiModel.owner
        self.createdAt = apiModel.createdAt?.foundationDate
        self.updatedAt = apiModel.updatedAt?.foundationDate
    }

    func toAPIHabit() -> Habit {
        // Serialize to JSON; safe fallback to legacy if needed
        let logString: String?
        if log.isEmpty {
            logString = nil
        } else if let data = try? JSONSerialization.data(withJSONObject: log, options: []),
                  let json = String(data: data, encoding: .utf8) {
            logString = json
        } else {
            logString = log.map { "\($0.key):\($0.value)" }.joined(separator: ",")
        }
        
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

// MARK: - Modern Habit Modal
struct ModernHabitModal: View {
    @State var habit: HabitItem
    let onSave: (HabitItem) -> Void
    let onDelete: (() -> Void)?
    let onClose: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let icons = ["star.fill", "leaf.fill", "heart.fill", "book.fill", "figure.walk", "drop.fill", "target", "pencil", "paintbrush.fill", "music.note", "figure.stand", "brain.head.profile", "leaf", "cup.and.saucer.fill", "applelogo", "bed.double.fill", "bolt.fill", "heart", "dollarsign.circle.fill", "globe"]
    
    private var backgroundColor: Color { themeManager.cardBackgroundColor }
    private var secondaryBackgroundColor: Color { themeManager.colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.95, green: 0.95, blue: 0.97) }
    private var textColor: Color { themeManager.textColor }
    
    private func dayBackgroundGradient(for day: String) -> LinearGradient {
        if habit.days.contains(day) {
            return LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
        }
        let c = themeManager.cardBackgroundColor
        return LinearGradient(gradient: Gradient(colors: [c, c]), startPoint: .leading, endPoint: .trailing)
    }
    private func dayForegroundColor(for day: String) -> Color { habit.days.contains(day) ? .white : themeManager.textColor }
    private func dayShadowColor(for day: String) -> Color { habit.days.contains(day) ? themeManager.accentColor.opacity(0.3) : Color.black.opacity(0.05) }
    private func iconBackgroundGradient(for icon: String) -> LinearGradient {
        if habit.icon == icon {
            return LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
        }
        let c = themeManager.cardBackgroundColor
        return LinearGradient(gradient: Gradient(colors: [c, c]), startPoint: .leading, endPoint: .trailing)
    }
    private func iconShadowColor(for icon: String) -> Color { habit.icon == icon ? themeManager.accentColor.opacity(0.3) : Color.black.opacity(0.05) }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        themeManager.colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.97, blue: 0.95),
                        themeManager.colorScheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.08) : Color(red: 0.95, green: 0.94, blue: 0.92)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        modernBasicsSection
                        modernCategoryDifficultySection
                        modernScheduleSection
                        modernHabitStackingSection
                        modernCueRoutineRewardSection
                        modernDetailsSection
                        if onDelete != nil { modernDeleteButton }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Habit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onClose() }
                        .foregroundColor(themeManager.textColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { onSave(habit) }
                        .disabled(habit.name.isEmpty)
                        .foregroundColor(habit.name.isEmpty ? .secondary : themeManager.accentColor)
                }
            }
        }
    }
    
    // MARK: - Sections
    private var modernBasicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.custom("Georgia", size: 20)).fontWeight(.semibold).foregroundColor(textColor)

            VStack(spacing: 16) {
                TextField("Habit name", text: $habit.name)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 12).fill(backgroundColor).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Icon").font(.custom("Georgia", size: 14)).foregroundColor(.secondary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: { habit.icon = icon }) {
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(habit.icon == icon ? .white : themeManager.textColor)
                                    .frame(width: 50, height: 50)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(iconBackgroundGradient(for: icon)).shadow(color: iconShadowColor(for: icon), radius: 6, x: 0, y: 3))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(backgroundColor).shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6))
    }
    
    private var modernCategoryDifficultySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category & Difficulty")
                .font(.custom("Georgia", size: 20)).fontWeight(.semibold).foregroundColor(textColor)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category").font(.custom("Georgia", size: 14)).foregroundColor(.secondary)
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Difficulty Level").font(.custom("Georgia", size: 14)).foregroundColor(.secondary)
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
        .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6))
    }
    
    private var modernScheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Schedule")
                .font(.custom("Georgia", size: 20)).fontWeight(.semibold).foregroundColor(themeManager.textColor)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequency").font(.custom("Georgia", size: 14)).foregroundColor(.secondary)
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
                
                if habit.frequency == "custom" {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Days").font(.custom("Georgia", size: 14)).foregroundColor(.secondary)
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
                                        .background(Circle().fill(dayBackgroundGradient(for: day)))
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
                    .background(RoundedRectangle(cornerRadius: 12).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6))
    }
    
    private var modernHabitStackingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Habit Stacking").font(.custom("Georgia", size: 20)).fontWeight(.semibold).foregroundColor(textColor)
                Spacer()
                Text("Atomic Habits")
                    .font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(themeManager.colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.95, green: 0.95, blue: 0.97)))
            }

            TextField("After [existing habit], I will [new habit]", text: $habit.habitStack)
                .font(.custom("Georgia", size: 16))
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(backgroundColor).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1))
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6))
    }
    
    private var modernCueRoutineRewardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cue-Routine-Reward").font(.custom("Georgia", size: 20)).fontWeight(.semibold).foregroundColor(textColor)
                Spacer()
                Text("Power of Habit").font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4).background(Capsule().fill(secondaryBackgroundColor))
            }

            VStack(spacing: 12) {
                TextField("Cue: What triggers this habit?", text: $habit.cue)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 12).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1))
                
                TextField("Reward: What reward after completion?", text: $habit.reward)
                    .font(.custom("Georgia", size: 16))
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 12).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6))
    }
    
    private var modernDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Details").font(.custom("Georgia", size: 20)).fontWeight(.semibold).foregroundColor(themeManager.textColor)

            TextField("Any additional notes or details...", text: $habit.description, axis: .vertical)
                .font(.custom("Georgia", size: 16))
                .lineLimit(3...6)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.82, green: 0.84, blue: 0.87), lineWidth: 1))
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6))
    }
    
    private var modernDeleteButton: some View {
        Button(action: onDelete ?? {}) {
            HStack(spacing: 8) {
                Image(systemName: "trash").font(.system(size: 16, weight: .medium))
                Text("Delete Habit").font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
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
    @EnvironmentObject var themeManager: ThemeManager
    
    private var backgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
        } else {
            let c = themeManager.cardBackgroundColor
            return LinearGradient(gradient: Gradient(colors: [c, c]), startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.emoji).font(.system(size: 16)).foregroundColor(isSelected ? .white : themeManager.textColor)
                Text(category.displayName).font(.system(size: 12, weight: .medium)).foregroundColor(isSelected ? .white : themeManager.textColor)
                Spacer()
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(backgroundGradient)
                .shadow(color: isSelected ? themeManager.accentColor.opacity(0.3) : Color.black.opacity(0.05), radius: 4, x: 0, y: 2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernDifficultySelectionButton: View {
    let difficulty: HabitDifficulty
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private var difficultyBackgroundColor: Color { isSelected ? difficulty.color : themeManager.cardBackgroundColor }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(difficulty.displayName).font(.system(size: 12, weight: .semibold)).foregroundColor(isSelected ? .white : difficulty.color)
                Text(difficulty.description).font(.system(size: 10)).foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(difficultyBackgroundColor)
                .shadow(color: isSelected ? difficulty.color.opacity(0.3) : Color.black.opacity(0.05), radius: 4, x: 0, y: 2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernFrequencySelectionButton: View {
    let frequency: HabitFrequency
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private var frequencyBackgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
        } else {
            let c = themeManager.cardBackgroundColor
            return LinearGradient(gradient: Gradient(colors: [c, c]), startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(frequency.displayName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : themeManager.textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(frequencyBackgroundGradient)
                    .shadow(color: isSelected ? themeManager.accentColor.opacity(0.3) : Color.black.opacity(0.05), radius: 4, x: 0, y: 2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Main Habit Tracker View
struct HabitTrackerView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var habits: [HabitItem] = []
    @State private var selectedHabit: HabitItem?
    @State private var selectedHabitIndex: Int?
    @State private var showHabitModal = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var selectedCategory: HabitCategory? = nil
    @State private var showCategoryFilter = false
    
    // Animation states
    @State private var animateCards = false
    @State private var animateProgress = false

    private var todayCompletionRate: Double {
        let todayKey = getCurrentDateKey()
        let completedToday = habits.filter { $0.log[todayKey] == true || $0.isCompleted() }.count
        let scheduledToday = habits.filter { $0.days.contains(getTodayName()) }.count
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

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.backgroundColor,
                    themeManager.colorScheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.08) : Color(red: 0.95, green: 0.94, blue: 0.92)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 32) {
                    modernHeader
                    modernProgressSection
                    modernStatsSection
                    modernCategoryFilter
                    modernHabitsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showHabitModal) {
            ModernHabitModal(
                habit: selectedHabit ?? createNewHabit(),
                onSave: { updatedHabit in
                    saveHabit(updatedHabit)
                    showHabitModal = false
                    selectedHabit = nil
                },
                onDelete: selectedHabitIndex != nil ? {
                    deleteHabit()
                    showHabitModal = false
                    selectedHabit = nil
                } : nil,
                onClose: {
                    showHabitModal = false
                    selectedHabit = nil
                }
            )
            .environmentObject(themeManager)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) { animateCards = true }
            withAnimation(.easeOut(duration: 1.2).delay(0.4)) { animateProgress = true }
            Task {
                var attempts = 0
                while !authManager.isAuthenticated && attempts < 10 {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    attempts += 1
                }
                if authManager.isAuthenticated { fetchHabits() }
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated && habits.isEmpty { fetchHabits() }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: { Text(errorMessage) }
    }
    
    // MARK: - Create New Habit
    private func createNewHabit() -> HabitItem {
        HabitItem(
            id: UUID().uuidString,
            name: "",
            icon: "star.fill",
            mood: "health",
            days: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            description: "",
            time: "",
            plan: "Difficulty: medium",
            log: [:],
            color: "neutral"
        )
    }

    // MARK: - Header
    private var modernHeader: some View {
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
            
            Text("Build lasting habits for success")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }

    // MARK: - Progress
    private var modernProgressSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today Progress")
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textColor)
                    
                    Text("\(Int(todayCompletionRate * 100))% complete")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(
                            themeManager.colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.9, green: 0.9, blue: 0.92),
                            lineWidth: 8
                        )
                    
                    Circle()
                        .trim(from: 0, to: todayCompletionRate)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]),
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
                    .fill(themeManager.cardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Stats
    private var modernStatsSection: some View {
        HStack(spacing: 16) {
            ModernStatCard(title: "Total Streak", value: "\(totalStreak)", icon: "🔥",
                           gradient: LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            ModernStatCard(title: "Completions", value: "\(totalCompletions)", icon: "✅",
                           gradient: LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            ModernStatCard(title: "Active Habits", value: "\(habits.count)", icon: "📊",
                           gradient: LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Category Filter
    private var modernCategoryFilter: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Filter by Category").font(.custom("Georgia", size: 18)).fontWeight(.semibold).foregroundColor(themeManager.textColor)
                Spacer()
                Button(action: { showCategoryFilter.toggle() }) {
                    HStack(spacing: 8) {
                        Text(selectedCategory?.displayName ?? "All Categories").font(.system(size: 14, weight: .medium)).foregroundColor(themeManager.textColor)
                        Image(systemName: "chevron.down").font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                            .rotationEffect(.degrees(showCategoryFilter ? 180 : 0))
                            .animation(.easeInOut(duration: 0.2), value: showCategoryFilter)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4))
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
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - List
    private var modernHabitsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Your Habits").font(.custom("Georgia", size: 22)).fontWeight(.semibold).foregroundColor(themeManager.textColor)
                Spacer()
                Button(action: {
                    selectedHabit = HabitItem()
                    selectedHabitIndex = nil
                    showHabitModal = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus").font(.system(size: 16, weight: .semibold))
                        Text("Add Habit").font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
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
    
    // MARK: - Helpers
    private func getCurrentDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    private func getTodayName() -> String {
        let f = DateFormatter(); f.dateFormat = "EEE"
        return f.string(from: Date())
    }
    
    private func toggleHabit(_ habit: HabitItem) {
        var updatedHabit = habit
        updatedHabit.toggleCompletion()
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = updatedHabit
        }
        saveHabit(updatedHabit)
    }
    
    private func fetchHabits() {
        isLoading = true; errorMessage = ""; showError = false
        Task {
            do {
                let result = try await Amplify.API.query(request: .list(Habit.self))
                await MainActor.run {
                    switch result {
                    case .success(let items):
                        self.habits = items.map { HabitItem(apiModel: $0) }
                        self.errorMessage = ""; self.showError = false
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
                let existingIndex = self.habits.firstIndex(where: { $0.id == habit.id })
                let result: GraphQLResponse<Habit> = (existingIndex != nil)
                    ? try await Amplify.API.mutate(request: .update(apiHabit))
                    : try await Amplify.API.mutate(request: .create(apiHabit))
                
                await MainActor.run {
                    switch result {
                    case .success(let saved):
                        let item = HabitItem(apiModel: saved)
                        if let idx = existingIndex { self.habits[idx] = item } else { self.habits.append(item) }
                        self.errorMessage = ""; self.showError = false
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
            errorMessage = "Invalid habit selection"; showError = true; return
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
                        self.errorMessage = ""; self.showError = false
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

// MARK: - Modern UI Components
struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text(icon).font(.system(size: 24))
            VStack(spacing: 4) {
                Text(value).font(.custom("Georgia", size: 20)).fontWeight(.bold).foregroundColor(themeManager.textColor)
                Text(title).font(.system(size: 12, weight: .medium)).foregroundColor(.secondary).multilineTextAlignment(.center).lineLimit(nil).fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4))
    }
}

struct ModernCategoryFilterButton: View {
    let category: HabitCategory
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private var backgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
        } else {
            let c = themeManager.cardBackgroundColor
            return LinearGradient(gradient: Gradient(colors: [c, c]), startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: category.emoji).font(.system(size: 20)).foregroundColor(isSelected ? .white : themeManager.textColor)
                Text(category.displayName).font(.system(size: 14, weight: .medium)).foregroundColor(isSelected ? .white : themeManager.textColor)
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 12).fill(backgroundGradient)
                .shadow(color: isSelected ? themeManager.accentColor.opacity(0.3) : Color.black.opacity(0.05), radius: 6, x: 0, y: 3))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Habit Row (theme-aware outline; no bright green)
struct ModernHabitRow: View {
    let habit: HabitItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private var isCompletedToday: Bool { habit.isCompleted() }
    private var secondaryBackgroundColor: Color {
        themeManager.colorScheme == .dark
        ? Color(red: 0.2, green: 0.2, blue: 0.25)
        : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    private var backgroundColor: Color { themeManager.cardBackgroundColor }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: habit.icon)
                .font(.system(size: 24))
                .foregroundColor(themeManager.textColor)
                .opacity(isCompletedToday ? 1.0 : 0.7)
                .onTapGesture { onToggle() }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(habit.name)
                        .font(.custom("Georgia", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textColor)
                        .strikethrough(isCompletedToday)
                        .opacity(isCompletedToday ? 0.68 : 1.0)
                    Spacer()
                    Button(action: onEdit) {
                        Image(systemName: "pencil").font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                    }.buttonStyle(PlainButtonStyle())
                }
                
                HStack(spacing: 12) {
                    if let category = HabitCategory(rawValue: habit.category) {
                        HStack(spacing: 4) {
                            Image(systemName: category.emoji).font(.system(size: 12)).foregroundColor(themeManager.textColor)
                            Text(category.displayName).font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Capsule().fill(secondaryBackgroundColor))
                    }
                    
                    if habit.streak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill").font(.system(size: 12))
                            Text("\(habit.streak)").font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange.opacity(0.18), Color.red.opacity(0.18)]),
                                    startPoint: .leading, endPoint: .trailing
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
                .stroke(isCompletedToday ? themeManager.accentColor.opacity(0.12) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Modern Empty Habits View
struct ModernEmptyHabitsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [themeManager.accentColor.opacity(0.1), themeManager.accentColor.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: "leaf.fill").font(.system(size: 32)).foregroundColor(themeManager.accentColor)
            }
            VStack(spacing: 8) {
                Text("No habits yet").font(.custom("Georgia", size: 20)).fontWeight(.semibold).foregroundColor(themeManager.textColor)
                Text("Start building your first habit to see it here").font(.system(size: 14)).foregroundColor(.secondary).multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .background(RoundedRectangle(cornerRadius: 20).fill(themeManager.cardBackgroundColor).shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6))
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        HabitTrackerView()
            .environmentObject(NavigationContainer.NavigationManager())
            .environmentObject(AuthenticationManager())
            // NOTE: ThemeManager() likely has a private init.
            // In the real app, it's provided at the root. For previews:
            // .environmentObject(ThemeManager.shared)
    }
}

