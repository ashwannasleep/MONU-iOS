// swiftlint:disable all
import Amplify
import Foundation

extension YearlyGoal {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case year
    case title
    case details
    case order
    case done
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let yearlyGoal = YearlyGoal.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "YearlyGoals"
    model.syncPluralName = "YearlyGoals"
    
    model.attributes(
      .primaryKey(fields: [yearlyGoal.id])
    )
    
    model.fields(
      .field(yearlyGoal.id, is: .required, ofType: .string),
      .field(yearlyGoal.year, is: .required, ofType: .int),
      .field(yearlyGoal.title, is: .required, ofType: .string),
      .field(yearlyGoal.details, is: .optional, ofType: .string),
      .field(yearlyGoal.order, is: .optional, ofType: .int),
      .field(yearlyGoal.done, is: .optional, ofType: .bool),
      .field(yearlyGoal.owner, is: .optional, ofType: .string),
      .field(yearlyGoal.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(yearlyGoal.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension YearlyGoal: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}