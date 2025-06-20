// swiftlint:disable all
import Amplify
import Foundation

extension FutureGoal {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case category
    case title
    case done
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let futureGoal = FutureGoal.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "FutureGoals"
    model.syncPluralName = "FutureGoals"
    
    model.attributes(
      .primaryKey(fields: [futureGoal.id])
    )
    
    model.fields(
      .field(futureGoal.id, is: .required, ofType: .string),
      .field(futureGoal.category, is: .required, ofType: .string),
      .field(futureGoal.title, is: .required, ofType: .string),
      .field(futureGoal.done, is: .optional, ofType: .bool),
      .field(futureGoal.owner, is: .optional, ofType: .string),
      .field(futureGoal.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(futureGoal.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension FutureGoal: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}