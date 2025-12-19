import SwiftUI
import Amplify
import UserNotifications

enum ActivityType: String, CaseIterable, Codable {
    case read = "Read"
    case study = "Study"
    case work = "Work"
}

struct PomodoroView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.scenePhase) private var scenePhase

    // Persisted bits so the timer survives app relaunch
    @AppStorage("pomodoroHistory") private var historyData: Data = Data()
    @AppStorage("pomodoroIsRunning") private var storedIsRunning: Bool = false
    @AppStorage("pomodoroEndDate") private var storedEndDate: Double = 0 // timeIntervalSince1970
    @AppStorage("pomodoroCustomMinutes") private var storedCustomMinutes: Int = 25
    @AppStorage("pomodoroSelectedActivity") private var storedActivityRaw: String = ActivityType.work.rawValue

    // Core timer states
    @State private var secondsLeft: Int = 1500 // 25 minutes default
    @State private var isRunning = false
    @State private var customMinutes: Int = 25
    @State private var timer: Timer?
    @State private var sessions: [PomodoroSession] = []
    @State private var showHistory = false
    @State private var showComplete = false
    @State private var selectedActivity: ActivityType = .work
    @State private var endDate: Date? = nil  // target finish time

    // Derived
    private var displayTime: String {
        let minutes = max(0, secondsLeft) / 60
        let seconds = max(0, secondsLeft) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    private var progress: Double {
        let total = Double(max(1, customMinutes) * 60)
        let current = Double(max(0, secondsLeft))
        return min(1, max(0, (total - current) / total))
    }

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let responsivePadding = LayoutHelper.responsivePadding(for: screenWidth)
            
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    headerView

                    // Activity selector
                    activitySelectorView

                    Spacer()

                    // Timer display
                    timerDisplayView(screenWidth: screenWidth)

                    Spacer()

                    // Time input
                    timeInputView
                        .padding(.top, 20)

                    // Controls
                    controlButtonsView
                        .padding(.top, 20)

                    Spacer()

                    // Stats
                    statsView
                }
                .padding(.horizontal, responsivePadding)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            bootstrapState()
            loadHistory()
            requestNotificationPermissionIfNeeded()
        }
        .onDisappear {
            // leave timer as-is; no invalidation needed (it should keep running)
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
        .sheet(isPresented: $showHistory) {
            historyView
        }
        .overlay {
            if showComplete { completeOverlay }
        }
    }

    // MARK: - Header
    private var headerView: some View {
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
                    .foregroundColor(themeManager.colorScheme == .dark ? .white : .black)
            }
            .buttonStyle(.plain)
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

    // MARK: - Activity selector
    private var activitySelectorView: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let spacing: CGFloat = screenWidth > LayoutHelper.iPadBreakpoint ? 16 : 12
            let fontSize: CGFloat = screenWidth > LayoutHelper.iPadBreakpoint ? 16 : 14
            
            HStack(spacing: spacing) {
                ForEach(ActivityType.allCases, id: \.self) { activity in
                    Button(action: {
                        selectedActivity = activity
                        storedActivityRaw = activity.rawValue
                    }) {
                        Text(activity.rawValue)
                            .font(.custom("Georgia", size: fontSize))
                            .fontWeight(.medium)
                            .foregroundColor(selectedActivity == activity ? .white : themeManager.textColor)
                            .padding(.horizontal, screenWidth > LayoutHelper.iPadBreakpoint ? 20 : 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedActivity == activity ? themeManager.accentColor : themeManager.cardBackgroundColor)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .frame(height: 50)
    }

    // MARK: - Timer display
    private func timerDisplayView(screenWidth: CGFloat) -> some View {
        let circleSize: CGFloat = min(220, screenWidth * 0.6)
        let fontSize: CGFloat = circleSize * 0.22
        let lineWidth: CGFloat = max(6, circleSize * 0.035)
        
        return ZStack {
            // Progress ring background
            Circle()
                .stroke(themeManager.cardBackgroundColor, lineWidth: lineWidth)
                .frame(width: circleSize, height: circleSize)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(themeManager.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)

            // Time text
            Text(displayTime)
                .font(.custom("Georgia", size: fontSize))
                .foregroundColor(themeManager.textColor)
                .monospacedDigit()
        }
        .padding(20)
        .background(
            Circle()
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
    }

    // MARK: - Time input
    private var timeInputView: some View {
        HStack(spacing: 16) {
            Text("Duration:")
                .font(.custom("Georgia", size: 16))
                .foregroundColor(.secondary)

            TextField("Minutes", value: $customMinutes, format: .number)
                .font(.custom("Georgia", size: 20))
                .multilineTextAlignment(.center)
                .frame(width: 60)
                .padding(8)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(8)
                .onChange(of: customMinutes) { _, newValue in
                    let clamped = max(1, min(180, newValue)) // clamp 1..180 minutes
                    if clamped != newValue { customMinutes = clamped }
                    storedCustomMinutes = clamped

                    if isRunning {
                        // Adjust endDate to reflect new total duration while preserving elapsed time
                        let elapsed = Double(max(0, max(1, clamped) * 60 - secondsLeft))
                        endDate = Date().addingTimeInterval(Double(clamped * 60) - elapsed)
                        storedEndDate = endDate?.timeIntervalSince1970 ?? 0
                    } else {
                        secondsLeft = clamped * 60
                    }
                }

            Text("minutes")
                .font(.custom("Georgia", size: 16))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: .black.opacity(0.05), radius: 8)
        )
    }

    // MARK: - Controls
    private var controlButtonsView: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let isWide = screenWidth > LayoutHelper.iPadBreakpoint
            let buttonWidth: CGFloat = isWide ? 140 : 120
            let fontSize: CGFloat = isWide ? 20 : 18
            
            HStack(spacing: isWide ? 24 : 20) {
                Button(isRunning ? "Pause" : "Start") {
                    isRunning ? pauseTimer() : startTimer()
                }
                .font(.custom("Georgia", size: fontSize))
                .foregroundColor(.white)
                .frame(width: buttonWidth, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isRunning ? Color.orange : themeManager.accentColor)
                )

                Button("Reset") { resetTimer() }
                    .font(.custom("Georgia", size: fontSize - 2))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: buttonWidth - 20, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.accentColor, lineWidth: 1.5)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 60)
    }

    // MARK: - Stats
    private var statsView: some View {
        HStack(spacing: 32) {
            VStack(spacing: 4) {
                Text("\(todaySessions)")
                    .font(.custom("Georgia", size: 24))
                    .foregroundColor(themeManager.textColor)
                Text("Today")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Button("History") { showHistory = true }
                .font(.system(size: 14))
                .foregroundColor(themeManager.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.accentColor.opacity(0.1))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: .black.opacity(0.05), radius: 8)
        )
    }

    // MARK: - Complete overlay
    private var completeOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 60))
                Text("Session Complete!")
                    .font(.custom("Georgia", size: 24))
                    .foregroundColor(.white)
                Button("Continue") { showComplete = false }
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.accentColor)
                    )
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.cardBackgroundColor)
            )
        }
        .onTapGesture { showComplete = false }
    }

    // MARK: - History
    private var historyView: some View {
        NavigationView {
            List {
                ForEach(sessions.reversed()) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(session.duration / 60) minutes")
                                .font(.custom("Georgia", size: 16))
                            // very minor line (can remove if you want zero visual change)
                            Text("• \(session.activity.rawValue)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(session.completedAt, style: .relative)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { showHistory = false }
                }
            }
        }
    }

    private var todaySessions: Int {
        sessions.filter { Calendar.current.isDateInToday($0.completedAt) }.count
    }

    // MARK: - Timer engine (accurate, background-safe)
    private func startTimer() {
        guard !isRunning else { return } // prevent duplicates
        isRunning = true
        storedIsRunning = true

        // If we already have an endDate (paused), keep it; else set from now + remaining
        if endDate == nil {
            endDate = Date().addingTimeInterval(TimeInterval(secondsLeft))
            storedEndDate = endDate!.timeIntervalSince1970
        }

        // Ensure ticker exists
        startTicker()
        scheduleCompletionNotification()
    }

    private func startTicker() {
        timer?.invalidate()
        // Use scheduled timer; accuracy comes from recomputing vs endDate
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            updateRemaining()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func updateRemaining() {
        guard let end = endDate else { return }
        let remaining = Int(ceil(end.timeIntervalSinceNow))
        secondsLeft = max(0, remaining)
        if remaining <= 0 {
            timerComplete()
        }
    }

    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        storedIsRunning = false
        // keep endDate as-is so resume uses remaining
        cancelCompletionNotification()
        // snapshot current remaining for persistence
        updateRemaining()
    }

    private func resetTimer() {
        pauseTimer()
        endDate = nil
        storedEndDate = 0
        secondsLeft = max(1, customMinutes) * 60
    }

    private func timerComplete() {
        pauseTimer()
        endDate = nil
        storedEndDate = 0
        secondsLeft = 0
        cancelCompletionNotification()

        let session = PomodoroSession(
            duration: max(1, customMinutes) * 60,
            completedAt: Date(),
            activity: selectedActivity
        )
        sessions.append(session)
        saveHistory()
        showComplete = true

        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        #endif
    }

    // MARK: - Lifecycle / persistence
    private func bootstrapState() {
        // Restore persisted selections
        customMinutes = max(1, storedCustomMinutes)
        selectedActivity = ActivityType(rawValue: storedActivityRaw) ?? .work

        // If a timer was running, reconstruct it from stored end date
        if storedIsRunning && storedEndDate > 0 {
            endDate = Date(timeIntervalSince1970: storedEndDate)
            updateRemaining()
            if secondsLeft == 0 {
                // Edge: finished while we were away
                timerComplete()
            } else {
                isRunning = true
                startTicker()
                scheduleCompletionNotification()
            }
        } else {
            // Not running; reset remaining to current duration
            secondsLeft = max(1, customMinutes) * 60
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // Re-sync remaining from endDate (avoids drift)
            if isRunning { updateRemaining() }
        case .background:
            // persist running/endDate for relaunch
            storedIsRunning = isRunning
            storedEndDate = endDate?.timeIntervalSince1970 ?? 0
            storedCustomMinutes = customMinutes
            storedActivityRaw = selectedActivity.rawValue
        default:
            break
        }
    }

    // MARK: - History persistence
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

    // MARK: - Local notifications
    private func requestNotificationPermissionIfNeeded() {
        #if os(iOS)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _,_ in }
            }
        }
        #endif
    }

    private func scheduleCompletionNotification() {
        #if os(iOS)
        guard let end = endDate else { return }
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Complete"
        content.body = "\(selectedActivity.rawValue) session finished."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, end.timeIntervalSinceNow), repeats: false)
        let req = UNNotificationRequest(identifier: "pomodoro_complete", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
        #endif
    }

    private func cancelCompletionNotification() {
        #if os(iOS)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["pomodoro_complete"])
        #endif
    }
}

// MARK: - Supporting Types
struct PomodoroSession: Codable, Identifiable {
    var id = UUID()
    let duration: Int
    let completedAt: Date
    let activity: ActivityType
}

