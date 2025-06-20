// swiftlint:disable all
import Amplify
import Foundation

public struct DailyTask: Model {
  public let id: String
  public var date: Temporal.Date
  public var text: String
  public var time: String?
  public var duration: String?
  public var order: Int?
  public var done: Bool?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      date: Temporal.Date,
      text: String,
      time: String? = nil,
      duration: String? = nil,
      order: Int? = nil,
      done: Bool? = nil,
      owner: String? = nil) {
    self.init(id: id,
      date: date,
      text: text,
      time: time,
      duration: duration,
      order: order,
      done: done,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      date: Temporal.Date,
      text: String,
      time: String? = nil,
      duration: String? = nil,
      order: Int? = nil,
      done: Bool? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.date = date
      self.text = text
      self.time = time
      self.duration = duration
      self.order = order
      self.done = done
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}