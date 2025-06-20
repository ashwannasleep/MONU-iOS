// swiftlint:disable all
import Amplify
import Foundation

extension UserSettings {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case googleToken
    case isSynced
    case theme
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userSettings = UserSettings.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "UserSettings"
    model.syncPluralName = "UserSettings"
    
    model.attributes(
      .primaryKey(fields: [userSettings.id])
    )
    
    model.fields(
      .field(userSettings.id, is: .required, ofType: .string),
      .field(userSettings.googleToken, is: .optional, ofType: .string),
      .field(userSettings.isSynced, is: .optional, ofType: .bool),
      .field(userSettings.theme, is: .optional, ofType: .string),
      .field(userSettings.owner, is: .optional, ofType: .string),
      .field(userSettings.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(userSettings.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension UserSettings: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}