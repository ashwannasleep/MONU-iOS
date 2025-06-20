// swiftlint:disable all
import Amplify
import Foundation

extension DailyTask {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case date
    case text
    case time
    case duration
    case order
    case done
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let dailyTask = DailyTask.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "DailyTasks"
    model.syncPluralName = "DailyTasks"
    
    model.attributes(
      .primaryKey(fields: [dailyTask.id])
    )
    
    model.fields(
      .field(dailyTask.id, is: .required, ofType: .string),
      .field(dailyTask.date, is: .required, ofType: .date),
      .field(dailyTask.text, is: .required, ofType: .string),
      .field(dailyTask.time, is: .optional, ofType: .string),
      .field(dailyTask.duration, is: .optional, ofType: .string),
      .field(dailyTask.order, is: .optional, ofType: .int),
      .field(dailyTask.done, is: .optional, ofType: .bool),
      .field(dailyTask.owner, is: .optional, ofType: .string),
      .field(dailyTask.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(dailyTask.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension DailyTask: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}