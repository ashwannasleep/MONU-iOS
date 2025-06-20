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

    override init() {
        super.init()
        Task {
            await checkExistingSignIn()
        }
    }

    private func checkExistingSignIn() async {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            await MainActor.run {
                isConnected = false
            }
            return
        }

        let hasCalendarScope = user.grantedScopes?.contains(calendarScope) ?? false

        await MainActor.run {
            isConnected = hasCalendarScope
        }

        if isConnected {
            accessToken = user.accessToken.tokenString
        }
    }

    func requestAuthorization() async throws {
        print("Google Calendar: Starting real Google Sign-In...")
        
        guard let presentingViewController = await getRootViewController() else {
            throw CalendarError.authorizationFailed("Could not find presenting view controller")
        }

        guard let clientID = getGoogleClientID() else {
            throw CalendarError.authorizationFailed("Google Client ID not found")
        }

        await MainActor.run {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: [calendarScope]
            )

            let user = result.user

            guard user.grantedScopes?.contains(calendarScope) == true else {
                throw CalendarError.authorizationFailed("Calendar access not granted")
            }

            accessToken = user.accessToken.tokenString

            await MainActor.run {
                isConnected = true
            }

            print("Google Calendar: Successfully connected with real authentication")

        } catch let error as GIDSignInError {
            throw CalendarError.authorizationFailed("Google Sign-In failed: \(error.localizedDescription)")
        } catch {
            throw CalendarError.authorizationFailed(error.localizedDescription)
        }
    }

    func disconnect() async {
        await MainActor.run {
            GIDSignIn.sharedInstance.signOut()
        }

        accessToken = nil

        await MainActor.run {
            isConnected = false
        }
    }

    private func getGoogleClientID() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            return nil
        }
        return clientId
    }

    private func getRootViewController() async -> UIViewController? {
        await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return nil
            }
            return window.rootViewController
        }
    }

    private func refreshTokenIfNeeded() async throws {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            throw CalendarError.notConnected
        }

        if let expirationDate = user.accessToken.expirationDate,
           expirationDate.timeIntervalSinceNow < 300 {
            try await user.refreshTokensIfNeeded()
            accessToken = user.accessToken.tokenString
            print("Google Calendar: Token refreshed successfully")
        }
    }

    func fetchEvents(from start: Date, to end: Date) async throws -> [CalendarEvent] {
        guard isConnected else {
            throw CalendarError.notConnected
        }

        try await refreshTokenIfNeeded()

        guard let accessToken = accessToken else {
            throw CalendarError.notConnected
        }

        let formatter = ISO8601DateFormatter()
        let startISO = formatter.string(from: start)
        let endISO = formatter.string(from: end)

        guard let encodedStart = startISO.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedEnd = endISO.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw CalendarError.invalidRequest
        }

        let urlString = "\(baseURL)/calendars/primary/events?timeMin=\(encodedStart)&timeMax=\(encodedEnd)&singleEvents=true&orderBy=startTime"

        guard let url = URL(string: urlString) else {
            throw CalendarError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CalendarError.networkError("Invalid response")
        }

        guard httpResponse.statusCode < 300 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw CalendarError.networkError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }

        return try parseEvents(from: data)
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

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current

        return response.items?.compactMap { item in
            guard let title = item.summary else { return nil }

            let startDate: Date
            let endDate: Date
            let isAllDay: Bool

            if let dateTime = item.start.dateTime {
                startDate = formatter.date(from: dateTime) ?? Date()
                isAllDay = false
            } else if let date = item.start.date {
                startDate = dateFormatter.date(from: date) ?? Date()
                isAllDay = true
            } else {
                return nil
            }

            if let dateTime = item.end.dateTime {
                endDate = formatter.date(from: dateTime) ?? startDate.addingTimeInterval(3600)
            } else if let date = item.end.date {
                endDate = dateFormatter.date(from: date) ?? startDate.addingTimeInterval(86400)
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
