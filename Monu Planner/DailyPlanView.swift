import SwiftUI
import Amplify
import Foundation
import UIKit

// ============================================================
// MARK: - Small font scaler that piggybacks on your LayoutHelper
// ============================================================
fileprivate func scaledFont(_ base: CGFloat, width w: CGFloat) -> CGFloat {
    // Light, predictable steps based on your breakpoints
    if w > LayoutHelper.largeiPadBreakpoint { return base * 1.20 } // big iPad / external
    if w > LayoutHelper.iPadBreakpoint     { return base * 1.10 }  // iPad
    return base // iPhone
}

// ============================================================
// MARK: - Time Formatting Utils (unchanged)
// ============================================================
fileprivate enum TimeFormatterUtil {
    static func displayTo24h(_ display: String) -> String? {
        let fmts = ["h:mm a", "h:m a", "h a"]
        for f in fmts {
            let df = DateFormatter()
            df.dateFormat = f
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = .current
            if let date = df.date(from: display.trimmingCharacters(in: .whitespaces)) {
                let out = DateFormatter()
                out.dateFormat = "HH:mm"
                out.locale = df.locale
                out.timeZone = df.timeZone
                return out.string(from: date)
            }
        }
        return nil
    }
    static func h24ToDisplay(_ h24: String) -> String? {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current
        if let date = df.date(from: h24.trimmingCharacters(in: .whitespaces)) {
            let out = DateFormatter()
            out.dateFormat = "h:mm a"
            out.locale = df.locale
            out.timeZone = df.timeZone
            return out.string(from: date)
        }
        return nil
    }
    static func normalizeForDisplay(_ maybeTime: String?) -> String? {
        guard let t = maybeTime, !t.isEmpty else { return nil }
        if t.uppercased().contains("AM") || t.uppercased().contains("PM") {
            if let h24 = displayTo24h(t), let disp = h24ToDisplay(h24) { return disp }
            return t
        }
        if let disp = h24ToDisplay(t) { return disp }
        return t
    }
    static func fromPickers(hour: Int, minute: Int, ampm: String) -> String {
        String(format: "%d:%02d %@", hour, minute, ampm)
    }
    static func to24h(hour: Int, minute: Int, ampm: String) -> String {
        var h = hour % 12
        if ampm.uppercased() == "PM" { h += 12 }
        return String(format: "%02d:%02d", h, minute)
    }
}

// ============================================================
// MARK: - UI Facade for Amplify Model
// ============================================================
struct DailyPlanTask: Identifiable, Equatable {
    let id: String
    var date: String
    var text: String
    var time: String?
    var duration: String?
    var order: Int
    var done: Bool
    var owner: String?
}

private let uiDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    df.timeZone = .current
    return df
}()

extension DailyPlanTask {
    init(apiModel: DailyTask) {
        self.id = apiModel.id
        self.date = apiModel.date.iso8601String
        self.text = apiModel.text
        self.time = TimeFormatterUtil.normalizeForDisplay(apiModel.time)
        self.duration = apiModel.duration
        self.order = apiModel.order ?? 0
        self.done = apiModel.done ?? false
        self.owner = apiModel.owner
    }

    func toAPITask() -> DailyTask? {
        let dateOnlyString = String(self.date.prefix(10))
        guard let dateOnly = try? Temporal.Date(iso8601String: dateOnlyString) else { return nil }

        var apiTime: String? = nil
        if let t = self.time, !t.isEmpty {
            apiTime = TimeFormatterUtil.displayTo24h(t) ?? t
        }

        return DailyTask(
            id: self.id,
            date: dateOnly,
            text: self.text,
            time: apiTime,
            duration: self.duration,
            order: self.order,
            done: self.done,
            owner: self.owner
        )
    }
}

// ============================================================
// MARK: - DailyPlanView
// ============================================================
struct DailyPlanView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var selectedDate = Date()
    @State private var plans: [String:[DailyPlanTask]] = [:]

    @State private var newTaskText = ""
    @State private var selectedHour = 9
    @State private var selectedMinute = 0
    @State private var selectedAMPM = "AM"
    @State private var selDurH = 0
    @State private var selDurM = 30

    @State private var error = ""
    @State private var showErr = false
    @State private var showTimePicker = false
    @State private var showDurPicker = false

    private var todayKey: String { uiDateFormatter.string(from: selectedDate) }
    private var todayTasks: [DailyPlanTask] { plans[todayKey] ?? [] }
    private var progress: Int {
        guard !todayTasks.isEmpty else { return 0 }
        let doneCnt = todayTasks.filter(\.done).count
        return Int(round(Double(doneCnt)/Double(todayTasks.count)*100))
    }

    private var timeString: String { String(format:"%d:%02d %@", selectedHour, selectedMinute, selectedAMPM) }
    private var durString: String {
        if selDurH > 0 && selDurM > 0 { return "\(selDurH)h \(selDurM)m" }
        if selDurH > 0               { return "\(selDurH)h" }
        if selDurM > 0               { return "\(selDurM)m" }
        return ""
    }

    var body: some View {
        GeometryReader { geo in
            let cw = geo.size.width
            let pad = LayoutHelper.responsivePadding(for: cw)
            let spacing = LayoutHelper.responsiveSpacing(for: cw)

            ZStack {
                (themeManager.colorScheme == .dark ? Color(red:0.12,green:0.12,blue:0.12)
                                                   : Color(red:0.97,green:0.96,blue:0.94))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            header(cw)
                            weekStrip(cw, horizontalPadding: pad)
                                .padding(.bottom, spacing * 0.5)

                            dateProgress(cw)
                                .padding(.horizontal, pad)
                                .padding(.bottom, spacing)

                            addBox(cw)
                                .padding(.horizontal, pad)
                                .padding(.bottom, spacing)

                            tasks(cw)
                                .padding(.horizontal, pad)
                                .padding(.bottom, 40)
                        }
                        .frame(maxWidth: maxContentWidth(for: cw, padding: pad))
                        .frame(maxWidth: .infinity)
                    }
                }

                if showTimePicker || showDurPicker {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture { showTimePicker = false; showDurPicker = false }

                    VStack {
                        Spacer()
                        VStack(spacing: 16) {
                            HStack {
                                Text(showTimePicker ? "Select Time" : "Select Duration")
                                    .font(.system(size: scaledFont(16, width: cw), weight: .semibold))
                                Spacer()
                                Button("Done") { showTimePicker = false; showDurPicker = false }
                                    .font(.system(size: scaledFont(14, width: cw), weight: .medium))
                            }
                            if showTimePicker { timeRoller(cw) } else { durationRoller(cw) }
                        }
                        .padding(pad)
                        .frame(maxWidth: min(maxContentWidth(for: cw, padding: pad) * 0.95, 500))
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                        .padding(.bottom, 40)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.28, dampingFraction: 0.9), value: showTimePicker || showDurPicker)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { load() }
        .onChange(of: selectedDate) { _,_ in load() }
        .refreshable { await refreshTasks() }
        .alert("Error", isPresented: $showErr) {
            Button("OK", role: .cancel) { }
        } message: { Text(error) }
    }

    // A single “readable column” width that feels good on all devices.
    private func maxContentWidth(for cw: CGFloat, padding pad: CGFloat) -> CGFloat {
        if cw > LayoutHelper.largeiPadBreakpoint { return 900 }
        if cw > LayoutHelper.iPadBreakpoint     { return 760 }
        return min(420, cw - 2 * pad)
    }

    // ========================================================
    // MARK: - Header
    // ========================================================
    private func header(_ cw: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack {
                BackButton()
                Spacer()
            }
            .padding(.horizontal, LayoutHelper.responsivePadding(for: cw))
            .padding(.top, LayoutHelper.isIPad ? 60 : 48)

            Button { navigationManager.navigateToRoot() } label: {
                Text("MONU")
                    .font(.custom("Georgia", size: scaledFont(32, width: cw)))
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.colorScheme == .dark ? .white : .black)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)

            Text("Balance, intention, and clarity — one day at a time.")
                .font(.custom("Georgia", size: scaledFont(16, width: cw)))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LayoutHelper.responsivePadding(for: cw))
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }

    // ========================================================
    // MARK: - Week strip
    // ========================================================
    private func weekStrip(_ cw: CGFloat, horizontalPadding pad: CGFloat) -> some View {
        let cal = Calendar.current
        let start = cal.dateInterval(of: .weekOfYear, for: Date())!.start
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }

        let columnWidth = maxContentWidth(for: cw, padding: pad)
        let inner = columnWidth - pad * 2
        let gap: CGFloat =  LayoutHelper.responsiveSpacing(for: cw) * 0.4
        // 7 items + 6 gaps
        let pillWidth = max(38, min(56, (inner - gap * 6) / 7))
        let pillHeight = pillWidth + (cw > LayoutHelper.iPadBreakpoint ? 8 : 4)

        return HStack(spacing: gap) {
            ForEach(days, id: \.self) { d in
                WeekDayView(
                    cw: cw,
                    date: d,
                    isSelected: cal.isDate(d, inSameDayAs: selectedDate),
                    width: pillWidth,
                    height: pillHeight
                ) { selectedDate = d }
            }
        }
        .padding(.horizontal, LayoutHelper.responsivePadding(for: cw))
    }

    // ========================================================
    // MARK: - Date progress
    // ========================================================
    private func dateProgress(_ cw: CGFloat) -> some View {
        VStack(spacing: 12) {
            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.custom("Georgia", size: scaledFont(18, width: cw)))
                .italic()
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(themeManager.colorScheme == .dark ? Color(red:0.27,green:0.27,blue:0.27) : Color(red:0.90,green:0.91,blue:0.92))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(themeManager.accentColor)
                            .frame(width: max(0, geo.size.width * CGFloat(progress) / 100), height: 8)
                            .animation(.easeOut(duration: 0.5), value: progress)
                    }
                }
                .frame(height: 8)

                Text("\(progress)% complete")
                    .font(.custom("Georgia", size: scaledFont(14, width: cw)))
                    .foregroundColor(.secondary)
            }
        }
        .padding(LayoutHelper.responsivePadding(for: cw))
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    // ========================================================
    // MARK: - Add Box
    // ========================================================
    private func addBox(_ cw: CGFloat) -> some View {
        VStack(spacing: 16) {
            TextField("Add a new task...", text: $newTaskText, axis: .vertical)
                .font(.custom("Georgia", size: scaledFont(16, width: cw)))
                .padding(14)
                .frame(minHeight: 50)
                .background(themeManager.colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(themeManager.accentColor.opacity(0.25), lineWidth: 1))
                .cornerRadius(10)
                .onSubmit { save() }

            HStack(spacing: 12) {
                pickerBtn(cw: cw, image: "clock", label: timeString, isEmpty: timeString.isEmpty) {
                    showDurPicker = false
                    withAnimation { showTimePicker = true }
                }
                pickerBtn(cw: cw, image: "timer", label: durString, isEmpty: durString.isEmpty) {
                    showTimePicker = false
                    withAnimation { showDurPicker = true }
                }
                Button(action: save) {
                    Text("＋")
                        .font(.system(size: scaledFont(20, width: cw), weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(themeManager.accentColor)
                        .cornerRadius(8)
                }
                .disabled(newTaskText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(LayoutHelper.responsivePadding(for: cw))
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    @ViewBuilder private func pickerBtn(cw: CGFloat, image: String, label: String, isEmpty: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: image).foregroundColor(.secondary).font(.system(size: 14))
                Text(label).foregroundColor(isEmpty ? .secondary : (themeManager.colorScheme == .dark ? .white : .black))
                Spacer()
                Image(systemName: "chevron.down").foregroundColor(.secondary).font(.system(size: 12))
            }
            .font(.custom("Georgia", size: scaledFont(16, width: cw)))
            .padding(12).frame(height: 44)
            .background(themeManager.colorScheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    // ========================================================
    // MARK: - Tasks
    // ========================================================
    private func tasks(_ cw: CGFloat) -> some View {
        LazyVStack(spacing: 12) {
            if todayTasks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: scaledFont(60, width: cw)))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text("No tasks for today")
                        .font(.custom("Georgia", size: scaledFont(18, width: cw)))
                        .foregroundColor(.secondary)
                    Text("Add your first task above to get started")
                        .font(.custom("Georgia", size: scaledFont(14, width: cw)))
                        .italic().foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity).padding(48)
            } else {
                ForEach(Array(todayTasks.enumerated()), id: \.element.id) { idx, task in
                    DailyPlanTaskRow(
                        cw: cw,
                        task: task,
                        onToggle: { toggle(idx) },
                        onDelete: { delete(idx) }
                    )
                }
            }
        }
    }

    // ========================================================
    // MARK: - Pickers
    // ========================================================
    private func timeRoller(_ cw: CGFloat) -> some View {
        let rollerWidth: CGFloat  = cw > LayoutHelper.iPadBreakpoint ? 80 : 70
        let rollerHeight: CGFloat = cw > LayoutHelper.iPadBreakpoint ? 140 : 120

        return HStack(spacing: 16) {
            VStack {
                Text("Hour")
                    .font(.system(size: scaledFont(12, width: cw), weight: .medium))
                    .foregroundColor(.secondary)
                Picker("Hour", selection: $selectedHour) {
                    ForEach(1...12, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: rollerWidth, height: rollerHeight)
            }
            VStack {
                Text("Minute")
                    .font(.system(size: scaledFont(12, width: cw), weight: .medium))
                    .foregroundColor(.secondary)
                Picker("Minute", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: rollerWidth, height: rollerHeight)
            }
            VStack {
                Text("AM/PM")
                    .font(.system(size: scaledFont(12, width: cw), weight: .medium))
                    .foregroundColor(.secondary)
                Picker("AM/PM", selection: $selectedAMPM) {
                    Text("AM").tag("AM"); Text("PM").tag("PM")
                }
                .pickerStyle(.wheel)
                .frame(width: rollerWidth + 8, height: rollerHeight)
            }
        }
    }

    private func durationRoller(_ cw: CGFloat) -> some View {
        let rollerWidth: CGFloat  = cw > LayoutHelper.iPadBreakpoint ? 90 : 80
        let rollerHeight: CGFloat = cw > LayoutHelper.iPadBreakpoint ? 140 : 120

        return HStack(spacing: 16) {
            VStack {
                Text("Hours")
                    .font(.system(size: scaledFont(12, width: cw), weight: .medium))
                    .foregroundColor(.secondary)
                Picker("Hours", selection: $selDurH) {
                    ForEach(0...12, id: \.self) { Text("\($0)h").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: rollerWidth, height: rollerHeight)
            }
            VStack {
                Text("Minutes")
                    .font(.system(size: scaledFont(12, width: cw), weight: .medium))
                    .foregroundColor(.secondary)
                Picker("Minutes", selection: $selDurM) {
                    ForEach(0..<60, id: \.self) { Text("\($0)m").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: rollerWidth, height: rollerHeight)
            }
        }
    }

    // ========================================================
    // MARK: - Data
    // ========================================================
    private func load() {
        guard authManager.isAuthenticated else {
            print("❌ User not authenticated, skipping load")
            return
        }
        let dStr = uiDateFormatter.string(from: selectedDate)
        Task {
            do {
                let q = try await Amplify.API.query(request: .list(DailyTask.self))
                await MainActor.run {
                    switch q {
                    case .success(let api):
                        let filtered = api.filter { String($0.date.iso8601String.prefix(10)) == dStr }
                        let sorted = filtered.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
                        plans[todayKey] = sorted.map(DailyPlanTask.init(apiModel:))
                    case .failure(let e):
                        show("Failed to load: \(e)")
                    }
                }
            } catch {
                show("Failed to load: \(error.localizedDescription)")
            }
        }
    }

    private func refreshTasks() async { await MainActor.run { load() } }

    private func save() {
        let trimmed = newTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard authManager.isAuthenticated else { show("Please sign in to save tasks"); return }

        let ui = DailyPlanTask(
            id: UUID().uuidString,
            date: todayKey,
            text: trimmed,
            time: timeString.isEmpty ? nil : timeString,
            duration: durString.isEmpty ? nil : durString,
            order: todayTasks.count,
            done: false,
            owner: nil
        )
        guard let api = ui.toAPITask() else { show("Date parse failed"); return }

        Task {
            do {
                let result = try await Amplify.API.mutate(request: .create(api))
                await MainActor.run {
                    if case .success(let saved) = result {
                        plans[todayKey, default: []].append(DailyPlanTask(apiModel: saved))
                        newTaskText = ""
                    }
                }
            } catch { show("Save failed: \(error.localizedDescription)") }
        }
    }

    private func toggle(_ idx: Int) {
        guard idx < todayTasks.count else { return }
        plans[todayKey]![idx].done.toggle()
        if let api = plans[todayKey]![idx].toAPITask() {
            Task { _ = try? await Amplify.API.mutate(request: .update(api)) }
        }
    }

    private func delete(_ idx: Int) {
        guard idx < todayTasks.count else { return }
        let ui = plans[todayKey]!.remove(at: idx)
        if let api = ui.toAPITask() {
            Task { _ = try? await Amplify.API.mutate(request: .delete(api)) }
        }
    }

    private func show(_ msg: String) { error = msg; showErr = true }
}

// ============================================================
// MARK: - WeekDayView (uses cw for consistent fonts)
// ============================================================
struct WeekDayView: View {
    let cw: CGFloat
    let date: Date
    let isSelected: Bool
    let width: CGFloat
    let height: CGFloat
    let tap: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: tap) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.custom("Georgia", size: scaledFont(12, width: cw)))
                    .foregroundColor(isSelected ? .white : .secondary)

                Text(date.formatted(.dateTime.day()))
                    .font(.custom("Georgia", size: scaledFont(16, width: cw)))
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white :
                        (themeManager.colorScheme == .dark ? .white : Color(red: 0.23, green: 0.23, blue: 0.23)))
            }
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 999)
                    .fill(isSelected ? themeManager.accentColor : .clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// ============================================================
// MARK: - Task Row (uses cw for consistent fonts)
// ============================================================
struct DailyPlanTaskRow: View {
    let cw: CGFloat
    let task: DailyPlanTask
    let onToggle: () -> Void
    let onDelete: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @State private var hover = false

    var cardBG: Color {
        themeManager.colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : .white
    }
    var txt: Color {
        themeManager.colorScheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) :
                          Color(red: 0.23, green: 0.23, blue: 0.23)
    }

    private var displayTime: String? {
        TimeFormatterUtil.normalizeForDisplay(task.time)
    }

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(task.done ? themeManager.accentColor : .clear))
                        if task.done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.text)
                            .font(.custom("Georgia", size: scaledFont(16, width: cw)))
                            .foregroundColor(task.done ? .secondary : txt)
                            .strikethrough(task.done)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            if let t = displayTime, !t.isEmpty { Tag(cw, t) }
                            if let d = task.duration, !d.isEmpty { Tag(cw, d) }
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
                    .background(Circle()
                        .fill(themeManager.colorScheme == .dark ?
                              Color(red: 0.3, green: 0.1, blue: 0.1) :
                              Color(red: 0.99, green: 0.95, blue: 0.95))
                        .opacity(hover ? 1 : 0))
            }
            .buttonStyle(.plain)
            #if !os(iOS)
            .onHover { hover = $0 }
            #endif
        }
        .padding(LayoutHelper.responsivePadding(for: cw))
        .background(cardBG)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        .opacity(task.done ? 0.7 : 1)
        #if !os(iOS)
        .scaleEffect(hover ? 1.02 : 1)
        .animation(.easeInOut(duration: 0.2), value: hover)
        #endif
    }

    @ViewBuilder private func Tag(_ cw: CGFloat, _ text: String) -> some View {
        Text(text)
            .font(.custom("Georgia", size: scaledFont(14, width: cw)))
            .foregroundColor(themeManager.colorScheme == .dark ?
                Color(red: 0.8, green: 0.8, blue: 0.8) :
                Color(red: 0.33, green: 0.33, blue: 0.33))
            .padding(.horizontal, 12).padding(.vertical, 4)
            .background(themeManager.colorScheme == .dark ?
                Color(red: 0.27, green: 0.27, blue: 0.27) :
                Color(red: 0.94, green: 0.93, blue: 0.91))
            .cornerRadius(16)
    }
}

