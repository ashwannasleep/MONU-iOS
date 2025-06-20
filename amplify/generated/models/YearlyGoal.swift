// swiftlint:disable all
import Amplify
import Foundation

public struct YearlyGoal: Model {
  public let id: String
  public var year: Int
  public var title: String
  public var details: String?
  public var order: Int?
  public var done: Bool?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      year: Int,
      title: String,
      details: String? = nil,
      order: Int? = nil,
      done: Bool? = nil,
      owner: String? = nil) {
    self.init(id: id,
      year: year,
      title: title,
      details: details,
      order: order,
      done: done,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      year: Int,
      title: String,
      details: String? = nil,
      order: Int? = nil,
      done: Bool? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.year = year
      self.title = title
      self.details = details
      self.order = order
      self.done = done
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}