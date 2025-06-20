// swiftlint:disable all
import Amplify
import Foundation

public struct FocusTask: Model {
  public let id: String
  public var title: String
  public var date: Temporal.Date?
  public var done: Bool?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      title: String,
      date: Temporal.Date? = nil,
      done: Bool? = nil,
      owner: String? = nil) {
    self.init(id: id,
      title: title,
      date: date,
      done: done,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      title: String,
      date: Temporal.Date? = nil,
      done: Bool? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.title = title
      self.date = date
      self.done = done
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}