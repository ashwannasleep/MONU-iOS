import SwiftUI
import Amplify
import Foundation

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
        self.time = apiModel.time
        self.duration = apiModel.duration
        self.order = apiModel.order ?? 0
        self.done = apiModel.done ?? false
        self.owner = apiModel.owner
    }

    func toAPITask() -> DailyTask? {
        let dateOnlyString = String(self.date.prefix(10))
        guard let dateOnly = try? Temporal.Date(iso8601String: dateOnlyString) else { return nil }
        return DailyTask(
            id: self.id,
            date: dateOnly,
            text: self.text,
            time: self.time,
            duration: self.duration,
            order: self.order,
            done: self.done,
            owner: self.owner
        )
    }
}

struct DailyPlanView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager

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

    private var timeString: String {
        String(format:"%d:%02d %@", selectedHour, selectedMinute, selectedAMPM)
    }

    private var durString: String {
        if selDurH > 0 && selDurM > 0 { return "\(selDurH)h \(selDurM)m" }
        if selDurH > 0               { return "\(selDurH)h" }
        if selDurM > 0               { return "\(selDurM)m" }
        return ""
    }

    var body: some View {
        ZStack {
            (scheme == .dark ? Color(red:0.12,green:0.12,blue:0.12) : Color(red:0.97,green:0.96,blue:0.94))
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    weekStrip.padding(.bottom, 24)
                    dateProgress.padding(.bottom, 24)
                    addBox.padding(.bottom, 24)
                    tasks.padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear { load() }
        .onChange(of: selectedDate) { _,_ in load() }
        .alert("Error", isPresented: $showErr) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error)
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            Button { navigationManager.navigateToRoot() } label: {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(scheme == .dark ? .white : .black)
            }
            .buttonStyle(.plain)
            .padding(.top, 48)
            .padding(.bottom, 8)

            Text("Balance, intention, and clarity — one day at a time.")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }

    private var weekStrip: some View {
        let cal = Calendar.current
        let start = cal.dateInterval(of: .weekOfYear, for: Date())!.start
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }

        return HStack {
            Spacer()
            HStack(spacing: 16) {
                ForEach(days, id: \.self) { d in
                    WeekDayView(date: d,
                                isSelected: cal.isDate(d, inSameDayAs: selectedDate)) {
                        selectedDate = d
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var dateProgress: some View {
        VStack(spacing: 16) {
            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.custom("Georgia", size: 18)).italic().foregroundColor(.secondary)

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(scheme == .dark ? Color(red:0.27,green:0.27,blue:0.27) : Color(red:0.90,green:0.91,blue:0.92))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red:0.95,green:0.62,blue:0.56))
                            .frame(width: geo.size.width * CGFloat(progress) / 100, height: 8)
                            .animation(.easeOut(duration: 0.5), value: progress)
                    }
                }
                .frame(height: 8)

                Text("\(progress)% complete")
                    .font(.custom("Georgia", size: 14)).foregroundColor(.secondary)
            }
        }
    }

    private var addBox: some View {
        VStack(spacing: 16) {
            TextField("Add a new task...", text: $newTaskText, axis: .vertical)
                .font(.custom("Georgia", size: 16))
                .padding(16).frame(minHeight: 50)
                .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
                .cornerRadius(12)
                .onSubmit { save() }

            HStack(spacing: 12) {
                pickerBtn(image: "clock", label: timeString, isEmpty: timeString.isEmpty) {
                    showTimePicker = true
                }.sheet(isPresented: $showTimePicker) { timeSheet }

                pickerBtn(image: "timer", label: durString, isEmpty: durString.isEmpty) {
                    showDurPicker = true
                }.sheet(isPresented: $showDurPicker) { durSheet }

                Button(action: save) {
                    Text("＋").font(.system(size: 20, weight: .medium)).foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color(red:0.76,green:0.72,blue:0.64))
                        .cornerRadius(8)
                }
                .disabled(newTaskText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : .white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
    }

    @ViewBuilder private func pickerBtn(image: String, label: String, isEmpty: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: image).foregroundColor(.secondary).font(.system(size: 14))
                Text(label).foregroundColor(isEmpty ? .secondary : (scheme == .dark ? .white : .black))
                Spacer()
                Image(systemName: "chevron.down").foregroundColor(.secondary).font(.system(size: 12))
            }
            .font(.custom("Georgia", size: 16))
            .padding(12).frame(height: 44)
            .background(scheme == .dark ? Color(red:0.18,green:0.18,blue:0.18) : Color(red:0.98,green:0.98,blue:0.98))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red:0.82,green:0.84,blue:0.87), lineWidth: 1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var tasks: some View {
        LazyVStack(spacing: 12) {
            if todayTasks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 60)).foregroundColor(.secondary.opacity(0.3))
                    Text("No tasks for today").font(.custom("Georgia", size: 18)).foregroundColor(.secondary)
                    Text("Add your first task above to get started")
                        .font(.custom("Georgia", size: 14)).italic().foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity).padding(48)
            } else {
                ForEach(Array(todayTasks.enumerated()), id: \.element.id) { idx, task in
                    TaskRow(task: task,
                            onToggle: { toggle(idx) },
                            onDelete: { delete(idx) })
                }
            }
        }
    }

    private var timeSheet: some View {
        Text("Time picker sheet here…") // Add as needed
    }

    private var durSheet: some View {
        Text("Duration picker sheet here…") // Add as needed
    }

    private func load() {
        guard authManager.isAuthenticated else {
            print("❌ User not authenticated, skipping load")
            return
        }
        
        let dStr = uiDateFormatter.string(from: selectedDate)
        print("📥 Loading tasks for date: \(dStr)")
        
        Task {
            do {
                let q = try await Amplify.API.query(request: .list(DailyTask.self, where: DailyTask.keys.date.eq(dStr)))
                await MainActor.run {
                    switch q {
                    case .success(let api):
                        print("✅ Loaded \(api.count) tasks")
                        let sorted = api.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
                        plans[todayKey] = sorted.map(DailyPlanTask.init(apiModel:))
                    case .failure(let e):
                        print("❌ Load failed: \(e)")
                        show("Failed to load: \(e)")
                    }
                }
            } catch {
                print("❌ Load error: \(error)")
                show("Failed to load: \(error.localizedDescription)")
            }
        }
    }

    private func save() {
        let trimmed = newTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        guard authManager.isAuthenticated else {
            show("Please sign in to save tasks")
            return
        }

        print("💾 Saving task: \(trimmed)")
        print("📅 Date: \(todayKey)")
        print("🔐 User authenticated: \(authManager.isAuthenticated)")

        let ui = DailyPlanTask(
            id: UUID().uuidString,
            date: todayKey,
            text: trimmed,
            time: timeString,
            duration: durString.isEmpty ? nil : durString,
            order: todayTasks.count,
            done: false,
            owner: nil // Amplify will automatically set this to the current user
        )

        guard let api = ui.toAPITask() else { 
            print("❌ Failed to create API task")
            show("Date parse failed"); 
            return 
        }

        Task {
            do {
                print("🚀 Sending API request...")
                let result = try await Amplify.API.mutate(request: .create(api))
                await MainActor.run {
                    if case .success(let saved) = result {
                        print("✅ Task saved successfully: \(saved.id)")
                        plans[todayKey, default: []].append(DailyPlanTask(apiModel: saved))
                        newTaskText = ""
                    }
                }
            } catch {
                print("❌ Save failed: \(error)")
                show("Save failed: \(error.localizedDescription)")
            }
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

    private func show(_ msg: String) {
        error = msg
        showErr = true
    }
}
struct WeekDayView: View {
    let date: Date
    let isSelected: Bool
    let tap: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: tap) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.custom("Georgia", size: 12))
                    .foregroundColor(isSelected ? .white : .secondary)

                Text(date.formatted(.dateTime.day()))
                    .font(.custom("Georgia", size: 16)).fontWeight(.bold)
                    .foregroundColor(isSelected ? .white :
                        (scheme == .dark ? .white : Color(red: 0.23, green: 0.23, blue: 0.23)))
            }
            .frame(width: 40, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 999)
                    .fill(isSelected ? Color(red: 0.76, green: 0.72, blue: 0.64) : .clear)
            )
        }
        .buttonStyle(.plain)
    }
}
struct TaskRow: View {
    let task: DailyPlanTask
    let onToggle: () -> Void
    let onDelete: () -> Void

    @Environment(\.colorScheme) private var scheme
    @State private var hover = false

    var cardBG: Color {
        scheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : .white
    }

    var txt: Color {
        scheme == .dark ? Color(red: 0.94, green: 0.94, blue: 0.94) :
                          Color(red: 0.23, green: 0.23, blue: 0.23)
    }

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color(red: 0.78, green: 0.75, blue: 0.70), lineWidth: 2)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(task.done ? Color(red: 0.95, green: 0.62, blue: 0.56) : .clear))
                        if task.done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.text)
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(task.done ? .secondary : txt)
                            .strikethrough(task.done)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            if let t = task.time, !t.isEmpty { Tag(t) }
                            if let d = task.duration, !d.isEmpty { Tag(d) }
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
                        .fill(scheme == .dark ?
                              Color(red: 0.3, green: 0.1, blue: 0.1) :
                              Color(red: 0.99, green: 0.95, blue: 0.95))
                        .opacity(hover ? 1 : 0))
            }
            .buttonStyle(.plain)
            #if !os(iOS)
            .onHover { hover = $0 }
            #endif
        }
        .padding(20)
        .background(cardBG)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        .opacity(task.done ? 0.7 : 1)
        #if !os(iOS)
        .scaleEffect(hover ? 1.02 : 1)
        .animation(.easeInOut(duration: 0.2), value: hover)
        #endif
    }

    @ViewBuilder private func Tag(_ txt: String) -> some View {
        Text(txt)
            .font(.custom("Georgia", size: 14))
            .foregroundColor(scheme == .dark ?
                Color(red: 0.8, green: 0.8, blue: 0.8) :
                Color(red: 0.33, green: 0.33, blue: 0.33))
            .padding(.horizontal, 12).padding(.vertical, 4)
            .background(scheme == .dark ?
                Color(red: 0.27, green: 0.27, blue: 0.27) :
                Color(red: 0.94, green: 0.93, blue: 0.91))
            .cornerRadius(16)
    }
}
