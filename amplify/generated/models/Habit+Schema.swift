// swiftlint:disable all
import Amplify
import Foundation

extension Habit {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case icon
    case mood
    case days
    case description
    case time
    case plan
    case log
    case color
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let habit = Habit.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Habits"
    model.syncPluralName = "Habits"
    
    model.attributes(
      .primaryKey(fields: [habit.id])
    )
    
    model.fields(
      .field(habit.id, is: .required, ofType: .string),
      .field(habit.name, is: .required, ofType: .string),
      .field(habit.icon, is: .optional, ofType: .string),
      .field(habit.mood, is: .optional, ofType: .string),
      .field(habit.days, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(habit.description, is: .optional, ofType: .string),
      .field(habit.time, is: .optional, ofType: .string),
      .field(habit.plan, is: .optional, ofType: .string),
      .field(habit.log, is: .optional, ofType: .string),
      .field(habit.color, is: .optional, ofType: .string),
      .field(habit.owner, is: .optional, ofType: .string),
      .field(habit.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(habit.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Habit: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}