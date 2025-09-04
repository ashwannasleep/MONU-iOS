import SwiftUI
import Amplify

// MARK: - BucketListItem Model
struct BucketListItem: Identifiable, Codable, Hashable {
    let id: String
    var text: String
    var category: String?
    var date: Date?
    var link: String?
    var done: Bool
    var owner: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    init(id: String = UUID().uuidString, text: String, category: String? = nil, date: Date? = nil, link: String? = nil, done: Bool = false) {
        self.id = id
        self.text = text
        self.category = category
        self.date = date
        self.link = link
        self.done = done
        self.owner = nil
        self.createdAt = nil
        self.updatedAt = nil
    }
    
    init(apiModel: BucketItem) {
        self.id = apiModel.id
        self.text = apiModel.text
        self.category = apiModel.category
        self.date = apiModel.date?.foundationDate
        self.link = apiModel.link
        self.done = apiModel.done ?? false
        self.owner = apiModel.owner
        self.createdAt = apiModel.createdAt?.foundationDate
        self.updatedAt = apiModel.updatedAt?.foundationDate
    }
    
    func toAPIBucketItem() -> BucketItem {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return BucketItem(
            id: self.id,
            text: self.text,
            category: self.category,
            date: self.date != nil ? try? Temporal.Date(iso8601String: df.string(from: self.date!)) : nil,
            link: self.link,
            done: self.done,
            owner: self.owner
        )
    }
}

// MARK: - Category Enum
enum BucketCategory: String, CaseIterable {
    case need = "Need"
    case want = "Want"
    case adventure = "Adventure"
    case growth = "Growth"
    
    var displayName: String { rawValue }
}

// MARK: - BucketListView
struct BucketListView: View {
    @EnvironmentObject var navigationManager: NavigationContainer.NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var items: [BucketListItem] = []
    @State private var newItemText = ""
    @State private var selectedCategory: BucketCategory?
    @State private var selectedDate: Date?
    @State private var linkText = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showDatePicker = false
    @State private var scrollOffset: CGFloat = 0
    
    // Computed properties
    private var totalItems: Int { items.count }
    private var completedCount: Int { items.filter { $0.done }.count }
    private var progressPercent: Int {
        totalItems == 0 ? 0 : Int(round(Double(completedCount) / Double(totalItems) * 100))
    }
    
    private var backgroundColor: Color { themeManager.backgroundColor }
    private var textColor: Color { themeManager.textColor }
    private var cardBackgroundColor: Color { themeManager.cardBackgroundColor }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollViewReader(scrollOffset: $scrollOffset) { _ in
                VStack(spacing: 0) {
                    headerView
                    progressView
                        .padding(.horizontal, LayoutHelper.responsivePadding(for: LayoutHelper.screenWidth))
                        .padding(.bottom, 24)
                    inputSection
                        .padding(.horizontal, LayoutHelper.responsivePadding(for: LayoutHelper.screenWidth))
                        .padding(.bottom, 24)
                    itemsList
                        .padding(.horizontal, LayoutHelper.responsivePadding(for: LayoutHelper.screenWidth))
                        .padding(.bottom, 40)
                }
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
        .navigationBarHidden(true)
        .onAppear { fetchItems() }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated && items.isEmpty { fetchItems() }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton()
                Spacer()
            }
            .padding(.horizontal, LayoutHelper.responsivePadding(for: LayoutHelper.screenWidth))
            .padding(.top, LayoutHelper.isIPad ? 60 : 48)
            
            Button(action: { navigationManager.navigateToRoot() }) {
                Text("MONU")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 8)
            
            Text("This is your moment to dream ✨")
                .font(.custom("Georgia", size: 16))
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
    }
    
    // MARK: - Progress View
    private var progressView: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(themeManager.colorScheme == .dark ? Color(red: 0.27, green: 0.27, blue: 0.27) : Color(red: 0.90, green: 0.91, blue: 0.92))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(themeManager.accentColor)
                        .frame(width: geometry.size.width * CGFloat(progressPercent) / 100, height: 12)
                        .animation(.easeOut(duration: 0.5), value: progressPercent)
                }
            }
            .frame(height: 12)
            Text("\(progressPercent)% complete (\(completedCount) of \(totalItems) items)")
                .font(.custom("Georgia", size: 14))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 16) {
            // Main text input
            HStack {
                TextField("Add an item...", text: $newItemText)
                    .font(.custom("Georgia", size: 16))
                    .padding(12)
                    .background(cardBackgroundColor)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                    .cornerRadius(8)
                    .disabled(isLoading)
                    .onSubmit { if !isLoading { addItem() } }
            }
            
            // Category, Date, Link row
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Category Picker
                    Menu {
                        Button("None") { selectedCategory = nil }
                        ForEach(BucketCategory.allCases, id: \.self) { category in
                            Button(category.displayName) { selectedCategory = category }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory?.displayName ?? "Category")
                                .foregroundColor(selectedCategory == nil ? .secondary : textColor)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundColor(.secondary).font(.caption)
                        }
                        .font(.custom("Georgia", size: 16))
                        .padding(12)
                        .background(cardBackgroundColor)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                        .cornerRadius(8)
                    }
                    .disabled(isLoading)
                    
                    // Date Button
                    Button(action: { showDatePicker.toggle() }) {
                        HStack {
                            if let date = selectedDate {
                                Text(date.formatted(date: .abbreviated, time: .omitted)).foregroundColor(textColor)
                            } else {
                                Text("Date").foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "calendar").foregroundColor(.secondary).font(.caption)
                        }
                        .font(.custom("Georgia", size: 16))
                        .padding(12)
                        .background(cardBackgroundColor)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                        .cornerRadius(8)
                    }
                    .disabled(isLoading)
                }
                
                // Link input
                HStack {
                    TextField("Link (optional)", text: $linkText)
                        .font(.custom("Georgia", size: 16))
                        .padding(12)
                        .background(cardBackgroundColor)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                        .cornerRadius(8)
                        .disabled(isLoading)
                        .onSubmit { if !isLoading { addItem() } }
                }
            }
            
            // Add Button
            Button(action: addItem) {
                HStack {
                    if isLoading {
                        ProgressView().scaleEffect(0.8).foregroundColor(.white)
                        Text("Adding...")
                    } else {
                        Text("＋ Add Item")
                    }
                }
                .font(.custom("Georgia", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
                    ? themeManager.accentColor.opacity(0.3)
                    : Color(red: 0.78, green: 0.75, blue: 0.70)
                )
                .cornerRadius(8)
            }
            .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding(24)
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                DatePicker("Select Date", selection: Binding(
                    get: { selectedDate ?? Date() },
                    set: { selectedDate = $0 }
                ), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Clear") { selectedDate = nil; showDatePicker = false }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showDatePicker = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Items List
    private var itemsList: some View {
        LazyVStack(spacing: 16) {
            if isLoading && items.isEmpty {
                loadingView
            } else if items.isEmpty {
                emptyStateView
            } else {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    BucketItemRow(
                        item: item,
                        onToggle: { toggleDone(at: index) },
                        onDelete: { deleteItem(at: index) }
                    )
                }
            }
        }
    }
    
    // MARK: - Loading / Empty
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("Loading your bucket list...")
                .font(.custom("Georgia", size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(48)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("Your bucket list is empty")
                .font(.custom("Georgia", size: 20))
                .foregroundColor(.secondary)
            Text("Add your first dream above! ✨")
                .font(.custom("Georgia", size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(48)
    }
    
    // MARK: - Methods
    private func fetchItems() {
        isLoading = true
        Task {
            // Wait briefly for auth
            var attempts = 0
            while !authManager.isAuthenticated && attempts < 10 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                attempts += 1
            }
            guard authManager.isAuthenticated else {
                await MainActor.run {
                    self.errorMessage = "Please sign in to view bucket list"
                    self.showError = true
                    self.isLoading = false
                }
                return
            }
            do {
                let result = try await Amplify.API.query(request: .list(BucketItem.self))
                await MainActor.run {
                    switch result {
                    case .success(let items):
                        self.items = items.map { BucketListItem(apiModel: $0) }
                        self.errorMessage = ""
                        self.showError = false
                    case .failure(let error):
                        self.errorMessage = "Failed to load items: \(error.localizedDescription)"
                        self.showError = true
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load items: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func addItem() {
        let trimmedText = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        guard authManager.isAuthenticated else {
            errorMessage = "Please sign in to save bucket list items"
            showError = true
            return
        }
        let newItem = BucketListItem(
            text: trimmedText,
            category: selectedCategory?.rawValue,
            date: selectedDate,
            link: linkText.isEmpty ? nil : linkText,
            done: false
        )
        isLoading = true
        Task {
            do {
                let apiItem = newItem.toAPIBucketItem()
                let result = try await Amplify.API.mutate(request: .create(apiItem))
                await MainActor.run {
                    switch result {
                    case .success(let savedItem):
                        self.items.append(BucketListItem(apiModel: savedItem))
                        self.clearInputs()
                    case .failure(let error):
                        self.errorMessage = "Failed to save item: \(error.localizedDescription)"
                        self.showError = true
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to save item: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func toggleDone(at index: Int) {
        guard index < items.count else { return }
        guard authManager.isAuthenticated else {
            errorMessage = "Please sign in to update items"
            showError = true
            return
        }
        let original = items[index]
        items[index].done.toggle() // optimistic
        
        Task {
            do {
                var updated = original
                updated.done = !original.done
                let apiItem = updated.toAPIBucketItem()
                let result = try await Amplify.API.mutate(request: .update(apiItem))
                switch result {
                case .success:
                    break // OK
                case .failure(let error):
                    await MainActor.run {
                        self.items[index] = original // revert
                        self.errorMessage = "Failed to update item: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.items[index] = original // revert
                    self.errorMessage = "Failed to update item: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func deleteItem(at index: Int) {
        guard index < items.count else { return }
        guard authManager.isAuthenticated else {
            errorMessage = "Please sign in to delete items"
            showError = true
            return
        }

        // Optimistically remove from UI
        let uiItem = items.remove(at: index)

        // Build the API model instance to delete (must include id; include _version if your schema has it)
        var apiToDelete = uiItem.toAPIBucketItem()

        Task {
            do {
                // ✅ Correct overload: delete by passing the instance
                let result = try await Amplify.API.mutate(request: .delete(apiToDelete))
                switch result {
                case .success:
                    // Optionally refresh list here
                    break
                case .failure(let error):
                    await MainActor.run {
                        // Revert UI on backend failure
                        self.items.insert(uiItem, at: min(index, self.items.count))
                        self.errorMessage = "Failed to delete: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    // Revert UI on transport error
                    self.items.insert(uiItem, at: min(index, self.items.count))
                    self.errorMessage = "Failed to delete: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func clearInputs() {
        newItemText = ""
        selectedCategory = nil
        selectedDate = nil
        linkText = ""
    }
}

// MARK: - BucketItemRow
struct BucketItemRow: View {
    let item: BucketListItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isHovered = false
    
    private var cardBackgroundColor: Color { themeManager.cardBackgroundColor }
    private var textColor: Color { themeManager.textColor }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: onToggle) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(item.text)
                            .font(.custom("Georgia", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(item.done ? .secondary : textColor)
                            .strikethrough(item.done)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if item.category != nil || item.date != nil || item.link != nil {
                            HStack(spacing: 8) {
                                if let category = item.category {
                                    TagView(text: category, type: .category)
                                }
                                if let date = item.date {
                                    TagView(text: "📅 \(date.formatted(date: .abbreviated, time: .omitted))", type: .date)
                                }
                                if let link = item.link, let url = URL(string: link) {
                                    Link(destination: url) {
                                        TagView(text: "🔗 Link", type: .link)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(themeManager.colorScheme == .dark ? Color(red: 0.3, green: 0.1, blue: 0.1) : Color(red: 0.99, green: 0.95, blue: 0.95))
                            .opacity(isHovered ? 1 : 0)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { isHovered = $0 }
        }
        .padding(24)
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        .opacity(item.done ? 0.75 : 1)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
}

// MARK: - TagView
struct TagView: View {
    let text: String
    let type: TagType
    @EnvironmentObject var themeManager: ThemeManager
    
    enum TagType { case category, date, link }
    
    private var backgroundColor: Color {
        switch type {
        case .category, .date: return themeManager.cardBackgroundColor
        case .link: return themeManager.accentColor.opacity(0.2)
        }
    }
    private var foregroundColor: Color {
        switch type {
        case .category, .date: return themeManager.textColor
        case .link: return themeManager.accentColor
        }
    }

    var body: some View {
        Text(text)
            .font(.custom("Georgia", size: 14))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(16)
    }
}
