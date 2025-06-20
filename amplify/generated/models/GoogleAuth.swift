// swiftlint:disable all
import Amplify
import Foundation

public struct GoogleAuth: Model {
  public let id: String
  public var token: String
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      token: String,
      owner: String? = nil) {
    self.init(id: id,
      token: token,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      token: String,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.token = token
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}