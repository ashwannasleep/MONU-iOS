// swiftlint:disable all
import Amplify
import Foundation

public struct YearlyPopupTask: Model {
  public let id: String
  public var month: String
  public var title: String
  public var date: Temporal.Date?
  public var time: Temporal.Time?
  public var done: Bool?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      month: String,
      title: String,
      date: Temporal.Date? = nil,
      time: Temporal.Time? = nil,
      done: Bool? = nil,
      owner: String? = nil) {
    self.init(id: id,
      month: month,
      title: title,
      date: date,
      time: time,
      done: done,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      month: String,
      title: String,
      date: Temporal.Date? = nil,
      time: Temporal.Time? = nil,
      done: Bool? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.month = month
      self.title = title
      self.date = date
      self.time = time
      self.done = done
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}