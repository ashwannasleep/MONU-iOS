// swiftlint:disable all
import Amplify
import Foundation

public struct BucketItem: Model {
  public let id: String
  public var text: String
  public var category: String?
  public var date: Temporal.Date?
  public var link: String?
  public var done: Bool?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      text: String,
      category: String? = nil,
      date: Temporal.Date? = nil,
      link: String? = nil,
      done: Bool? = nil,
      owner: String? = nil) {
    self.init(id: id,
      text: text,
      category: category,
      date: date,
      link: link,
      done: done,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      text: String,
      category: String? = nil,
      date: Temporal.Date? = nil,
      link: String? = nil,
      done: Bool? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.text = text
      self.category = category
      self.date = date
      self.link = link
      self.done = done
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}