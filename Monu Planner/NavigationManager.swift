import SwiftUI
import Foundation

enum NavigationDestination: Hashable {
    case landing
    case choose
    case dashboard
    case yearlyOverview
    case monthlyPlanner
    case dailyPlan
    case habitTracker
    case futureVision
    case bucketList
    case pomodoro
    case settings
}

struct NavigationContainer {
    struct NavigationTypes {
        enum NavigationDestination: Hashable {
            case landing
            case choose
            case dashboard
            case yearlyOverview
            case monthlyPlanner
            case dailyPlan
            case habitTracker
            case futureVision
            case bucketList
            case pomodoro
            case settings
        }
    }

    class NavigationManager: ObservableObject {
        @Published var navigationPath: [NavigationTypes.NavigationDestination] = []

        // Push to a new page
        func navigate(to destination: NavigationTypes.NavigationDestination) {
            navigationPath.append(destination)
        }

        // Go back one step
        func goBack() {
            _ = navigationPath.popLast()
        }

        // Clear stack and return to choose page
        func navigateToRoot() {
            navigationPath = [.choose]
        }

        func goToChoosePage() {
            navigationPath = [.choose]
        }
    }
}
