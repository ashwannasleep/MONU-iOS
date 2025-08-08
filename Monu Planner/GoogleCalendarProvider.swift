import Foundation
import GoogleSignIn
import UIKit

@MainActor
final class GoogleCalendarProvider: NSObject, @preconcurrency CalendarProvider, ObservableObject {
    private let baseURL = "https://www.googleapis.com/calendar/v3"
    private let calendarScope = "https://www.googleapis.com/auth/calendar"
    
    var source: Source { .google }
    @Published private(set) var isConnected: Bool = false
    private var accessToken: String?
    
    // Local storage keys
    private let cachedEventsKey = "google_calendar_cached_events"
    private let lastSyncDateKey = "google_calendar_last_sync"
    private let cacheExpirationHours: TimeInterval = 24 * 60 * 60 // 24 hours

    override init() {
        super.init()
        Task {
            await checkExistingSignIn()
        }
    }

    private func checkExistingSignIn() async {
        print("🔍 Google Calendar: Checking existing sign-in...")
        
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("❌ Google Calendar: No current user found")
            await MainActor.run {
                isConnected = false
            }
            return
        }

        let hasCalendarScope = user.grantedScopes?.contains(calendarScope) ?? false
        print("🔍 Google Calendar: User found, calendar scope: \(hasCalendarScope)")

        await MainActor.run {
            isConnected = hasCalendarScope
        }

        if isConnected {
            accessToken = user.accessToken.tokenString
            print("✅ Google Calendar: Successfully restored connection")
        } else {
            print("❌ Google Calendar: User exists but no calendar scope")
        }
    }

    func requestAuthorization() async throws {
        print("🔐 Google Calendar: Starting authorization...")
        
        // Check if already connected
        if isConnected {
            print("✅ Google Calendar: Already connected, skipping authorization")
            return
        }
        
        // Check if user is already signed in but needs calendar scope
        if let user = GIDSignIn.sharedInstance.currentUser {
            let hasCalendarScope = user.grantedScopes?.contains(calendarScope) ?? false
            if hasCalendarScope {
                print("✅ Google Calendar: User already has calendar access")
                accessToken = user.accessToken.tokenString
                await MainActor.run {
                    isConnected = true
                }
                return
            } else {
                print("🔐 Google Calendar: User signed in but needs calendar scope")
            }
        }
        
        guard let presentingViewController = await getRootViewController() else {
            throw CalendarError.authorizationFailed("Could not find presenting view controller")
        }

        guard let clientID = getGoogleClientID() else {
            throw CalendarError.authorizationFailed("Google Client ID not found")
        }

        print("🔐 Google Calendar: Client ID found, configuring...")

        await MainActor.run {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        do {
            print("🔐 Google Calendar: Requesting sign-in with calendar scope...")
            
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: [calendarScope]
            )

            let user = result.user
            print("🔐 Google Calendar: Sign-in successful, checking scopes...")

            guard user.grantedScopes?.contains(calendarScope) == true else {
                print("❌ Google Calendar: Calendar access not granted")
                throw CalendarError.authorizationFailed("Calendar access not granted")
            }

            accessToken = user.accessToken.tokenString
            print("🔐 Google Calendar: Access token obtained")

            await MainActor.run {
                isConnected = true
            }

            print("✅ Google Calendar: Successfully connected with calendar access")

        } catch let error as GIDSignInError {
            print("❌ Google Calendar: Sign-in error: \(error.localizedDescription)")
            throw CalendarError.authorizationFailed("Google Sign-In failed: \(error.localizedDescription)")
        } catch {
            print("❌ Google Calendar: Unexpected error: \(error.localizedDescription)")
            throw CalendarError.authorizationFailed(error.localizedDescription)
        }
    }

    func disconnect() async {
        print("🔌 Google Calendar: Disconnecting...")
        
        await MainActor.run {
            GIDSignIn.sharedInstance.signOut()
        }

        accessToken = nil
        clearLocalCache() // Clear cached data when disconnecting

        await MainActor.run {
            isConnected = false
        }
        
        print("✅ Google Calendar: Disconnected successfully")
    }
    
    func forceRefreshCache() async throws -> [CalendarEvent] {
        print("🔄 Google Calendar: Force refreshing cache...")
        clearLocalCache()
        return try await fetchEvents(from: Date().addingTimeInterval(-30*24*60*60), to: Date().addingTimeInterval(30*24*60*60))
    }
    
    func fetchEventsForDateRange(from start: Date, to end: Date) async throws -> [CalendarEvent] {
        print("📅 Google Calendar: Fetching events for specific date range: \(start) to \(end)")
        clearLocalCache() // Clear cache to ensure fresh data
        
        // Use a more precise date range for specific queries
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: start)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? start
        
        return try await fetchEvents(from: startOfDay, to: endOfDay)
    }
    
    // MARK: - Local Storage Methods
    
    private func saveEventsToLocalStorage(_ events: [CalendarEvent]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(events)
            UserDefaults.standard.set(data, forKey: cachedEventsKey)
            UserDefaults.standard.set(Date(), forKey: lastSyncDateKey)
            print("💾 Google Calendar: Saved \(events.count) events to local storage")
        } catch {
            print("❌ Google Calendar: Failed to save events to local storage: \(error)")
        }
    }
    
    private func loadEventsFromLocalStorage() -> [CalendarEvent] {
        guard let data = UserDefaults.standard.data(forKey: cachedEventsKey) else {
            print("📱 Google Calendar: No cached events found")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let events = try decoder.decode([CalendarEvent].self, from: data)
            print("📱 Google Calendar: Loaded \(events.count) events from local storage")
            return events
        } catch {
            print("❌ Google Calendar: Failed to load events from local storage: \(error)")
            return []
        }
    }
    
    private func isCacheValid() -> Bool {
        guard let lastSync = UserDefaults.standard.object(forKey: lastSyncDateKey) as? Date else {
            return false
        }
        
        let timeSinceLastSync = Date().timeIntervalSince(lastSync)
        let isValid = timeSinceLastSync < cacheExpirationHours
        
        print("⏰ Google Calendar: Cache valid: \(isValid), last sync: \(timeSinceLastSync / 3600) hours ago")
        return isValid
    }
    
    private func clearLocalCache() {
        UserDefaults.standard.removeObject(forKey: cachedEventsKey)
        UserDefaults.standard.removeObject(forKey: lastSyncDateKey)
        print("🗑️ Google Calendar: Cleared local cache")
    }

    private func getGoogleClientID() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("❌ Google Calendar: Could not find GoogleService-Info.plist or CLIENT_ID")
            return nil
        }
        print("✅ Google Calendar: Client ID found")
        return clientId
    }

    private func getRootViewController() async -> UIViewController? {
        await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                print("❌ Google Calendar: Could not find root view controller")
                return nil
            }
            return window.rootViewController
        }
    }

    private func refreshTokenIfNeeded() async throws {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("❌ Google Calendar: No current user for token refresh")
            throw CalendarError.notConnected
        }

        if let expirationDate = user.accessToken.expirationDate {
            let timeUntilExpiration = expirationDate.timeIntervalSinceNow
            print("🔍 Google Calendar: Token expires in \(timeUntilExpiration) seconds")
            
            if timeUntilExpiration < 300 { // Refresh if expires in less than 5 minutes
                print("🔄 Google Calendar: Refreshing token...")
                try await user.refreshTokensIfNeeded()
                accessToken = user.accessToken.tokenString
                print("✅ Google Calendar: Token refreshed successfully")
            } else {
                print("✅ Google Calendar: Token is still valid")
            }
        } else {
            print("⚠️ Google Calendar: No expiration date for token")
        }
    }

    func fetchEvents(from start: Date, to end: Date) async throws -> [CalendarEvent] {
        print("📅 Google Calendar: Fetching events from \(start) to \(end)")
        
        // Always fetch fresh data for specific date ranges to ensure accuracy
        // Only use cache for general browsing, not for specific date queries
        
        guard isConnected else {
            print("❌ Google Calendar: Not connected")
            throw CalendarError.notConnected
        }

        try await refreshTokenIfNeeded()

        guard let accessToken = accessToken else {
            print("❌ Google Calendar: No access token")
            throw CalendarError.notConnected
        }

        let formatter = ISO8601DateFormatter()
        let startISO = formatter.string(from: start)
        let endISO = formatter.string(from: end)

        guard let encodedStart = startISO.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedEnd = endISO.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Google Calendar: Failed to encode dates")
            throw CalendarError.invalidRequest
        }

        let urlString = "\(baseURL)/calendars/primary/events?timeMin=\(encodedStart)&timeMax=\(encodedEnd)&singleEvents=true&orderBy=startTime&maxResults=2500&showDeleted=false"

        guard let url = URL(string: urlString) else {
            print("❌ Google Calendar: Invalid URL")
            throw CalendarError.invalidRequest
        }

        print("🌐 Google Calendar: Making request to \(urlString)")

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Google Calendar: Invalid response type")
                throw CalendarError.networkError("Invalid response")
            }

            print("📡 Google Calendar: Response status: \(httpResponse.statusCode)")

            guard httpResponse.statusCode < 300 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Google Calendar: HTTP \(httpResponse.statusCode): \(errorMessage)")
                throw CalendarError.networkError("HTTP \(httpResponse.statusCode): \(errorMessage)")
            }

            let events = try parseEvents(from: data)
            print("✅ Google Calendar: Successfully fetched \(events.count) events")
            
            // Save events to local storage for future use
            saveEventsToLocalStorage(events)
            
            return events
            
        } catch {
            print("❌ Google Calendar: Network error: \(error.localizedDescription)")
            throw CalendarError.networkError("Network error: \(error.localizedDescription)")
        }
    }

    func add(_ event: CalendarEvent) async throws {
        guard isConnected else {
            throw CalendarError.notConnected
        }

        try await refreshTokenIfNeeded()

        guard let accessToken = accessToken else {
            throw CalendarError.notConnected
        }

        guard let url = URL(string: "\(baseURL)/calendars/primary/events") else {
            throw CalendarError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0

        let eventData = try createEventJSON(from: event)
        request.httpBody = eventData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode < 300 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw CalendarError.networkError("Failed to create event: \(errorMessage)")
        }

        print("Google Calendar: Successfully added event '\(event.title)'")
    }

    func update(_ event: CalendarEvent) async throws {
        guard isConnected else {
            throw CalendarError.notConnected
        }

        try await refreshTokenIfNeeded()

        guard let accessToken = accessToken else {
            throw CalendarError.notConnected
        }

        let eventId = event.id

        guard let url = URL(string: "\(baseURL)/calendars/primary/events/\(eventId)") else {
            throw CalendarError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0

        let eventData = try createEventJSON(from: event)
        request.httpBody = eventData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode < 300 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw CalendarError.networkError("Failed to update event: \(errorMessage)")
        }

        print("Google Calendar: Successfully updated event '\(event.title)'")
    }

    func delete(_ event: CalendarEvent) async throws {
        guard isConnected else {
            throw CalendarError.notConnected
        }

        try await refreshTokenIfNeeded()

        guard let accessToken = accessToken else {
            throw CalendarError.notConnected
        }

        let eventId = event.id

        guard let url = URL(string: "\(baseURL)/calendars/primary/events/\(eventId)") else {
            throw CalendarError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30.0

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode < 300 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw CalendarError.networkError("Failed to delete event: \(errorMessage)")
        }

        print("Google Calendar: Successfully deleted event '\(event.title)'")
    }

    private func parseEvents(from data: Data) throws -> [CalendarEvent] {
        struct GoogleCalendarResponse: Codable {
            let items: [GoogleCalendarEvent]?
        }

        struct GoogleCalendarEvent: Codable {
            let id: String
            let summary: String?
            let start: GoogleDateTime
            let end: GoogleDateTime
            let description: String?
            let location: String?

            struct GoogleDateTime: Codable {
                let dateTime: String?
                let date: String?
                let timeZone: String?
            }
        }

        let response = try JSONDecoder().decode(GoogleCalendarResponse.self, from: data)

        // ISO8601 formatter for dateTime strings
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current

        let events = response.items?.compactMap { item -> CalendarEvent? in
            guard let title = item.summary else { 
                print("⚠️ Google Calendar: Event without summary, skipping")
                return nil 
            }

            let startDate: Date
            let endDate: Date
            let isAllDay: Bool

            if let dateTime = item.start.dateTime {
                // Respect timezone if provided and string lacks explicit offset
                if let tzId = item.start.timeZone, let tz = TimeZone(identifier: tzId) {
                    isoFormatter.timeZone = tz
                } else {
                    isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                }
                if let parsedDate = isoFormatter.date(from: dateTime) {
                    startDate = parsedDate
                    isAllDay = false
                    print("📅 Google Calendar: Parsed datetime event '\(title)' at \(startDate) (src: \(dateTime))")
                } else {
                    print("⚠️ Google Calendar: Failed to parse datetime: \(dateTime)")
                    startDate = Date()
                    isAllDay = false
                }
            } else if let date = item.start.date {
                // For all-day events, use the date as-is
                if let parsedDate = dateFormatter.date(from: date) {
                    startDate = parsedDate
                    isAllDay = true
                    print("📅 Google Calendar: Parsed all-day event '\(title)' on \(startDate)")
                } else {
                    print("⚠️ Google Calendar: Failed to parse date: \(date)")
                    startDate = Date()
                    isAllDay = true
                }
            } else {
                print("⚠️ Google Calendar: Event without start date, skipping")
                return nil
            }
            
            // Debug: Print the final parsed date for verification
            let debugFormatter = DateFormatter()
            debugFormatter.dateStyle = .medium
            debugFormatter.timeStyle = .short
            print("📅 Google Calendar: Final event '\(title)' scheduled for: \(debugFormatter.string(from: startDate))")

            if let dateTime = item.end.dateTime {
                if let tzId = item.end.timeZone, let tz = TimeZone(identifier: tzId) {
                    isoFormatter.timeZone = tz
                }
                if let parsedDate = isoFormatter.date(from: dateTime) {
                    endDate = parsedDate
                } else {
                    endDate = startDate.addingTimeInterval(3600)
                }
            } else if let date = item.end.date {
                if let parsedDate = dateFormatter.date(from: date) {
                    endDate = parsedDate
                } else {
                    endDate = startDate.addingTimeInterval(86400)
                }
            } else {
                endDate = startDate.addingTimeInterval(isAllDay ? 86400 : 3600)
            }

            return CalendarEvent(
                id: item.id,
                title: title,
                start: startDate,
                end: endDate,
                isAllDay: isAllDay,
                provider: .google
            )
        } ?? []
        
        print("📊 Google Calendar: Parsed \(events.count) events")
        return events
    }

    private func createEventJSON(from event: CalendarEvent) throws -> Data {
        let formatter = ISO8601DateFormatter()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current

        var eventDict: [String: Any] = [
            "summary": event.title
        ]

        if event.isAllDay {
            eventDict["start"] = ["date": dateFormatter.string(from: event.start)]
            eventDict["end"] = ["date": dateFormatter.string(from: event.end)]
        } else {
            eventDict["start"] = [
                "dateTime": formatter.string(from: event.start),
                "timeZone": TimeZone.current.identifier
            ]
            eventDict["end"] = [
                "dateTime": formatter.string(from: event.end),
                "timeZone": TimeZone.current.identifier
            ]
        }

        return try JSONSerialization.data(withJSONObject: eventDict, options: [])
    }

    // MARK: - Additional Helper Methods
    
    func forceRefreshConnection() async {
        print("🔄 Google Calendar: Force refreshing connection...")
        
        // Clear current state
        await MainActor.run {
            isConnected = false
        }
        accessToken = nil
        
        // Check existing sign-in
        await checkExistingSignIn()
        
        if !isConnected {
            print("🔄 Google Calendar: No existing connection, attempting new authorization...")
            do {
                try await requestAuthorization()
            } catch {
                print("❌ Google Calendar: Force refresh failed: \(error.localizedDescription)")
            }
        }
    }
    
    func getConnectionStatus() -> String {
        if isConnected {
            return "Connected"
        } else if GIDSignIn.sharedInstance.currentUser != nil {
            return "User signed in but no calendar access"
        } else {
            return "Not connected"
        }
    }
    
    func getDebugInfo() -> [String: String] {
        let user = GIDSignIn.sharedInstance.currentUser
        return [
            "isConnected": "\(isConnected)",
            "hasUser": "\(user != nil)",
            "hasToken": "\(accessToken != nil)",
            "grantedScopes": "\(user?.grantedScopes?.joined(separator: ", ") ?? "none")",
            "tokenExpiration": "\(user?.accessToken.expirationDate?.description ?? "unknown")"
        ]
    }
}

// MARK: - Calendar Error Extension
extension CalendarError {
    static func authorizationFailed(_ message: String) -> CalendarError {
        return .networkError("Authorization failed: \(message)")
    }

    static var invalidRequest: CalendarError {
        return .networkError("Invalid request")
    }
}
