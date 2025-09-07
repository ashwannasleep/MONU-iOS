import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStep = 0
    @State private var showMainApp = false
    
    let welcomeSteps = [
        WelcomeStep(
            title: "Welcome to MONU",
            subtitle: "Your mindful planning companion",
            description: "Start your journey towards intentional living with guided planning, habit tracking, and mindful goal setting.",
            icon: "leaf.fill",
            color: .mint
        ),
        WelcomeStep(
            title: "Build Lasting Habits",
            subtitle: "Science-backed approach",
            description: "Create habits that stick using proven strategies from 'Atomic Habits' and 'The Power of Habit'.",
            icon: "repeat.circle.fill",
            color: .pastelBlue
        ),
        WelcomeStep(
            title: "Track Your Progress",
            subtitle: "Visualize your growth",
            description: "See your progress with beautiful charts and insights that motivate you to keep going.",
            icon: "chart.line.uptrend.xyaxis",
            color: .pastelPurple
        ),
        WelcomeStep(
            title: "Plan with Intention",
            subtitle: "Mindful goal setting",
            description: "Set meaningful goals across daily tasks, yearly objectives, and your bucket list dreams.",
            icon: "target",
            color: .pastelOrange
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Main content
                    VStack(spacing: 40) {
                        // Icon
                        iconView
                        
                        // Text content
                        VStack(spacing: 16) {
                            Text(welcomeSteps[currentStep].title)
                                .font(.custom("Georgia", size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.textColor)
                                .multilineTextAlignment(.center)
                            
                            Text(welcomeSteps[currentStep].subtitle)
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.accentColor)
                                .multilineTextAlignment(.center)
                            
                            Text(welcomeSteps[currentStep].description)
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(themeManager.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 40)
                        }
                        
                        Spacer()
                        
                        // Navigation buttons
                        navigationButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                themeManager.backgroundColor,
                themeManager.backgroundColor.opacity(0.8),
                themeManager.accentColor.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<welcomeSteps.count, id: \.self) { index in
                Circle()
                    .fill(index == currentStep ? themeManager.accentColor : themeManager.secondaryTextColor.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    // MARK: - Icon View
    private var iconView: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(welcomeSteps[currentStep].color.color.opacity(0.1))
                .frame(width: 120, height: 120)
            
            // Icon
            Image(systemName: welcomeSteps[currentStep].icon)
                .font(.system(size: 50, weight: .medium))
                .foregroundColor(welcomeSteps[currentStep].color.color)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            if currentStep > 0 {
                Button("Back") {
                    currentStep -= 1
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            Button(currentStep == welcomeSteps.count - 1 ? "Get Started" : "Next") {
                if currentStep == welcomeSteps.count - 1 {
                    // Navigate to main app
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                    NotificationCenter.default.post(name: .welcomeCompleted, object: nil)
                } else {
                    currentStep += 1
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 20)
    }
    
}

// MARK: - Welcome Step Model
struct WelcomeStep {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: ThemeColor
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Georgia", size: 16))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(themeManager.accentColor)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Georgia", size: 16))
            .fontWeight(.medium)
            .foregroundColor(themeManager.textColor)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(themeManager.cardBackgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.accentColor, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
} 
