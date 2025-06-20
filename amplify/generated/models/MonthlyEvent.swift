// swiftlint:disable all
import Amplify
import Foundation

public struct MonthlyEvent: Model {
  public let id: String
  public var title: String
  public var start: Temporal.DateTime
  public var end: Temporal.DateTime
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      title: String,
      start: Temporal.DateTime,
      end: Temporal.DateTime,
      owner: String? = nil) {
    self.init(id: id,
      title: title,
      start: start,
      end: end,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      title: String,
      start: Temporal.DateTime,
      end: Temporal.DateTime,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.title = title
      self.start = start
      self.end = end
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}