// swiftlint:disable all
import Amplify
import Foundation

extension YearlyPopupTask {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case month
    case title
    case date
    case time
    case done
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let yearlyPopupTask = YearlyPopupTask.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "YearlyPopupTasks"
    model.syncPluralName = "YearlyPopupTasks"
    
    model.attributes(
      .primaryKey(fields: [yearlyPopupTask.id])
    )
    
    model.fields(
      .field(yearlyPopupTask.id, is: .required, ofType: .string),
      .field(yearlyPopupTask.month, is: .required, ofType: .string),
      .field(yearlyPopupTask.title, is: .required, ofType: .string),
      .field(yearlyPopupTask.date, is: .optional, ofType: .date),
      .field(yearlyPopupTask.time, is: .optional, ofType: .time),
      .field(yearlyPopupTask.done, is: .optional, ofType: .bool),
      .field(yearlyPopupTask.owner, is: .optional, ofType: .string),
      .field(yearlyPopupTask.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(yearlyPopupTask.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension YearlyPopupTask: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}