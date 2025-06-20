import Foundation

enum CalendarError: Error, LocalizedError {
    case permissionDenied
    case notConnected
    case eventNotFound
    case networkError(String)
    case unknown
    case noCalendarAvailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission was denied for accessing the calendar."
        case .notConnected:
            return "Not connected to the calendar."
        case .eventNotFound:
            return "The event could not be found."
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown:
            return "An unknown error occurred."
        case .noCalendarAvailable:
            return "No writable calendar is available."
        }
    }
}
