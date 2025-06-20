// swiftlint:disable all
import Amplify
import Foundation

extension MonthlyEvent {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case title
    case start
    case end
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let monthlyEvent = MonthlyEvent.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "MonthlyEvents"
    model.syncPluralName = "MonthlyEvents"
    
    model.attributes(
      .primaryKey(fields: [monthlyEvent.id])
    )
    
    model.fields(
      .field(monthlyEvent.id, is: .required, ofType: .string),
      .field(monthlyEvent.title, is: .required, ofType: .string),
      .field(monthlyEvent.start, is: .required, ofType: .dateTime),
      .field(monthlyEvent.end, is: .required, ofType: .dateTime),
      .field(monthlyEvent.owner, is: .optional, ofType: .string),
      .field(monthlyEvent.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(monthlyEvent.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension MonthlyEvent: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}