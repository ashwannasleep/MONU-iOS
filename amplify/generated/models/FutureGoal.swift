// swiftlint:disable all
import Amplify
import Foundation

public struct FutureGoal: Model {
  public let id: String
  public var category: String
  public var title: String
  public var done: Bool?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      category: String,
      title: String,
      done: Bool? = nil,
      owner: String? = nil) {
    self.init(id: id,
      category: category,
      title: title,
      done: done,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      category: String,
      title: String,
      done: Bool? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.category = category
      self.title = title
      self.done = done
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}