// swiftlint:disable all
import Amplify
import Foundation

extension BucketItem {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case text
    case category
    case date
    case link
    case done
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let bucketItem = BucketItem.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "BucketItems"
    model.syncPluralName = "BucketItems"
    
    model.attributes(
      .primaryKey(fields: [bucketItem.id])
    )
    
    model.fields(
      .field(bucketItem.id, is: .required, ofType: .string),
      .field(bucketItem.text, is: .required, ofType: .string),
      .field(bucketItem.category, is: .optional, ofType: .string),
      .field(bucketItem.date, is: .optional, ofType: .date),
      .field(bucketItem.link, is: .optional, ofType: .string),
      .field(bucketItem.done, is: .optional, ofType: .bool),
      .field(bucketItem.owner, is: .optional, ofType: .string),
      .field(bucketItem.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(bucketItem.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension BucketItem: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}