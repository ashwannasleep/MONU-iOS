import Foundation

// MARK: - Unified event model
public struct CalendarEvent: Identifiable, Codable, Hashable {
    public let id: String           // provider-unique UID, e.g. "google:abc123"
    public var title: String
    public var start: Date
    public var end: Date
    public var isAllDay: Bool
    public var notes: String?       // event description/notes
    public var provider: Source     // who created / owns it

    public init(id: String = UUID().uuidString,
                title: String,
                start: Date,
                end: Date,
                isAllDay: Bool = false,
                notes: String? = nil,
                provider: Source) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.isAllDay = isAllDay
        self.notes = notes
        self.provider = provider
    }

    // Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(start.timeIntervalSince1970)
        hasher.combine(end.timeIntervalSince1970)
        hasher.combine(isAllDay)
        hasher.combine(notes)
        hasher.combine(provider)
    }

    public static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.start == rhs.start &&
               lhs.end == rhs.end &&
               lhs.isAllDay == rhs.isAllDay &&
               lhs.notes == rhs.notes &&
               lhs.provider == rhs.provider
    }
}

// MARK: - Supported calendar sources
public enum Source: String, CaseIterable, Codable {
    case apple  = "Apple Calendar"
    case google = "Google Calendar"
}

// MARK: - Provider contract
public protocol CalendarProvider: AnyObject {
    var source: Source { get }
    var isConnected: Bool { get }

    func requestAuthorization() async throws
    func disconnect() async

    func fetchEvents(from start: Date, to end: Date) async throws -> [CalendarEvent]
    func add(_ event: CalendarEvent) async throws
    func update(_ event: CalendarEvent) async throws
    func delete(_ event: CalendarEvent) async throws
}

// MARK: - Event dedupe helper
private struct EventKey: Hashable {
    let title: String
    let startTime: TimeInterval
    init(from event: CalendarEvent) {
        self.title = event.title
        self.startTime = event.start.timeIntervalSince1970
    }
}

public extension Array where Element == CalendarEvent {
    func mergedDeduping() -> [CalendarEvent] {
        let grouped = Dictionary(grouping: self) { EventKey(from: $0) }
        return grouped.compactMap { _, group in
            group.sorted(by: { $0.end > $1.end }).first
        }
    }
}

