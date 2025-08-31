import Foundation
import GoogleSignIn
import UIKit

@MainActor
final class GoogleCalendarProvider: NSObject, @preconcurrency CalendarProvider, ObservableObject {

    // MARK: - Constants
    private let baseURL = "https://www.googleapis.com/calendar/v3"
    // Use least-privilege unless you truly need full calendar control:
    // "https://www.googleapis.com/auth/calendar.events"
    private let calendarScope = "https://www.googleapis.com/auth/calendar"

    // MARK: - Protocol conformance
    let source: Source = .google
    @Published private(set) var isConnected: Bool = false

    // MARK: - State
    private var accessToken: String?
    private var currentAppUserEmail: String?

    // Initial restore gate
    private var didFinishInitialRestore = false
    private var initContinuation: CheckedContinuation<Void, Never>?

    // MARK: - Init
    override init() {
        super.init()
        Task { @MainActor in
            configureIfNeeded()              // 1) configure GID
            await restorePreviousSignIn()    // 2) silently restore
            await reflectCurrentUserState()  // 3) update flags from currentUser
            didFinishInitialRestore = true
            initContinuation?.resume()
            initContinuation = nil
        }
    }

    // Call this from the manager before checking isConnected during app start
    func waitForInitialRestore() async {
        if didFinishInitialRestore { return }
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            self.initContinuation = cont
        }
    }

    // MARK: - Public API
    func setCurrentAppUser(_ email: String?) async {
        currentAppUserEmail = email
        if let appEmail = email,
           let googleEmail = GIDSignIn.sharedInstance.currentUser?.profile?.email,
           googleEmail != appEmail {
            self.isConnected = false
            self.accessToken = nil
        }
    }

    func requestAuthorization() async throws {
        configureIfNeeded()
        
        if GIDSignIn.sharedInstance.currentUser == nil {
            await restorePreviousSignIn()
        }
        
        print(GIDSignIn.sharedInstance.currentUser)

        // Reuse existing session if scoped and not mismatched
        if let user = GIDSignIn.sharedInstance.currentUser {
            if let appEmail = currentAppUserEmail,
               let googleEmail = user.profile?.email,
               googleEmail != appEmail {
                GIDSignIn.sharedInstance.signOut()
            } else if user.grantedScopes?.contains(calendarScope) == true {
                try await user.refreshTokensIfNeeded()
                accessToken = user.accessToken.tokenString
                isConnected = true
                return
            }
        }

        guard let presenting = await getRootViewController() else {
            throw CalendarError.networkError("Authorization failed: no presenting view controller")
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presenting,
            hint: nil,
            additionalScopes: [calendarScope]
        )
        let user = result.user

        guard user.grantedScopes?.contains(calendarScope) == true else {
            throw CalendarError.networkError("Authorization failed: calendar scope not granted")
        }

        if let appEmail = currentAppUserEmail,
           let googleEmail = user.profile?.email,
           googleEmail != appEmail {
            GIDSignIn.sharedInstance.signOut()
            throw CalendarError.networkError("Authorization failed: Google account doesn't match app user")
        }

        accessToken = user.accessToken.tokenString
        isConnected = true
    }

    func disconnect() async {
        GIDSignIn.sharedInstance.signOut()
        accessToken = nil
        isConnected = false
    }

    @discardableResult
    func forceRefreshCache() async throws -> Bool {
        if let user = GIDSignIn.sharedInstance.currentUser {
            try await user.refreshTokensIfNeeded()
            accessToken = user.accessToken.tokenString
            isConnected = user.grantedScopes?.contains(calendarScope) ?? false
            return true
        }
        // Try restore; if not, fall back to auth
        await restorePreviousSignIn()
        if isConnected { return true }
        try await requestAuthorization()
        return isConnected
    }

    // MARK: - Fetch / CRUD
    func fetchEvents(from start: Date, to end: Date) async throws -> [CalendarEvent] {
        guard isConnected else { throw CalendarError.notConnected }
        try await refreshTokenIfNeeded()

        let url = try buildEventsURL(timeMin: toRFC3339Local(start), timeMax: toRFC3339Local(end))
        let data = try await authedJSON(method: "GET", url: url, body: nil)

        struct GEventsResponse: Decodable { let items: [GEvent] }
        let decoded = try JSONDecoder().decode(GEventsResponse.self, from: data)

        return decoded.items
            .compactMap { self.mapToCalendarEvent($0) }
            .sorted { $0.start < $1.start }
    }

    func fetchEventsForDateRange(from start: Date, to end: Date) async throws -> [CalendarEvent] {
        try await fetchEvents(from: start, to: end)
    }

    func add(_ event: CalendarEvent) async throws {
        guard isConnected else { throw CalendarError.notConnected }
        try await refreshTokenIfNeeded()

        let url = try buildInsertURL()
        let body = try makeEventBody(from: event)
        let data = try await authedJSON(method: "POST", url: url, body: body)

        // Capture created Google event id for future updates/deletes
        struct GEventCreated: Decodable { let id: String }
        if let created = try? JSONDecoder().decode(GEventCreated.self, from: data) {
            // TODO: persist mapping from your local model -> created.id
            print("Created Google event id: \(created.id)")
        }
    }

    func update(_ event: CalendarEvent) async throws {
        guard isConnected else { throw CalendarError.notConnected }
        try await refreshTokenIfNeeded()

        let url = try buildEventURL(eventId: event.id) // event.id should be the Google id
        let body = try makeEventBody(from: event)
        _ = try await authedJSON(method: "PATCH", url: url, body: body)
    }

    func delete(_ event: CalendarEvent) async throws {
        guard isConnected else { throw CalendarError.notConnected }
        try await refreshTokenIfNeeded()

        let url = try buildEventURL(eventId: event.id)
        _ = try await authedJSON(method: "DELETE", url: url, body: nil)
    }

    // MARK: - Session restore/check
    private func restorePreviousSignIn() async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            // (Optional) Helpful log before restore:
            let hadPrev = GIDSignIn.sharedInstance.hasPreviousSignIn()
            print("🔎 hasPreviousSignIn BEFORE restore: \(hadPrev)")

            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                defer { cont.resume() }

                if let err = error as NSError? {
                    print("❌ restorePreviousSignIn error: \(err.domain) code=\(err.code) \(err.localizedDescription)")
                    self.accessToken = nil
                    self.isConnected = false
                    return
                }

                guard let user = user else {
                    print("ℹ️ No stored session to restore")
                    self.accessToken = nil
                    self.isConnected = false
                    return
                }

                // Optional app-user/email isolation
                if let appEmail = self.currentAppUserEmail,
                   let googleEmail = user.profile?.email,
                   googleEmail != appEmail {
                    print("⚠️ Email mismatch on restore (app=\(appEmail), google=\(googleEmail))")
                    self.accessToken = nil
                    self.isConnected = false
                    return
                }

                self.accessToken = user.accessToken.tokenString
                self.isConnected = user.grantedScopes?.contains(self.calendarScope) ?? false
                print("✅ Restored user: \(user.profile?.email ?? "unknown"), has calendar scope: \(self.isConnected)")
            }
        }
    }

    private func reflectCurrentUserState() async {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            isConnected = false
            return
        }
        if let appEmail = currentAppUserEmail,
           let googleEmail = user.profile?.email,
           googleEmail != appEmail {
            await disconnect()
            return
        }
        accessToken = user.accessToken.tokenString
        isConnected = user.grantedScopes?.contains(calendarScope) ?? false
    }

    // MARK: - Token
    private func refreshTokenIfNeeded() async throws {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            throw CalendarError.notConnected
        }
        try await user.refreshTokensIfNeeded()
        accessToken = user.accessToken.tokenString
    }

    // MARK: - Configuration / helpers
    private func configureIfNeeded() {
        print("check in configuration")
        print(GIDSignIn.sharedInstance.configuration)
        if GIDSignIn.sharedInstance.configuration == nil,
           let clientID = getGoogleClientID() {
            print("configuration client ID: \(clientID)")
            // NOTE: clientID only. Do NOT set serverClientID unless you do backend code exchange.
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
    }

    private func getGoogleClientID() -> String? {
        guard let path = Bundle.main.path(forResource: "Monu-Planner-info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else { return nil }
        return clientId
    }

    // Find a reliable presenter (even through nav/tab/presented stacks)
    private func topViewController(base: UIViewController? = UIApplication.shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController { return topViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController { return topViewController(base: tab.selectedViewController) }
        if let presented = base?.presentedViewController { return topViewController(base: presented) }
        return base
    }

    private func getRootViewController() async -> UIViewController? {
        await MainActor.run { topViewController() }
    }

    // MARK: - HTTP
    private func authedJSON(method: String, url: URL, body: [String: Any]?) async throws -> Data {
        guard let token = accessToken else { throw CalendarError.notConnected }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        }
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, http.statusCode >= 300 {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            throw CalendarError.networkError("HTTP \(http.statusCode): \(msg)")
        }
        return data
    }

    private func buildEventsURL(timeMin: String, timeMax: String) throws -> URL {
        var comps = URLComponents(string: "\(baseURL)/calendars/primary/events")!
        comps.queryItems = [
            URLQueryItem(name: "timeMin", value: timeMin),
            URLQueryItem(name: "timeMax", value: timeMax),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
            URLQueryItem(name: "maxResults", value: "2500"),
            URLQueryItem(name: "showDeleted", value: "false")
        ]
        guard let url = comps.url else { throw URLError(.badURL) }
        return url
    }

    private func buildInsertURL() throws -> URL {
        guard let url = URL(string: "\(baseURL)/calendars/primary/events") else { throw URLError(.badURL) }
        return url
    }

    private func buildEventURL(eventId: String) throws -> URL {
        // URL-encode event id to be safe
        let safe = eventId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? eventId
        guard let url = URL(string: "\(baseURL)/calendars/primary/events/\(safe)") else { throw URLError(.badURL) }
        return url
    }

    // MARK: - Mapping / bodies

    private struct GEvent: Decodable {
        struct GDate: Decodable {
            let dateTime: String?
            let date: String?
            let timeZone: String?
        }
        let id: String
        let summary: String?
        let start: GDate
        let end: GDate?
    }

    private enum RFC3339 {
        static let withFrac: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            f.timeZone = TimeZone(secondsFromGMT: 0)
            return f
        }()
        static let noFrac: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime]
            f.timeZone = TimeZone(secondsFromGMT: 0)
            return f
        }()
        static func parse(_ s: String) -> Date? {
            if let d = withFrac.date(from: s) { return d }
            return noFrac.date(from: s)
        }
    }

    /// yyyy-MM-dd in UTC for all-day values (Google uses exclusive end for all-day)
    private let ymdUTC: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    private func toRFC3339Local(_ date: Date) -> String {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return df.string(from: date)
    }

    private func mapToCalendarEvent(_ g: GEvent) -> CalendarEvent? {
        guard let sParsed = parseEventDate(g.start) else { return nil }
        var start = sParsed.date
        var isAllDay = sParsed.isAllDay

        var end: Date
        if let ge = g.end, let eParsed = parseEventDate(ge) {
            end = eParsed.date
            isAllDay = isAllDay || eParsed.isAllDay
        } else {
            end = start
        }

        if isAllDay {
            var cal = Calendar.current
            cal.timeZone = .current
            let sLocal = cal.startOfDay(for: start)
            let eLocal = cal.date(byAdding: .day, value: 1, to: sLocal)!
            start = sLocal
            end = eLocal
        }

        let title = (g.summary?.isEmpty == false) ? g.summary! : "(No title)"
        return CalendarEvent(
            id: g.id,
            title: title,
            start: start,
            end: end,
            isAllDay: isAllDay,
            provider: .google
        )
    }

    private func parseEventDate(_ d: GEvent.GDate) -> (date: Date, isAllDay: Bool)? {
        if let dt = d.dateTime, let parsed = RFC3339.parse(dt) {
            return (parsed, false)
        }
        if let day = d.date, let parsed = ymdUTC.date(from: day) {
            return (parsed, true)
        }
        return nil
    }

    private func makeEventBody(from ev: CalendarEvent) throws -> [String: Any] {
        if ev.isAllDay {
            let startDay = ymdUTC.string(from: ev.start)
            let endDay   = ymdUTC.string(from: ev.end) // exclusive end (next day) expected
            return [
                "summary": ev.title,
                "start": ["date": startDay],
                "end":   ["date": endDay]
            ]
        } else {
            return [
                "summary": ev.title,
                "start": ["dateTime": toRFC3339Local(ev.start), "timeZone": TimeZone.current.identifier],
                "end":   ["dateTime": toRFC3339Local(ev.end),   "timeZone": TimeZone.current.identifier]
            ]
        }
    }
}
