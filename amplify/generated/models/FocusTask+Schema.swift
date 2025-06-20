// swiftlint:disable all
import Amplify
import Foundation

extension FocusTask {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case title
    case date
    case done
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let focusTask = FocusTask.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "FocusTasks"
    model.syncPluralName = "FocusTasks"
    
    model.attributes(
      .primaryKey(fields: [focusTask.id])
    )
    
    model.fields(
      .field(focusTask.id, is: .required, ofType: .string),
      .field(focusTask.title, is: .required, ofType: .string),
      .field(focusTask.date, is: .optional, ofType: .date),
      .field(focusTask.done, is: .optional, ofType: .bool),
      .field(focusTask.owner, is: .optional, ofType: .string),
      .field(focusTask.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(focusTask.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension FocusTask: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}