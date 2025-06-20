import Foundation
import Combine

/// Unified event model (kept from your original file, moved here for reuse)
public struct CalendarEvent: Identifiable, Codable, Hashable {
    public let id: String           // provider-unique UID
    public var title: String
    public var start: Date
    public var end: Date
    public var isAllDay: Bool
    public var provider: Source     // who created / owns it
    
    public init(id: String = UUID().uuidString,
                title: String,
                start: Date,
                end: Date,
                isAllDay: Bool = false,
                provider: Source) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.isAllDay = isAllDay
        self.provider = provider
    }
    
    // Custom Hashable implementation
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(start.timeIntervalSince1970)
        hasher.combine(end.timeIntervalSince1970)
        hasher.combine(isAllDay)
        hasher.combine(provider)
    }
    
    public static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.start == rhs.start &&
               lhs.end == rhs.end &&
               lhs.isAllDay == rhs.isAllDay &&
               lhs.provider == rhs.provider
    }
}

/// Supported calendar sources
public enum Source: String, CaseIterable, Codable {
    case apple      = "Apple Calendar"
    case google     = "Google Calendar"
}

/// Contract every provider must fulfil
protocol CalendarProvider {
    var source: Source { get }
    var isConnected: Bool { get }
    
    func requestAuthorization() async throws
    func disconnect() async                 // revoke or forget tokens

    func fetchEvents(from start: Date, to end: Date) async throws -> [CalendarEvent]
    func add(_ event: CalendarEvent) async throws
    func update(_ event: CalendarEvent) async throws
    func delete(_ event: CalendarEvent) async throws
}

/// Helper struct for event deduplication
private struct EventKey: Hashable {
    let title: String
    let startTime: TimeInterval
    
    init(from event: CalendarEvent) {
        self.title = event.title
        self.startTime = event.start.timeIntervalSince1970
    }
}

/// Simple merge that keeps latest-modified copy when duplicates exist
extension Array where Element == CalendarEvent {
    func mergedDeduping() -> [CalendarEvent] {
        let grouped = Dictionary(grouping: self) { event in
            EventKey(from: event)
        }
        
        return grouped.compactMap { _, events in
            // Return the event with the latest end time (most recently modified)
            events.sorted(by: { $0.end > $1.end }).first
        }
    }
}

