// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "526144cea2d669660831d877683bfa96"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: BucketItem.self)
    ModelRegistry.register(modelType: YearlyGoal.self)
    ModelRegistry.register(modelType: DailyTask.self)
    ModelRegistry.register(modelType: Habit.self)
    ModelRegistry.register(modelType: FutureGoal.self)
    ModelRegistry.register(modelType: YearlyPopupTask.self)
    ModelRegistry.register(modelType: FocusTask.self)
    ModelRegistry.register(modelType: MonthlyEvent.self)
    ModelRegistry.register(modelType: GoogleAuth.self)
    ModelRegistry.register(modelType: UserSettings.self)
  }
}