import SwiftUI
import Amplify

struct PomodoroView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @AppStorage("pomodoroHistory") private var historyData: Data = Data()
    @EnvironmentObject var themeManager: ThemeManager
    
    // Timer states
    @State private var modes: [StudyMode: Int] = [
        .study: 30,
        .reading: 45,
        .work: 50
    ]
    @State private var currentMode: StudyMode = .study
    @State private var customTime: Int = 30
    @State private var secondsLeft: Int = 1800 // 30 * 60
    @State private var isRunning = false
    @State private var phase: TimerPhase = .focus
    @State private var showBreakChoice = false
    @State private var showTimerComplete = false
    @State private var isCountingUp = false // 正计时
    @State private var secondsElapsed: Int = 0
    @State private var showHistory = false
    
    // Timer reference
    @State private var timer: Timer?
    
    // History
    @State private var sessions: [PomodoroSession] = []
    
    // Computed properties for theming
    private var backgroundColor: Color {
        themeManager.backgroundColor
    }
    
    private var textColor: Color {
        themeManager.textColor
    }
    
    private var displayTime: String {
        let totalSeconds = isCountingUp ? secondsElapsed : secondsLeft
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var progress: Double {
        guard phase == .focus else { return 0 }
        let total = Double(customTime * 60)
        let current = Double(secondsLeft)
        return total > 0 ? (total - current) / total : 0
    }
    
    var body: some View {
        ZStack {
            // Background using theme colors
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Luxurious header
                luxuriousHeaderView
                
                // Main content
                ScrollView {
                    VStack(spacing: 40) {
                        // Mode selection with luxury design
                        luxuriousModeSelectionView
                            .padding(.top, 40)
                        
                        // Custom time input with premium styling
                        luxuriousCustomTimeInputView
                        
                        // Luxurious timer display
                        luxuriousTimerDisplayView
                            .padding(.vertical, 30)
                        
                        // Premium control buttons
                        if !showBreakChoice {
                            luxuriousControlButtonsView
                        } else {
                            luxuriousBreakChoiceView
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 24)
                }
            }
            
            // Timer complete animation
            if showTimerComplete {
                LuxuriousTimerCompleteView {
                    showTimerComplete = false
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            loadHistory()
            restoreTimerState()
        }
        .onDisappear {
            pauseTimer()
            saveTimerState()
        }
        .sheet(isPresented: $showHistory) {
            LuxuriousHistoryView(sessions: sessions, onClose: { showHistory = false })
        }
    }
    
    // MARK: - Luxurious Header View
    private var luxuriousHeaderView: some View {
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
            
            Text("Master your focus with precision timing 🍅")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }
    
    // MARK: - Luxurious Mode Selection View
    private var luxuriousModeSelectionView: some View {
        VStack(spacing: 20) {
            Text("Choose Your Focus Mode")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(textColor)
            
            HStack(spacing: 16) {
                ForEach(StudyMode.allCases, id: \.self) { mode in
                    LuxuriousModeButton(
                        mode: mode,
                        isActive: currentMode == mode,
                        action: { selectMode(mode) }
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.colorScheme == .dark ? themeManager.cardBackgroundColor : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
    
    // MARK: - Luxurious Custom Time Input View
    private var luxuriousCustomTimeInputView: some View {
        VStack(spacing: 16) {
            Text("Customize Your Session")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(textColor)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration (minutes)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("", value: $customTime, format: .number)
                            .font(.custom("Georgia", size: 24))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.colorScheme == .dark ? themeManager.cardBackgroundColor : themeManager.cardBackgroundColor)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                            .onChange(of: customTime) { _, newValue in
                                updateCustomTime(newValue)
                            }
                        
                        Text("min")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Current Mode")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(currentMode.displayName)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(.white)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.colorScheme == .dark ? themeManager.cardBackgroundColor : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
    
    // MARK: - Luxurious Timer Display View
    private var luxuriousTimerDisplayView: some View {
        VStack(spacing: 24) {
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                                themeManager.accentColor.opacity(0.3),
                themeManager.accentColor.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 12
                    )
                    .frame(width: 280, height: 280)
                
                // Progress ring
                Circle()
                    .stroke(
                        themeManager.colorScheme == .dark ? themeManager.cardBackgroundColor : themeManager.cardBackgroundColor,
                        lineWidth: 8
                    )
                    .frame(width: 260, height: 260)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                                themeManager.accentColor,
                themeManager.accentColor
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: progress)
                
                // Timer content
                VStack(spacing: 12) {
                    Text(displayTime)
                        .font(.custom("Georgia", size: 52))
                        .foregroundColor(textColor)
                        .monospacedDigit()
                    
                    Text(phase.displayName)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(.secondary)
                    
                    if isCountingUp {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.accentColor)
                            Text("Counting Up")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.accentColor)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(themeManager.accentColor.opacity(0.1))
                        )
                    }
                }
            }
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeManager.cardBackgroundColor,
                                themeManager.backgroundColor
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
            )
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.colorScheme == .dark ? themeManager.cardBackgroundColor : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
    
    // MARK: - Luxurious Control Buttons View
    private var luxuriousControlButtonsView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 20) {
                if !isRunning {
                    LuxuriousTimerButton(
                        title: "Start",
                        icon: "play.fill",
                        style: .primary,
                        action: { startTimer() }
                    )
                } else {
                    LuxuriousTimerButton(
                        title: "Pause",
                        icon: "pause.fill",
                        style: .secondary,
                        action: { pauseTimer() }
                    )
                }
                
                LuxuriousTimerButton(
                    title: "Reset",
                    icon: "arrow.clockwise",
                    style: .outline,
                    action: { resetTimer() }
                )
            }
            
            // Timer mode toggle
            Button(action: { isCountingUp.toggle() }) {
                HStack(spacing: 8) {
                    Image(systemName: isCountingUp ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text(isCountingUp ? "Count Up" : "Count Down")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(themeManager.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(themeManager.accentColor.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // History button
            Button(action: { showHistory = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16, weight: .medium))
                    Text("View History")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.cardBackgroundColor)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
    
    // MARK: - Luxurious Break Choice View
    private var luxuriousBreakChoiceView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Break Time!")
                    .font(.custom("Georgia", size: 28))
                    .foregroundColor(textColor)
                
                Text("Choose your well-deserved break")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                LuxuriousBreakButton(
                    title: "Short Break",
                    subtitle: "5 minutes",
                    icon: "☕",
                    action: { handleBreakChoice(.shortBreak) }
                )
                
                LuxuriousBreakButton(
                    title: "Long Break",
                    subtitle: "15 minutes",
                    icon: "🌿",
                    action: { handleBreakChoice(.longBreak) }
                )
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
    
    // MARK: - Timer Functions
    private func startTimer() {
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if isCountingUp {
                secondsElapsed += 1
            } else {
                if secondsLeft > 0 {
                    secondsLeft -= 1
                } else {
                    timerComplete()
                }
            }
            saveTimerState()
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        saveTimerState()
    }
    
    private func resetTimer() {
        pauseTimer()
        secondsLeft = phase == .focus ? customTime * 60 :
                     phase == .shortBreak ? 5 * 60 : 15 * 60
        secondsElapsed = 0
        removeTimerState()
    }
    
    private func timerComplete() {
        pauseTimer()
        showTimerComplete = true
        
        // Save to history
        let session = PomodoroSession(
            mode: currentMode,
            duration: phase == .focus ? customTime * 60 :
                      phase == .shortBreak ? 5 * 60 : 15 * 60,
            phase: phase,
            completedAt: Date()
        )
        sessions.append(session)
        saveHistory()
        
        // Haptic feedback
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        #endif
        
        if phase == .focus {
            showBreakChoice = true
        } else {
            phase = .focus
            resetTimer()
        }
    }
    
    private func selectMode(_ mode: StudyMode) {
        currentMode = mode
        customTime = modes[mode] ?? 30
        phase = .focus
        resetTimer()
    }
    
    private func updateCustomTime(_ value: Int) {
        guard value > 0 else { return }
        modes[currentMode] = value
        if !isRunning {
            secondsLeft = value * 60
        }
    }
    
    private func handleBreakChoice(_ breakType: TimerPhase) {
        phase = breakType
        secondsLeft = breakType == .shortBreak ? 5 * 60 : 15 * 60
        showBreakChoice = false
        startTimer()
    }
    
    // MARK: - State Persistence
    private func saveTimerState() {
        let state = TimerState(
            secondsLeft: secondsLeft,
            secondsElapsed: secondsElapsed,
            isRunning: isRunning,
            phase: phase,
            mode: currentMode,
            isCountingUp: isCountingUp,
            timestamp: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: "pomodoroState")
        }
    }
    
    private func restoreTimerState() {
        guard let data = UserDefaults.standard.data(forKey: "pomodoroState"),
              let state = try? JSONDecoder().decode(TimerState.self, from: data) else { return }
        
        let elapsed = Int(Date().timeIntervalSince(state.timestamp))
        
        if state.isRunning {
            if state.isCountingUp {
                secondsElapsed = state.secondsElapsed + elapsed
            } else {
                let remaining = state.secondsLeft - elapsed
                if remaining > 0 {
                    secondsLeft = remaining
                    currentMode = state.mode
                    phase = state.phase
                    isCountingUp = state.isCountingUp
                    startTimer()
                }
            }
        } else {
            secondsLeft = state.secondsLeft
            secondsElapsed = state.secondsElapsed
            currentMode = state.mode
            phase = state.phase
            isCountingUp = state.isCountingUp
        }
    }
    
    private func removeTimerState() {
        UserDefaults.standard.removeObject(forKey: "pomodoroState")
    }
    
    // MARK: - History Functions
    private func loadHistory() {
        if let decoded = try? JSONDecoder().decode([PomodoroSession].self, from: historyData) {
            sessions = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            historyData = encoded
        }
    }
}

// MARK: - Supporting Types
enum StudyMode: String, CaseIterable, Codable {
    case study, reading, work
    
    var displayName: String {
        switch self {
        case .study: return "Study"
        case .reading: return "Reading"
        case .work: return "Work"
        }
    }
}

enum TimerPhase: String, Codable {
    case focus, shortBreak, longBreak
    
    var displayName: String {
        switch self {
        case .focus: return "Focus Time"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
}

struct TimerState: Codable {
    let secondsLeft: Int
    let secondsElapsed: Int
    let isRunning: Bool
    let phase: TimerPhase
    let mode: StudyMode
    let isCountingUp: Bool
    let timestamp: Date
}

struct PomodoroSession: Codable, Identifiable {
    var id = UUID()
    let mode: StudyMode
    let duration: Int
    let phase: TimerPhase
    let completedAt: Date
}

// MARK: - Component Views
struct LuxuriousModeButton: View {
    let mode: StudyMode
    let isActive: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private var textColor: Color {
        themeManager.textColor
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mode.displayName)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(isActive ? .white : textColor.opacity(0.7))
                
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isActive ? 
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : 
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.cardBackgroundColor.opacity(0.5), themeManager.cardBackgroundColor.opacity(0.5)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct LuxuriousTimerButton: View {
    enum Style {
        case primary, secondary, outline
    }
    
    let title: String
    let icon: String
    let style: Style
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(foregroundColor)
                
                Text(title)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(foregroundColor)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .outline ? 1.5 : 0)
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return themeManager.accentColor
        case .secondary: return Color.gray
        case .outline: return themeManager.cardBackgroundColor
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary: return .white
        case .outline: return themeManager.accentColor
        }
    }
    
    private var borderColor: Color {
        style == .outline ? themeManager.accentColor : Color.clear
    }
}

struct LuxuriousBreakButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private var textColor: Color {
        themeManager.textColor
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Text(icon)
                        .font(.system(size: 24))
                    Text(title)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(textColor)
                }
                Text(subtitle)
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.cardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LuxuriousTimerCompleteView: View {
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Luxurious backdrop
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onTapGesture {
                dismiss()
            }
            
            VStack(spacing: 32) {
                // Animated success icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotation))
                }
                
                VStack(spacing: 16) {
                    Text("Session Complete!")
                        .font(.custom("Georgia", size: 32))
                        .foregroundColor(.white)
                    
                    Text("Excellent focus! Time to recharge and celebrate your progress.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Button(action: dismiss) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .medium))
                        Text("Continue")
                            .font(.custom("Georgia", size: 16))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeManager.colorScheme == .dark ? themeManager.cardBackgroundColor : Color.white,
                                themeManager.colorScheme == .dark ? themeManager.cardBackgroundColor : themeManager.cardBackgroundColor
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 15)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                rotation = 360
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.4)) {
            scale = 0.5
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onDismiss()
        }
    }
}

struct LuxuriousHistoryView: View {
    let sessions: [PomodoroSession]
    let onClose: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                            // Luxurious gradient background - using theme colors
            LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.backgroundColor,
                    themeManager.cardBackgroundColor
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Luxurious header
                    VStack(spacing: 16) {
                        HStack {
                            Text("Session History")
                                .font(.custom("Georgia", size: 28))
                                .foregroundColor(themeManager.textColor)
                            
                            Spacer()
                            
                            Button("Done") { onClose() }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.accentColor)
                        }
                        
                        Text("Your focus journey")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Sessions list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(sessions.reversed()) { session in
                                LuxuriousSessionCard(session: session, dateFormatter: dateFormatter)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
            }
        }
    

struct LuxuriousSessionCard: View {
    let session: PomodoroSession
    let dateFormatter: DateFormatter
    @EnvironmentObject var themeManager: ThemeManager
    
    private var textColor: Color {
        themeManager.textColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.mode.displayName)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(textColor)
                    
                    Text(session.phase.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(session.duration / 60) min")
                        .font(.custom("Georgia", size: 20))
                        .foregroundColor(themeManager.accentColor)
                    
                    Text(dateFormatter.string(from: session.completedAt))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}
