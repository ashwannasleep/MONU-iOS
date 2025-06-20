// swiftlint:disable all
import Amplify
import Foundation

public struct UserSettings: Model {
  public let id: String
  public var googleToken: String?
  public var isSynced: Bool?
  public var theme: String?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      googleToken: String? = nil,
      isSynced: Bool? = nil,
      theme: String? = nil,
      owner: String? = nil) {
    self.init(id: id,
      googleToken: googleToken,
      isSynced: isSynced,
      theme: theme,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      googleToken: String? = nil,
      isSynced: Bool? = nil,
      theme: String? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.googleToken = googleToken
      self.isSynced = isSynced
      self.theme = theme
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}