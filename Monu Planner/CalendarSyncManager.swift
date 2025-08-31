import Foundation
import Combine
import GoogleSignIn

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
    
    // MARK: - Calendar helpers (explicit local timezone everywhere)
    private var localCal: Calendar {
        var c = Calendar.current
        c.timeZone = .current
        return c
    }
    private func dayInterval(for date: Date) -> DateInterval {
        localCal.dateInterval(of: .day, for: date)
        ?? DateInterval(start: localCal.startOfDay(for: date),
                        end: localCal.date(byAdding: .day, value: 1, to: localCal.startOfDay(for: date))!)
    }
    /// Overlap check: [eventStart, eventEnd) vs [rangeStart, rangeEnd)
    private func overlaps(eventStart: Date, eventEnd: Date?, rangeStart: Date, rangeEnd: Date) -> Bool {
        let eStart = eventStart
        let eEnd   = eventEnd ?? eventStart
        return (eStart < rangeEnd) && (eEnd > rangeStart)
    }
    
    // Enhanced date range with configurable lookback/ahead
    private var lookBack: Date {
        localCal.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    }
    private var lookAhead: Date {
        localCal.date(byAdding: .month, value: 1, to: Date()) ?? Date()
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
            let msg = "Google Calendar connection failed: \(error.localizedDescription)"
            print("❌ CalendarSyncManager: \(msg)")
            handleError(msg)
            useGoogle = false
        }
        isLoading = false
    }
    
    func forceRefreshGoogle() async {
        print("🔄 CalendarSyncManager: Force refreshing Google Calendar...")
        clearError()
        isLoading = true
        do {
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
            let day = dayInterval(for: date)
            let freshEvents = try await googleProvider.fetchEventsForDateRange(from: day.start, to: day.end)
            print("✅ CalendarSyncManager: Fetched \(freshEvents.count) fresh events for \(date)")
            
            await MainActor.run {
                // Remove ALL events overlapping this day (including spanning events),
                // then append the fresh set for the day.
                self.events.removeAll { ev in
                    overlaps(eventStart: ev.start, eventEnd: ev.end, rangeStart: day.start, rangeEnd: day.end)
                }
                self.events.append(contentsOf: freshEvents)
                self.events.sort { $0.start < $1.start }
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
        
        let appleConnected = appleProvider.isConnected
        let googleConnected = googleProvider.isConnected
        print("🔍 CalendarSyncManager: Apple connected: \(appleConnected), Google connected: \(googleConnected)")
        
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
        
        print("check google: \(googleConnected)")
        if googleConnected {
            print("check google")
        }
        
        if !googleConnected {
            do {
                print("🔄 CalendarSyncManager: Attempting Google Calendar connection...")
                try await googleProvider.requestAuthorization()
                useGoogle = true
                print("✅ Google Calendar connected successfully")
            } catch {
                print("❌ Google Calendar connection failed: \(error.localizedDescription)")
                
                // Provide user-friendly error message based on error type
                if error.localizedDescription.contains("Code=-4") {
                    handleError("Google Calendar session expired. Please sign in again.")
                } else if error.localizedDescription.contains("networkError") {
                    handleError("Network error. Please check your internet connection.")
                } else if error.localizedDescription.contains("permissionDenied") {
                    handleError("Calendar permission denied. Please grant access in Settings.")
                } else {
                    handleError("Google Calendar connection failed: \(error.localizedDescription)")
                }
                
                useGoogle = false
            }
        } else {
            useGoogle = true
            print("✅ Google Calendar already connected")
        }
        
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
            // Check if Google Sign-In has a previous session
            let hasPreviousSignIn = GIDSignIn.sharedInstance.hasPreviousSignIn()
            print("🔍 CalendarSyncManager: Google Sign-In previous session check:")
            print("   - hasPreviousSignIn: \(hasPreviousSignIn)")
            print("   - Current user: \(GIDSignIn.sharedInstance.currentUser?.profile?.email ?? "nil")")
            
            // Log access token and refresh token
            if let currentUser = GIDSignIn.sharedInstance.currentUser {
                print("🔐 CalendarSyncManager: Token information:")
                print("   - Access Token: \(currentUser.accessToken.tokenString)")
                print("   - Refresh Token: \(currentUser.refreshToken.tokenString)")
                print("   - Access Token Expiry: \(currentUser.accessToken.expirationDate)")
                
                // Test storing tokens in keychain
                await testTokenStorageInKeychain(currentUser: currentUser)
            } else {
                print("❌ CalendarSyncManager: No current user found for token logging")
            }
            
            do {
                let googleEvents = try await googleProvider.fetchEvents(from: lookBack, to: lookAhead)
                allEvents.append(contentsOf: googleEvents)
                print("✅ CalendarSyncManager: Fetched \(googleEvents.count) Google events")
            } catch {
                print("❌ CalendarSyncManager: Google Calendar fetch failed: \(error)")
                handleError("Google Calendar fetch failed: \(error.localizedDescription)")
                
                // Attempt to refresh Google connection if unauthorized/forbidden
                if error.localizedDescription.contains("401") || error.localizedDescription.contains("403") {
                    print("🔄 CalendarSyncManager: Attempting to refresh Google connection...")
                    await forceRefreshGoogle()
                }
            }
        }
        
        // Process and update events
        let processedEvents = allEvents
            .mergedDeduping() // Assumes your existing extension uses stable IDs (provider+eventId)
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
        if useApple {
            await connectApple()
        }
        if useGoogle {
            await connectGoogle()
        }
    }
    
    /// Events overlapping a single day (overlap-aware).
    func getEventsForDate(_ date: Date) -> [CalendarEvent] {
        let interval = dayInterval(for: date)
        let start = interval.start
        let end   = interval.end
        
        print("📅 CalendarSyncManager: Looking for events on \(date)")
        print("   - Start of day: \(start)")
        print("   - End of day: \(end)")
        print("   - Total events available: \(events.count)")
        
        let filtered = events.filter { ev in
            let ok = overlaps(eventStart: ev.start, eventEnd: ev.end, rangeStart: start, rangeEnd: end)
            if ok {
                print("   ✅ Match '\(ev.title)' start=\(ev.start) end=\(String(describing: ev.end))")
            }
            return ok
        }
        print("📅 CalendarSyncManager: Found \(filtered.count) events for \(date)")
        return filtered.sorted { $0.start < $1.start }
    }
    
    /// Events overlapping the requested range (not just starting within it).
    func getEventsForDateRange(from start: Date, to end: Date) -> [CalendarEvent] {
        return events
            .filter { ev in overlaps(eventStart: ev.start, eventEnd: ev.end, rangeStart: start, rangeEnd: end) }
            .sorted { $0.start < $1.start }
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ message: String) {
        errorMessage = message
        print("CalendarSyncManager Error: \(message)")
    }
    
    private func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Keychain Token Storage Test
    private func testTokenStorageInKeychain(currentUser: GIDGoogleUser) async {
        print("🔐 CalendarSyncManager: Testing token storage in keychain...")
        
        guard let email = currentUser.profile?.email else {
            print("❌ CalendarSyncManager: No email available for keychain test")
            return
        }
        
        // Test 1: Store Access Token
        let accessTokenData = currentUser.accessToken.tokenString.data(using: .utf8)!
        let accessTokenQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.ashleychang.Monu-Planner.accessToken",
            kSecAttrAccount: email,
            kSecValueData: accessTokenData,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let accessTokenStatus = SecItemAdd(accessTokenQuery as CFDictionary, nil)
        print("   - Access Token storage status: \(accessTokenStatus)")
        
        if accessTokenStatus == errSecSuccess {
            print("✅ Access Token stored successfully")
        } else if accessTokenStatus == errSecDuplicateItem {
            print("⚠️ Access Token already exists, updating...")
            let updateQuery: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: "com.ashleychang.Monu-Planner.accessToken",
                kSecAttrAccount: email
            ]
            let updateAttributes: [CFString: Any] = [
                kSecValueData: accessTokenData
            ]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            print("   - Access Token update status: \(updateStatus)")
        } else {
            print("❌ Access Token storage failed: \(accessTokenStatus)")
        }
        
        // Test 2: Store Refresh Token
        let refreshTokenData = currentUser.refreshToken.tokenString.data(using: .utf8)!
        let refreshTokenQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.ashleychang.Monu-Planner.refreshToken",
            kSecAttrAccount: email,
            kSecValueData: refreshTokenData,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let refreshTokenStatus = SecItemAdd(refreshTokenQuery as CFDictionary, nil)
        print("   - Refresh Token storage status: \(refreshTokenStatus)")
        
        if refreshTokenStatus == errSecSuccess {
            print("✅ Refresh Token stored successfully")
        } else if refreshTokenStatus == errSecDuplicateItem {
            print("⚠️ Refresh Token already exists, updating...")
            let updateQuery: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: "com.ashleychang.Monu-Planner.refreshToken",
                kSecAttrAccount: email
            ]
            let updateAttributes: [CFString: Any] = [
                kSecValueData: refreshTokenData
            ]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            print("   - Refresh Token update status: \(updateStatus)")
        } else {
            print("❌ Refresh Token storage failed: \(refreshTokenStatus)")
        }
        
        // Test 3: Retrieve tokens from keychain
        await testTokenRetrievalFromKeychain(email: email)
    }
    
    private func testTokenRetrievalFromKeychain(email: String) async {
        print("🔐 CalendarSyncManager: Testing token retrieval from keychain...")
        
        // Retrieve Access Token
        let accessTokenQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.ashleychang.Monu-Planner.accessToken",
            kSecAttrAccount: email,
            kSecReturnData: true
        ]
        
        var accessTokenResult: AnyObject?
        let accessTokenRetrieveStatus = SecItemCopyMatching(accessTokenQuery as CFDictionary, &accessTokenResult)
        print("   - Access Token retrieval status: \(accessTokenRetrieveStatus)")
        
        if accessTokenRetrieveStatus == errSecSuccess,
           let accessTokenData = accessTokenResult as? Data,
           let accessTokenString = String(data: accessTokenData, encoding: .utf8) {
            print("✅ Access Token retrieved successfully")
            print("   - Retrieved Access Token: \(accessTokenString)")
        } else {
            print("❌ Access Token retrieval failed")
        }
        
        // Retrieve Refresh Token
        let refreshTokenQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.ashleychang.Monu-Planner.refreshToken",
            kSecAttrAccount: email,
            kSecReturnData: true
        ]
        
        var refreshTokenResult: AnyObject?
        let refreshTokenRetrieveStatus = SecItemCopyMatching(refreshTokenQuery as CFDictionary, &refreshTokenResult)
        print("   - Refresh Token retrieval status: \(refreshTokenRetrieveStatus)")
        
        if refreshTokenRetrieveStatus == errSecSuccess,
           let refreshTokenData = refreshTokenResult as? Data,
           let refreshTokenString = String(data: refreshTokenData, encoding: .utf8) {
            print("✅ Refresh Token retrieved successfully")
            print("   - Retrieved Refresh Token: \(refreshTokenString)")
        } else {
            print("❌ Refresh Token retrieval failed")
        }
    }
    
    private func cleanupTestTokens(email: String) async {
        print("🔐 CalendarSyncManager: Cleaning up test tokens...")
        
        let accessTokenDeleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.ashleychang.Monu-Planner.accessToken",
            kSecAttrAccount: email
        ]
        
        let refreshTokenDeleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.ashleychang.Monu-Planner.refreshToken",
            kSecAttrAccount: email
        ]
        
        let accessTokenDeleteStatus = SecItemDelete(accessTokenDeleteQuery as CFDictionary)
        let refreshTokenDeleteStatus = SecItemDelete(refreshTokenDeleteQuery as CFDictionary)
        
        print("   - Access Token cleanup status: \(accessTokenDeleteStatus)")
        print("   - Refresh Token cleanup status: \(refreshTokenDeleteStatus)")
        print("✅ Keychain token storage test completed")
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
