import Foundation
import Combine

@MainActor
final class CalendarSyncManager: ObservableObject {
    // Injected providers
    @Published private(set) var appleProvider = EventKitProvider()
    @Published private(set) var googleProvider: GoogleCalendarProvider = GoogleCalendarProvider()
    
    // User choice - simplified state management
    @Published var useApple = false {
        didSet {
            if useApple != oldValue {
                Task {
                    if useApple {
                        await connectApple()
                    } else {
                        await disconnectApple()
                    }
                }
            }
        }
    }
    
    @Published var useGoogle = false {
        didSet {
            if useGoogle != oldValue {
                Task {
                    if useGoogle {
                        await connectGoogle()
                    } else {
                        await disconnectGoogle()
                    }
                }
            }
        }
    }
    
    // Unified events for the UI
    @Published private(set) var events: [CalendarEvent] = []
    
    // Loading states
    @Published var isLoading = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var errorMessage: String?
    
    // Enhanced date range with configurable lookback/ahead
    private var lookBack: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    }
    
    private var lookAhead: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }
    
    // MARK: - Public API with Enhanced Error Handling
    
    func setCurrentAppUser(_ email: String?) async {
        print("🔐 CalendarSyncManager: Setting current app user to: \(email ?? "nil")")
        await googleProvider.setCurrentAppUser(email)
    }
    
    func connectApple() async {
        clearError()
        isLoading = true
        
        do {
            try await appleProvider.requestAuthorization()
            useApple = true
            await reSync()
        } catch {
            handleError("Apple Calendar connection failed: \(error.localizedDescription)")
            useApple = false
        }
        
        isLoading = false
    }
    
    func connectGoogle() async {
        clearError()
        isLoading = true
        
        print("🔄 CalendarSyncManager: Connecting to Google Calendar...")
        
        do {
            try await googleProvider.requestAuthorization()
            useGoogle = true
            print("✅ CalendarSyncManager: Google Calendar connected successfully")
            await reSync()
        } catch {
            let errorMessage = "Google Calendar connection failed: \(error.localizedDescription)"
            print("❌ CalendarSyncManager: \(errorMessage)")
            handleError(errorMessage)
            useGoogle = false
        }
        
        isLoading = false
    }
    
    func forceRefreshGoogle() async {
        print("🔄 CalendarSyncManager: Force refreshing Google Calendar...")
        clearError()
        isLoading = true
        
        do {
            // Force refresh the cache
            _ = try await googleProvider.forceRefreshCache()
            useGoogle = true
            print("✅ CalendarSyncManager: Google Calendar cache refreshed successfully")
            await reSync()
        } catch {
            print("❌ CalendarSyncManager: Google Calendar cache refresh failed: \(error)")
            useGoogle = false
        }
        
        isLoading = false
    }
    
    func refreshGoogleForDate(_ date: Date) async {
        print("🔄 CalendarSyncManager: Refreshing Google Calendar for specific date: \(date)")
        clearError()
        isLoading = true
        
        do {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            let freshEvents = try await googleProvider.fetchEventsForDateRange(from: startOfDay, to: endOfDay)
            print("✅ CalendarSyncManager: Fetched \(freshEvents.count) fresh events for \(date)")
            
            // Update the events list with fresh data
            await MainActor.run {
                // Remove old events for this date and add fresh ones
                let filteredEvents = self.events.filter { event in
                    !calendar.isDate(event.start, inSameDayAs: date)
                }
                self.events = filteredEvents + freshEvents
            }
        } catch {
            print("❌ CalendarSyncManager: Failed to refresh Google Calendar for date: \(error)")
            handleError("Failed to refresh Google Calendar: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Auto-connect functionality
    
    func autoConnect() async {
        clearError()
        isLoading = true
        
        // Check existing connections first
        let appleConnected = appleProvider.isConnected
        let googleConnected = googleProvider.isConnected
        
        print("🔍 CalendarSyncManager: Apple connected: \(appleConnected), Google connected: \(googleConnected)")
        
        // Only request authorization if not already connected
        if !appleConnected {
            do {
                try await appleProvider.requestAuthorization()
                useApple = true
                print("✅ Apple Calendar connected successfully")
            } catch {
                print("❌ Apple Calendar connection failed: \(error.localizedDescription)")
                useApple = false
            }
        } else {
            useApple = true
            print("✅ Apple Calendar already connected")
        }
        
        if !googleConnected {
            do {
                try await googleProvider.requestAuthorization()
                useGoogle = true
                print("✅ Google Calendar connected successfully")
            } catch {
                print("❌ Google Calendar connection failed: \(error.localizedDescription)")
                useGoogle = false
            }
        } else {
            useGoogle = true
            print("✅ Google Calendar already connected")
        }
        
        // Sync events if any provider is connected
        if useApple || useGoogle {
            await reSync()
        }
        
        isLoading = false
    }
    
    func disconnectApple() async {
        await appleProvider.disconnect()
        await reSync()
    }
    
    func disconnectGoogle() async {
        await googleProvider.disconnect()
        await reSync()
    }
    
    // MARK: - CRUD Operations with Better Error Handling
    
    func add(_ event: CalendarEvent) async throws {
        clearError()
        
        do {
            switch event.provider {
            case .apple:
                guard useApple && appleProvider.isConnected else {
                    throw CalendarSyncError.providerNotConnected(.apple)
                }
                try await appleProvider.add(event)
                
            case .google:
                guard useGoogle && googleProvider.isConnected else {
                    throw CalendarSyncError.providerNotConnected(.google)
                }
                try await googleProvider.add(event)
            }
            
            await reSync()
        } catch {
            handleError("Failed to add event: \(error.localizedDescription)")
            throw error
        }
    }
    
    func update(_ event: CalendarEvent) async throws {
        clearError()
        
        do {
            switch event.provider {
            case .apple:
                guard useApple && appleProvider.isConnected else {
                    throw CalendarSyncError.providerNotConnected(.apple)
                }
                try await appleProvider.update(event)
                
            case .google:
                guard useGoogle && googleProvider.isConnected else {
                    throw CalendarSyncError.providerNotConnected(.google)
                }
                try await googleProvider.update(event)
            }
            
            await reSync()
        } catch {
            handleError("Failed to update event: \(error.localizedDescription)")
            throw error
        }
    }
    
    func delete(_ event: CalendarEvent) async throws {
        clearError()
        
        do {
            switch event.provider {
            case .apple:
                guard useApple && appleProvider.isConnected else {
                    throw CalendarSyncError.providerNotConnected(.apple)
                }
                try await appleProvider.delete(event)
                
            case .google:
                guard useGoogle && googleProvider.isConnected else {
                    throw CalendarSyncError.providerNotConnected(.google)
                }
                try await googleProvider.delete(event)
            }
            
            await reSync()
        } catch {
            handleError("Failed to delete event: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Enhanced Sync Logic
    
    @discardableResult
    func reSync() async -> [CalendarEvent] {
        clearError()
        isLoading = true
        
        print("🔄 CalendarSyncManager: Starting sync...")
        print("   - Apple connected: \(useApple && appleProvider.isConnected)")
        print("   - Google connected: \(useGoogle && googleProvider.isConnected)")
        
        var allEvents: [CalendarEvent] = []
        
        // Fetch from Apple if connected
        if useApple && appleProvider.isConnected {
            do {
                let appleEvents = try await appleProvider.fetchEvents(from: lookBack, to: lookAhead)
                allEvents.append(contentsOf: appleEvents)
                print("✅ CalendarSyncManager: Fetched \(appleEvents.count) Apple events")
            } catch {
                print("❌ CalendarSyncManager: Apple Calendar fetch failed: \(error)")
                handleError("Apple Calendar fetch failed: \(error.localizedDescription)")
            }
        }
        
        // Fetch from Google if connected
        if useGoogle && googleProvider.isConnected {
            do {
                let googleEvents = try await googleProvider.fetchEvents(from: lookBack, to: lookAhead)
                allEvents.append(contentsOf: googleEvents)
                print("✅ CalendarSyncManager: Fetched \(googleEvents.count) Google events")
            } catch {
                print("❌ CalendarSyncManager: Google Calendar fetch failed: \(error)")
                handleError("Google Calendar fetch failed: \(error.localizedDescription)")
                
                // Try to force refresh Google connection if it fails
                if error.localizedDescription.contains("401") || error.localizedDescription.contains("403") {
                    print("🔄 CalendarSyncManager: Attempting to refresh Google connection...")
                    await forceRefreshGoogle()
                }
            }
        }
        
        // Process and update events
        let processedEvents = allEvents
            .mergedDeduping()
            .sorted(by: { $0.start < $1.start })
        
        events = processedEvents
        lastSyncDate = Date()
        isLoading = false
        
        // Debug logging
        print("🔄 CalendarSyncManager: Sync Complete:")
        print("   - Apple connected: \(useApple && appleProvider.isConnected)")
        print("   - Google connected: \(useGoogle && googleProvider.isConnected)")
        print("   - Total events fetched: \(allEvents.count)")
        print("   - Processed events: \(processedEvents.count)")
        print("   - Date range: \(lookBack) to \(lookAhead)")
        
        return processedEvents
    }
    
    // MARK: - Utility Methods
    
    func refreshAllProviders() async {
        clearError()
        
        // Refresh connections for active providers
        if useApple {
            await connectApple()
        }
        
        if useGoogle {
            await connectGoogle()
        }
    }
    
    func getEventsForDate(_ date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        
        // Normalize the target date to start of day for comparison
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        print("📅 CalendarSyncManager: Looking for events on \(date)")
        print("   - Start of day: \(startOfDay)")
        print("   - End of day: \(endOfDay)")
        print("   - Total events available: \(events.count)")
        
        let filteredEvents = events.filter { event in
            // Check if event starts on this day
            let eventStartOfDay = calendar.startOfDay(for: event.start)
            let eventEndOfDay = calendar.startOfDay(for: event.end)
            
            // Event is on this day if:
            // 1. Event starts on this day, OR
            // 2. Event ends on this day, OR  
            // 3. Event spans across this day
            let isOnThisDay = (eventStartOfDay >= startOfDay && eventStartOfDay < endOfDay) ||
                              (eventEndOfDay > startOfDay && eventEndOfDay <= endOfDay) ||
                              (eventStartOfDay < startOfDay && eventEndOfDay > endOfDay)
            
            if isOnThisDay {
                print("   ✅ Event '\(event.title)' matches: start=\(event.start), end=\(event.end)")
            }
            
            return isOnThisDay
        }
        
        print("📅 CalendarSyncManager: Found \(filteredEvents.count) events for \(date)")
        return filteredEvents
    }
    
    func getEventsForDateRange(from start: Date, to end: Date) -> [CalendarEvent] {
        return events.filter { event in
            event.start >= start && event.start <= end
        }
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ message: String) {
        errorMessage = message
        print("CalendarSyncManager Error: \(message)")
    }
    
    private func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Connection Status Helpers
    
    var hasAnyConnection: Bool {
        return (useApple && appleProvider.isConnected) || (useGoogle && googleProvider.isConnected)
    }
    
    var connectionSummary: String {
        let connections = [
            (useApple && appleProvider.isConnected) ? "Apple" : nil,
            (useGoogle && googleProvider.isConnected) ? "Google" : nil
        ].compactMap { $0 }
        
        if connections.isEmpty {
            return "No calendars connected"
        } else {
            return "Connected: \(connections.joined(separator: ", "))"
        }
    }
}

// MARK: - Custom Error Types

enum CalendarSyncError: LocalizedError {
    case providerNotConnected(Source)
    case syncFailed(String)
    case operationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .providerNotConnected(let source):
            return "\(source.rawValue) is not connected"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        }
    }
}
