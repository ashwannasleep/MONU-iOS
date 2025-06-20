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
    @Published private(set) var isLoading = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var errorMessage: String?
    
    // Enhanced date range with configurable lookback/ahead
    private var lookBack: Date {
        Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
    }
    
    private var lookAhead: Date {
        Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    }
    
    // MARK: - Public API with Enhanced Error Handling
    
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
        
        do {
            try await googleProvider.requestAuthorization()
            useGoogle = true
            await reSync()
        } catch {
            handleError("Google Calendar connection failed: \(error.localizedDescription)")
            useGoogle = false
        }
        
        isLoading = false
    }
    
    // MARK: - Auto-connect functionality
    
    func autoConnect() async {
        clearError()
        isLoading = true
        
        // Try to connect to Apple Calendar first (usually more reliable)
        do {
            try await appleProvider.requestAuthorization()
            useApple = true
            print("✅ Apple Calendar connected successfully")
        } catch {
            print("❌ Apple Calendar connection failed: \(error.localizedDescription)")
            useApple = false
        }
        
        // Try to connect to Google Calendar
        do {
            try await googleProvider.requestAuthorization()
            useGoogle = true
            print("✅ Google Calendar connected successfully")
        } catch {
            print("❌ Google Calendar connection failed: \(error.localizedDescription)")
            useGoogle = false
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
        
        var allEvents: [CalendarEvent] = []
        
        // Fetch from Apple if connected
        if useApple && appleProvider.isConnected {
            do {
                let appleEvents = try await appleProvider.fetchEvents(from: lookBack, to: lookAhead)
                allEvents.append(contentsOf: appleEvents)
            } catch {
                print("Apple Calendar fetch failed: \(error)")
                // Don't fail completely, just log and continue
            }
        }
        
        // Fetch from Google if connected
        if useGoogle && googleProvider.isConnected {
            do {
                let googleEvents = try await googleProvider.fetchEvents(from: lookBack, to: lookAhead)
                allEvents.append(contentsOf: googleEvents)
            } catch {
                print("Google Calendar fetch failed: \(error)")
                // Don't fail completely, just log and continue
            }
        }
        
        // Process and update events
        let processedEvents = allEvents
            .mergedDeduping()
            .sorted(by: { $0.start < $1.start })
        
        events = processedEvents
        lastSyncDate = Date()
        isLoading = false
        
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
        return events.filter { event in
            calendar.isDate(event.start, inSameDayAs: date) ||
            (event.start <= date && event.end >= date)
        }
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
