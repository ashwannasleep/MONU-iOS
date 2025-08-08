import SwiftUI

struct ChoosePageView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager  // Use nested NavigationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var name = "you"

    // Use the nested NavigationDestination type
    typealias Destination = NavigationContainer.NavigationTypes.NavigationDestination
    
    var modules: [ModuleItem] {
        [
            ModuleItem(title: "Dashboard", description: "See an overview of all your progress.", destination: Destination.dashboard),
            ModuleItem(title: "Yearly Overview", description: "Set your vision for the year.", destination: Destination.yearlyOverview),
            ModuleItem(title: "Monthly Planner", description: "Break down your year into focused months.", destination: Destination.monthlyPlanner),
            ModuleItem(title: "Daily Plan", description: "Organize your to‑dos and priorities.", destination: Destination.dailyPlan),
            ModuleItem(title: "Habits", description: "Build your habits with structure.", destination: Destination.habitTracker),
            ModuleItem(title: "Future Vision", description: "Dream and map your long‑term goals.", destination: Destination.futureVision),
            ModuleItem(title: "Bucket List", description: "List your big life goals & fun ideas.", destination: Destination.bucketList),
            ModuleItem(title: "Pomodoro", description: "Work with rhythm. Breathe between tasks.", destination: Destination.pomodoro),
            ModuleItem(title: "User Guide", description: "Your guide to mindful planning with MONU.", destination: Destination.userGuide)
        ]
    }
    
    // MARK: - Computed properties for theming
    private var backgroundColor: Color {
        themeManager.backgroundColor
    }
    
    private var textColor: Color {
        themeManager.textColor
    }
    
    private var secondaryTextColor: Color {
        themeManager.secondaryTextColor
    }
    
    private var cardBackgroundColor: Color {
        themeManager.cardBackgroundColor
    }
    
    private var cardBorderColor: Color {
        themeManager.colorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.94, green: 0.92, blue: 0.9)
    }

    var body: some View {
        GeometryReader { geometry in
            backgroundColor
                .ignoresSafeArea()
                .overlay(
                    VStack(spacing: 0) {
                        // MONU Header
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

                        Text("Choose a section to begin with.")
                            .font(.custom("Georgia", size: 16))
                            .italic()
                            .foregroundColor(secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .padding(.bottom, 32)

                        // Scrollable modules grid
                        ScrollView {
                            LazyVGrid(columns: gridColumns(for: geometry.size.width), spacing: 24) {
                                ForEach(modules, id: \.self) { module in
                                    ModuleCard(
                                        module: module,
                                        cardBackgroundColor: cardBackgroundColor,
                                        cardBorderColor: cardBorderColor,
                                        textColor: textColor,
                                        secondaryTextColor: secondaryTextColor
                                    ) {
                                        // Navigate using the correct type
                                        navigationManager.navigate(to: module.destination)
                                    }
                                }
                            }
                            .padding(.horizontal, 32)
                            .padding(.bottom, 40)
                        }
                    }
                )
        }
        .onAppear { loadUserName() }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigationManager.navigate(to: Destination.settings)
                } label: {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                        .foregroundColor(textColor)
                }
            }
        }
        #endif
        .navigationBarBackButtonHidden(true)
    }

    private func gridColumns(for width: CGFloat) -> [GridItem] {
        let isWide = width > 768
        return Array(repeating: GridItem(.flexible(), spacing: 24), count: isWide ? 2 : 1)
    }

    private func loadUserName() {
        name = UserDefaults.standard.string(forKey: "monu_name") ?? "you"
    }
}

// MARK: - Module Item Model (Using nested type)
struct ModuleItem: Hashable {
    let title: String
    let description: String
    let destination: NavigationContainer.NavigationTypes.NavigationDestination
}

// MARK: - Module Card Component
struct ModuleCard: View {
    let module: ModuleItem
    let cardBackgroundColor: Color
    let cardBorderColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(module.title)
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)

                Text(module.description)
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
            .background(
                isHovered
                    ? (colorScheme == .dark
                        ? Color(red: 0.18, green: 0.18, blue: 0.18)
                        : Color(red: 0.99, green: 0.98, blue: 0.97))
                    : cardBackgroundColor
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(cardBorderColor, lineWidth: 1.5)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.3 : (isHovered ? 0.12 : 0.08)),
                radius: isHovered ? 12 : 8,
                x: 0,
                y: isHovered ? 6 : 4
            )
            .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in isHovered = hovering }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in isPressed = pressing }, perform: {})
    }
}
