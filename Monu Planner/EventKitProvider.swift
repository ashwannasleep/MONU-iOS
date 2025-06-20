import Foundation
import EventKit

@MainActor
final class EventKitProvider: @preconcurrency CalendarProvider, ObservableObject {
    let eventStore = EKEventStore()
    private(set) var calendars: [EKCalendar] = []
    
    var source: Source { .apple }
    @Published private(set) var isConnected: Bool = false
    
    func requestAuthorization() async throws {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            let granted = try await eventStore.requestFullAccessToEvents()
            if granted {
                await setupCalendars()
            } else {
                throw CalendarError.permissionDenied
            }
            
        case .authorized, .fullAccess:
            await setupCalendars()
            
        case .restricted, .denied:
            throw CalendarError.permissionDenied
            
        case .writeOnly:
            let granted = try await eventStore.requestFullAccessToEvents()
            if granted {
                await setupCalendars()
            } else {
                throw CalendarError.permissionDenied
            }
            
        @unknown default:
            throw CalendarError.unknown
        }
    }
    
    private func setupCalendars() async {
        calendars = eventStore.calendars(for: .event).filter { $0.allowsContentModifications }
        isConnected = !calendars.isEmpty
        
        print("EventKit: Found \(calendars.count) writable calendars")
        for calendar in calendars {
            print("Calendar: \(calendar.title) - Source: \(calendar.source.title)")
        }
    }
    
    func disconnect() async {
        calendars.removeAll()
        isConnected = false
    }
    
    func fetchEvents(from start: Date, to end: Date) async throws -> [CalendarEvent] {
        guard isConnected && !calendars.isEmpty else {
            print("EventKit: Not connected or no calendars available")
            return []
        }
        
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let ekEvents = eventStore.events(matching: predicate)
        
        print("EventKit: Found \(ekEvents.count) events between \(start) and \(end)")
        
        return ekEvents.compactMap { ekEvent in
            guard let eventId = ekEvent.eventIdentifier else {
                print("EventKit: Event missing identifier: \(ekEvent.title ?? "Unknown")")
                return nil
            }
            
            return CalendarEvent(
                id: eventId,
                title: ekEvent.title ?? "Untitled",
                start: ekEvent.startDate,
                end: ekEvent.endDate,
                isAllDay: ekEvent.isAllDay,
                provider: .apple
            )
        }
    }
    
    func add(_ event: CalendarEvent) async throws {
        guard isConnected else {
            throw CalendarError.notConnected
        }
        
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents ?? calendars.first else {
            throw CalendarError.noCalendarAvailable
        }
        
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.calendar = defaultCalendar
        ekEvent.title = event.title
        ekEvent.startDate = event.start
        ekEvent.endDate = event.end
        ekEvent.isAllDay = event.isAllDay
        
        try eventStore.save(ekEvent, span: .thisEvent)
        print("EventKit: Successfully added event '\(event.title)' to calendar '\(defaultCalendar.title)'")
    }
    
    func update(_ event: CalendarEvent) async throws {
        guard isConnected else {
            throw CalendarError.notConnected
        }
        
        guard let ekEvent = eventStore.event(withIdentifier: event.id) else {
            print("EventKit: Event not found for update: \(event.id)")
            throw CalendarError.eventNotFound
        }
        
        ekEvent.title = event.title
        ekEvent.startDate = event.start
        ekEvent.endDate = event.end
        ekEvent.isAllDay = event.isAllDay
        
        try eventStore.save(ekEvent, span: .thisEvent)
        print("EventKit: Successfully updated event '\(event.title)'")
    }
    
    func delete(_ event: CalendarEvent) async throws {
        guard isConnected else {
            throw CalendarError.notConnected
        }
        
        guard let ekEvent = eventStore.event(withIdentifier: event.id) else {
            print("EventKit: Event not found for deletion: \(event.id)")
            throw CalendarError.eventNotFound
        }
        
        try eventStore.remove(ekEvent, span: .thisEvent)
        print("EventKit: Successfully deleted event '\(event.title)'")
    }
}

