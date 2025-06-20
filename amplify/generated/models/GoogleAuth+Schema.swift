// swiftlint:disable all
import Amplify
import Foundation

extension GoogleAuth {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case token
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let googleAuth = GoogleAuth.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "GoogleAuths"
    model.syncPluralName = "GoogleAuths"
    
    model.attributes(
      .primaryKey(fields: [googleAuth.id])
    )
    
    model.fields(
      .field(googleAuth.id, is: .required, ofType: .string),
      .field(googleAuth.token, is: .required, ofType: .string),
      .field(googleAuth.owner, is: .optional, ofType: .string),
      .field(googleAuth.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(googleAuth.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension GoogleAuth: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}