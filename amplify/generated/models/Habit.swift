// swiftlint:disable all
import Amplify
import Foundation

public struct Habit: Model {
  public let id: String
  public var name: String
  public var icon: String?
  public var mood: String?
  public var days: [String?]?
  public var description: String?
  public var time: String?
  public var plan: String?
  public var log: String?
  public var color: String?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      icon: String? = nil,
      mood: String? = nil,
      days: [String?]? = nil,
      description: String? = nil,
      time: String? = nil,
      plan: String? = nil,
      log: String? = nil,
      color: String? = nil,
      owner: String? = nil) {
    self.init(id: id,
      name: name,
      icon: icon,
      mood: mood,
      days: days,
      description: description,
      time: time,
      plan: plan,
      log: log,
      color: color,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      icon: String? = nil,
      mood: String? = nil,
      days: [String?]? = nil,
      description: String? = nil,
      time: String? = nil,
      plan: String? = nil,
      log: String? = nil,
      color: String? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.icon = icon
      self.mood = mood
      self.days = days
      self.description = description
      self.time = time
      self.plan = plan
      self.log = log
      self.color = color
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}