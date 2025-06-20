import SwiftUI

// MARK: - Elegant User Guide View
struct UserGuideView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedSection: GuideSection = .welcome
    @State private var showQuickStart = false
    
    enum GuideSection: String, CaseIterable {
        case welcome = "Welcome"
        case dashboard = "Dashboard"
        case habits = "Habits"
        case goals = "Goals"
        case aiInsights = "AI Insights"
        case tips = "Tips"
        
        var icon: String {
            switch self {
            case .welcome: return "🌟"
            case .dashboard: return "📊"
            case .habits: return "🌱"
            case .goals: return "🎯"
            case .aiInsights: return "🤖"
            case .tips: return "💡"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Elegant gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(red: 0.06, green: 0.06, blue: 0.08) : Color(red: 0.98, green: 0.97, blue: 0.95),
                    colorScheme == .dark ? Color(red: 0.10, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.94, blue: 0.92)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Elegant header
                elegantHeaderView
                
                // Main content
                ScrollView {
                    VStack(spacing: 0) {
                        // Quick Start Button
                        elegantQuickStartButton
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                        
                        // Guide Content
                        elegantGuideContent
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showQuickStart) {
            ElegantQuickStartGuide()
        }
    }
    
    // MARK: - Elegant Header View
    private var elegantHeaderView: some View {
        VStack(spacing: 0) {
            Button { navigationManager.navigateToRoot() } label: {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
            }
            .buttonStyle(.plain)
            .padding(.top, 48)
            .padding(.bottom, 8)
            
            Text("Master the art of mindful planning")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }
    
    // MARK: - Elegant Quick Start Button
    private var elegantQuickStartButton: some View {
        Button(action: {
            showQuickStart = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                                    Text(languageManager.localizedString(.quickStart))
                    .font(.custom("Georgia", size: 18))
                    .foregroundColor(textColor)
                    
                    Text(languageManager.localizedString(.getStartedInMinutes))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.16) : Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Elegant Guide Content
    private var elegantGuideContent: some View {
        VStack(spacing: 32) {
            // Elegant Section Navigation
            elegantSectionNavigation
            
            // Content based on selected section
            switch selectedSection {
            case .welcome:
                elegantWelcomeSection
            case .dashboard:
                elegantDashboardSection
            case .habits:
                elegantHabitsSection
            case .goals:
                elegantGoalsSection
            case .aiInsights:
                elegantAIInsightsSection
            case .tips:
                elegantTipsSection
            }
        }
    }
    
    // MARK: - Elegant Section Navigation
    private var elegantSectionNavigation: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(GuideSection.allCases, id: \.self) { section in
                    ElegantSectionButton(
                        section: section,
                        isSelected: selectedSection == section,
                        action: { selectedSection = section }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Elegant Welcome Section
    private var elegantWelcomeSection: some View {
        VStack(spacing: 32) {
            // Welcome Message
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.2), Color(red: 0.98, green: 0.75, blue: 0.65).opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text("🌟")
                        .font(.system(size: 40))
                }
                
                VStack(spacing: 8) {
                    Text(languageManager.localizedString(.welcomeToMonu))
                        .font(.custom("Georgia", size: 28))
                        .foregroundColor(textColor)
                    
                    Text(languageManager.localizedString(.mindfulPlanningCompanion))
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // What is MONU
            ElegantGuideCard(
                title: languageManager.localizedString(.whatIsMonu),
                content: languageManager.localizedString(.monuDescription),
                icon: "🧠",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Key Features
            VStack(spacing: 20) {
                Text(languageManager.localizedString(.keyFeatures))
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(textColor)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ElegantFeatureCard(icon: "📊", title: "Dashboard", description: "Track your progress across all areas")
                    ElegantFeatureCard(icon: "🌱", title: "Habit Building", description: "Research-based habit formation")
                    ElegantFeatureCard(icon: "🎯", title: "Goal Setting", description: "Yearly, monthly, and daily planning")
                    ElegantFeatureCard(icon: "🤖", title: "AI Insights", description: "Personalized guidance and tips")
                }
            }
        }
    }
    
    // MARK: - Elegant Dashboard Section
    private var elegantDashboardSection: some View {
        VStack(spacing: 32) {
            ElegantGuideCard(
                title: "Dashboard Overview",
                content: "Your dashboard provides a comprehensive view of your progress across all areas of your life. It shows completion rates, streaks, and personalized insights to keep you motivated.",
                icon: "📊",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.mint]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            VStack(spacing: 20) {
                Text("Dashboard Features")
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(textColor)
                
                VStack(spacing: 16) {
                    ElegantFeatureRow(icon: "📈", title: "Progress Cards", description: "Visual progress for daily, yearly, bucket list, and future goals")
                    ElegantFeatureRow(icon: "🔥", title: "Focus Card", description: "Today's tasks and weekly statistics")
                    ElegantFeatureRow(icon: "🤖", title: "AI Insights", description: "Research-based personalized guidance")
                    ElegantFeatureRow(icon: "📊", title: "Statistics", description: "Total streaks, completions, and active habits")
                }
            }
            
            ElegantGuideCard(
                title: "How to Use",
                content: "• Check your dashboard daily to see your progress\n• Use the progress cards to understand completion rates\n• Read AI insights for personalized tips\n• Focus on today's tasks for immediate action",
                icon: "💡",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.yellow]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // MARK: - Elegant Habits Section
    private var elegantHabitsSection: some View {
        VStack(spacing: 32) {
            ElegantGuideCard(
                title: "Building Lasting Habits",
                content: "MONU's habit system is based on research from 'Atomic Habits', 'The Power of Habit', and 'Tiny Habits'. It helps you create habits that stick through proven strategies.",
                icon: "🌱",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.mint]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            VStack(spacing: 20) {
                Text("Research-Based Features")
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(textColor)
                
                VStack(spacing: 16) {
                    ElegantFeatureRow(icon: "🔗", title: "Habit Stacking", description: "Link new habits to existing ones (Atomic Habits)")
                    ElegantFeatureRow(icon: "👁️", title: "Environment Design", description: "Make good habits obvious and bad habits invisible")
                    ElegantFeatureRow(icon: "🎉", title: "Celebration", description: "Immediate rewards for habit completion (Tiny Habits)")
                    ElegantFeatureRow(icon: "⚡", title: "Keystone Habits", description: "Habits that trigger other positive changes")
                    ElegantFeatureRow(icon: "🆔", title: "Identity-Based", description: "Focus on who you want to become")
                }
            }
            
            ElegantGuideCard(
                title: "Creating Your First Habit",
                content: "1. Choose a category (Health, Productivity, etc.)\n2. Start with an easy habit (1-2 minutes)\n3. Add a specific cue and reward\n4. Use habit stacking: 'After I [existing habit], I will [new habit]'\n5. Celebrate immediately after completion",
                icon: "✨",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            ElegantGuideCard(
                title: "Pro Tips",
                content: "• Start tiny - 30-second habits work better\n• Focus on consistency over quantity\n• Use morning routines as keystone habits\n• Design your environment for success\n• Celebrate every completion, no matter how small",
                icon: "💡",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.yellow]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // MARK: - Elegant Goals Section
    private var elegantGoalsSection: some View {
        VStack(spacing: 32) {
            ElegantGuideCard(
                title: "Goal Setting Strategy",
                content: "MONU helps you set and achieve goals at different time horizons: daily tasks, yearly goals, bucket list items, and future vision. Each serves a different purpose in your planning system.",
                icon: "🎯",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.orange]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            VStack(spacing: 20) {
                Text("Goal Types")
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(textColor)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ElegantFeatureCard(icon: "📅", title: "Daily Tasks", description: "Immediate actions for today")
                    ElegantFeatureCard(icon: "📊", title: "Yearly Goals", description: "Annual objectives and milestones")
                    ElegantFeatureCard(icon: "🌟", title: "Bucket List", description: "Life dreams and experiences")
                    ElegantFeatureCard(icon: "🔮", title: "Future Vision", description: "Long-term identity and aspirations")
                }
            }
            
            ElegantGuideCard(
                title: "Goal Setting Best Practices",
                content: "• Set 3-5 yearly goals maximum\n• Make goals specific and measurable\n• Include different categories (health, career, relationships)\n• Review and adjust goals regularly\n• Focus on systems over goals",
                icon: "📋",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // MARK: - Elegant AI Insights Section
    private var elegantAIInsightsSection: some View {
        VStack(spacing: 32) {
            ElegantGuideCard(
                title: "AI-Powered Insights",
                content: "MONU's AI analyzes your data to provide personalized insights and recommendations based on proven research from habit and productivity books.",
                icon: "🤖",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            VStack(spacing: 20) {
                Text("What AI Analyzes")
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(textColor)
                
                VStack(spacing: 16) {
                    ElegantFeatureRow(icon: "📊", title: "Habit Patterns", description: "Your completion rates and streaks")
                    ElegantFeatureRow(icon: "🎯", title: "Goal Progress", description: "Achievement rates and trends")
                    ElegantFeatureRow(icon: "📈", title: "Productivity Trends", description: "When you're most effective")
                    ElegantFeatureRow(icon: "🧠", title: "Behavior Analysis", description: "Patterns in your planning")
                }
            }
            
            ElegantGuideCard(
                title: "Research-Based Tips",
                content: "• Insights are based on 'Atomic Habits', 'The Power of Habit', and 'Tiny Habits'\n• Recommendations focus on proven strategies\n• Tips are personalized to your data\n• Suggestions adapt as you progress",
                icon: "📚",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.mint]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // MARK: - Elegant Tips Section
    private var elegantTipsSection: some View {
        VStack(spacing: 32) {
            ElegantGuideCard(
                title: "Pro Tips for Success",
                content: "These tips are based on research and real user experiences. They'll help you get the most out of MONU and build lasting positive changes.",
                icon: "💡",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.yellow]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            VStack(spacing: 20) {
                Text("Essential Tips")
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(textColor)
                
                VStack(spacing: 16) {
                    ElegantTipRow(number: "1", title: "Start Small", description: "Begin with 30-second habits and build up gradually")
                    ElegantTipRow(number: "2", title: "Be Consistent", description: "Focus on daily consistency rather than perfection")
                    ElegantTipRow(number: "3", title: "Celebrate Wins", description: "Acknowledge every small victory to build momentum")
                    ElegantTipRow(number: "4", title: "Review Regularly", description: "Check your progress weekly and adjust as needed")
                    ElegantTipRow(number: "5", title: "Trust the Process", description: "Lasting change takes time - be patient with yourself")
                }
            }
            
            ElegantGuideCard(
                title: "Getting Started",
                content: "1. Set up your first habit (start tiny!)\n2. Add 3-5 yearly goals\n3. Create your first daily task\n4. Check your dashboard daily\n5. Read AI insights weekly",
                icon: "🚀",
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // MARK: - Computed Properties
    private var textColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }
}

// MARK: - Supporting Views
struct ElegantSectionButton: View {
    let section: UserGuideView.GuideSection
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(section.icon)
                    .font(.system(size: 24))
                
                Text(section.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : textColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color(red: 0.95, green: 0.62, blue: 0.56) : (colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : Color.white))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18)
    }
}

struct ElegantGuideCard: View {
    let title: String
    let content: String
    let icon: String
    let gradient: LinearGradient
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 50, height: 50)
                        .shadow(color: Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text(icon)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Georgia", size: 20))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                }
                
                Spacer()
            }
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
                .lineSpacing(6)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.16) : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
}

struct ElegantFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.2), Color(red: 0.98, green: 0.75, blue: 0.65).opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Text(icon)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.16) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

struct ElegantFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.2), Color(red: 0.98, green: 0.75, blue: 0.65).opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Text(icon)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Quick Start Guide
struct ElegantQuickStartGuide: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(red: 0.06, green: 0.06, blue: 0.08) : Color(red: 0.98, green: 0.97, blue: 0.95),
                        colorScheme == .dark ? Color(red: 0.10, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.94, blue: 0.92)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Welcome
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3), radius: 12, x: 0, y: 6)
                                
                                Text("🚀")
                                    .font(.system(size: 40))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Quick Start Guide")
                                    .font(.custom("Georgia", size: 28))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                                
                                Text("Get started with MONU in 5 minutes")
                                    .font(.custom("Georgia", size: 16))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Steps
                        VStack(spacing: 24) {
                            ElegantQuickStartStep(
                                number: "1",
                                title: "Add Your First Habit",
                                description: "Go to Habits → Tap + → Choose 'Health' → Add 'Drink water' → Set to 'Easy' → Add cue: 'After I wake up' → Add reward: 'Say I'm awesome!'",
                                icon: "🌱"
                            )
                            
                            ElegantQuickStartStep(
                                number: "2",
                                title: "Set a Daily Task",
                                description: "Go to Daily Plan → Tap + → Add 'Make my bed' → Set time to '7:00 AM' → Save",
                                icon: "📝"
                            )
                            
                            ElegantQuickStartStep(
                                number: "3",
                                title: "Create a Yearly Goal",
                                description: "Go to Yearly Overview → Tap + → Add 'Read 12 books' → Choose 'Learning' category → Save",
                                icon: "🎯"
                            )
                            
                            ElegantQuickStartStep(
                                number: "4",
                                title: "Check Your Dashboard",
                                description: "Go to Dashboard → See your progress → Read AI Insights → Take action on suggestions",
                                icon: "📊"
                            )
                            
                            ElegantQuickStartStep(
                                number: "5",
                                title: "Build Momentum",
                                description: "Complete your first habit → Celebrate your win → Add another tiny habit → Repeat daily",
                                icon: "🚀"
                            )
                        }
                        
                        // Tips
                        VStack(spacing: 20) {
                            Text("💡 Quick Tips")
                                .font(.custom("Georgia", size: 22))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                            
                            VStack(spacing: 16) {
                                ElegantTipRow(number: "1", title: "Start Tiny", description: "Begin with 30-second habits")
                                ElegantTipRow(number: "2", title: "Celebrate", description: "Acknowledge every completion")
                                ElegantTipRow(number: "3", title: "Check Insights", description: "Read AI insights daily")
                                ElegantTipRow(number: "4", title: "Be Consistent", description: "Focus on daily consistency")
                                ElegantTipRow(number: "5", title: "Stack Habits", description: "Link new habits to existing ones")
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.16) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
                        )
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Quick Start")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.95, green: 0.62, blue: 0.56))
                }
            }
        }
    }
}

struct ElegantQuickStartStep: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text(number)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Text(icon)
                        .font(.system(size: 20))
                    
                    Text(title)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                }
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.16) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

struct ElegantTipRow: View {
    let number: String
    let title: String
    let description: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.56), Color(red: 0.98, green: 0.75, blue: 0.65)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: Color(red: 0.95, green: 0.62, blue: 0.56).opacity(0.3), radius: 4, x: 0, y: 2)
                
                Text(number)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
} 
