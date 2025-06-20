//  This file was automatically generated and should not be edited.

#if canImport(AWSAPIPlugin)
import Foundation

public protocol GraphQLInputValue {
}

public struct GraphQLVariable {
  let name: String
  
  public init(_ name: String) {
    self.name = name
  }
}

extension GraphQLVariable: GraphQLInputValue {
}

extension JSONEncodable {
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> Any {
    return jsonValue
  }
}

public typealias GraphQLMap = [String: JSONEncodable?]

extension Dictionary where Key == String, Value == JSONEncodable? {
  public var withNilValuesRemoved: Dictionary<String, JSONEncodable> {
    var filtered = Dictionary<String, JSONEncodable>(minimumCapacity: count)
    for (key, value) in self {
      if value != nil {
        filtered[key] = value
      }
    }
    return filtered
  }
}

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

public extension GraphQLMapConvertible {
  var jsonValue: Any {
    return graphQLMap.withNilValuesRemoved.jsonValue
  }
}

public typealias GraphQLID = String

public protocol APISwiftGraphQLOperation: AnyObject {
  
  static var operationString: String { get }
  static var requestString: String { get }
  static var operationIdentifier: String? { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLSelectionSet
}

public extension APISwiftGraphQLOperation {
  static var requestString: String {
    return operationString
  }

  static var operationIdentifier: String? {
    return nil
  }

  var variables: GraphQLMap? {
    return nil
  }
}

public protocol GraphQLQuery: APISwiftGraphQLOperation {}

public protocol GraphQLMutation: APISwiftGraphQLOperation {}

public protocol GraphQLSubscription: APISwiftGraphQLOperation {}

public protocol GraphQLFragment: GraphQLSelectionSet {
  static var possibleTypes: [String] { get }
}

public typealias Snapshot = [String: Any?]

public protocol GraphQLSelectionSet: Decodable {
  static var selections: [GraphQLSelection] { get }
  
  var snapshot: Snapshot { get }
  init(snapshot: Snapshot)
}

extension GraphQLSelectionSet {
    public init(from decoder: Decoder) throws {
        if let jsonObject = try? APISwiftJSONValue(from: decoder) {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(jsonObject)
            let decodedDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
            let optionalDictionary = decodedDictionary.mapValues { $0 as Any? }

            self.init(snapshot: optionalDictionary)
        } else {
            self.init(snapshot: [:])
        }
    }
}

enum APISwiftJSONValue: Codable {
    case array([APISwiftJSONValue])
    case boolean(Bool)
    case number(Double)
    case object([String: APISwiftJSONValue])
    case string(String)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode([String: APISwiftJSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([APISwiftJSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            self = .null
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .array(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

public protocol GraphQLSelection {
}

public struct GraphQLField: GraphQLSelection {
  let name: String
  let alias: String?
  let arguments: [String: GraphQLInputValue]?
  
  var responseKey: String {
    return alias ?? name
  }
  
  let type: GraphQLOutputType
  
  public init(_ name: String, alias: String? = nil, arguments: [String: GraphQLInputValue]? = nil, type: GraphQLOutputType) {
    self.name = name
    self.alias = alias
    
    self.arguments = arguments
    
    self.type = type
  }
}

public indirect enum GraphQLOutputType {
  case scalar(JSONDecodable.Type)
  case object([GraphQLSelection])
  case nonNull(GraphQLOutputType)
  case list(GraphQLOutputType)
  
  var namedType: GraphQLOutputType {
    switch self {
    case .nonNull(let innerType), .list(let innerType):
      return innerType.namedType
    case .scalar, .object:
      return self
    }
  }
}

public struct GraphQLBooleanCondition: GraphQLSelection {
  let variableName: String
  let inverted: Bool
  let selections: [GraphQLSelection]
  
  public init(variableName: String, inverted: Bool, selections: [GraphQLSelection]) {
    self.variableName = variableName
    self.inverted = inverted;
    self.selections = selections;
  }
}

public struct GraphQLTypeCondition: GraphQLSelection {
  let possibleTypes: [String]
  let selections: [GraphQLSelection]
  
  public init(possibleTypes: [String], selections: [GraphQLSelection]) {
    self.possibleTypes = possibleTypes
    self.selections = selections;
  }
}

public struct GraphQLFragmentSpread: GraphQLSelection {
  let fragment: GraphQLFragment.Type
  
  public init(_ fragment: GraphQLFragment.Type) {
    self.fragment = fragment
  }
}

public struct GraphQLTypeCase: GraphQLSelection {
  let variants: [String: [GraphQLSelection]]
  let `default`: [GraphQLSelection]
  
  public init(variants: [String: [GraphQLSelection]], default: [GraphQLSelection]) {
    self.variants = variants
    self.default = `default`;
  }
}

public typealias JSONObject = [String: Any]

public protocol JSONDecodable {
  init(jsonValue value: Any) throws
}

public protocol JSONEncodable: GraphQLInputValue {
  var jsonValue: Any { get }
}

public enum JSONDecodingError: Error, LocalizedError {
  case missingValue
  case nullValue
  case wrongType
  case couldNotConvert(value: Any, to: Any.Type)
  
  public var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .wrongType:
      return "Wrong type"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }
}

extension String: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
    self = string
  }

  public var jsonValue: Any {
    return self
  }
}

extension Int: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Int.self)
    }
    self = number.intValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Float: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Float.self)
    }
    self = number.floatValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Double: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Double.self)
    }
    self = number.doubleValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Bool: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let bool = value as? Bool else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Bool.self)
    }
    self = bool
  }

  public var jsonValue: Any {
    return self
  }
}

extension RawRepresentable where RawValue: JSONDecodable {
  public init(jsonValue value: Any) throws {
    let rawValue = try RawValue(jsonValue: value)
    if let tempSelf = Self(rawValue: rawValue) {
      self = tempSelf
    } else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Self.self)
    }
  }
}

extension RawRepresentable where RawValue: JSONEncodable {
  public var jsonValue: Any {
    return rawValue.jsonValue
  }
}

extension Optional where Wrapped: JSONDecodable {
  public init(jsonValue value: Any) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

extension Optional: JSONEncodable {
  public var jsonValue: Any {
    switch self {
    case .none:
      return NSNull()
    case .some(let wrapped as JSONEncodable):
      return wrapped.jsonValue
    default:
      fatalError("Optional is only JSONEncodable if Wrapped is")
    }
  }
}

extension Dictionary: JSONEncodable {
  public var jsonValue: Any {
    return jsonObject
  }
  
  public var jsonObject: JSONObject {
    var jsonObject = JSONObject(minimumCapacity: count)
    for (key, value) in self {
      if case let (key as String, value as JSONEncodable) = (key, value) {
        jsonObject[key] = value.jsonValue
      } else {
        fatalError("Dictionary is only JSONEncodable if Value is (and if Key is String)")
      }
    }
    return jsonObject
  }
}

extension Array: JSONEncodable {
  public var jsonValue: Any {
    return map() { element -> (Any) in
      if case let element as JSONEncodable = element {
        return element.jsonValue
      } else {
        fatalError("Array is only JSONEncodable if Element is")
      }
    }
  }
}

extension URL: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
    self.init(string: string)!
  }

  public var jsonValue: Any {
    return self.absoluteString
  }
}

extension Dictionary {
  static func += (lhs: inout Dictionary, rhs: Dictionary) {
    lhs.merge(rhs) { (_, new) in new }
  }
}

#elseif canImport(AWSAppSync)
import AWSAppSync
#endif

public struct CreateBucketItemInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var text: String {
    get {
      return graphQLMap["text"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var category: String? {
    get {
      return graphQLMap["category"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var date: String? {
    get {
      return graphQLMap["date"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var link: String? {
    get {
      return graphQLMap["link"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelBucketItemConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(text: ModelStringInput? = nil, category: ModelStringInput? = nil, date: ModelStringInput? = nil, link: ModelStringInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, and: [ModelBucketItemConditionInput?]? = nil, or: [ModelBucketItemConditionInput?]? = nil, not: ModelBucketItemConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var text: ModelStringInput? {
    get {
      return graphQLMap["text"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var category: ModelStringInput? {
    get {
      return graphQLMap["category"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var link: ModelStringInput? {
    get {
      return graphQLMap["link"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelBucketItemConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelBucketItemConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelBucketItemConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelBucketItemConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelBucketItemConditionInput? {
    get {
      return graphQLMap["not"] as! ModelBucketItemConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct ModelStringInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil, size: ModelSizeInput? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "attributeExists": attributeExists, "attributeType": attributeType, "size": size]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }

  public var size: ModelSizeInput? {
    get {
      return graphQLMap["size"] as! ModelSizeInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

public enum ModelAttributeTypes: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case binary
  case binarySet
  case bool
  case list
  case map
  case number
  case numberSet
  case string
  case stringSet
  case null
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "binary": self = .binary
      case "binarySet": self = .binarySet
      case "bool": self = .bool
      case "list": self = .list
      case "map": self = .map
      case "number": self = .number
      case "numberSet": self = .numberSet
      case "string": self = .string
      case "stringSet": self = .stringSet
      case "_null": self = .null
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .binary: return "binary"
      case .binarySet: return "binarySet"
      case .bool: return "bool"
      case .list: return "list"
      case .map: return "map"
      case .number: return "number"
      case .numberSet: return "numberSet"
      case .string: return "string"
      case .stringSet: return "stringSet"
      case .null: return "_null"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ModelAttributeTypes, rhs: ModelAttributeTypes) -> Bool {
    switch (lhs, rhs) {
      case (.binary, .binary): return true
      case (.binarySet, .binarySet): return true
      case (.bool, .bool): return true
      case (.list, .list): return true
      case (.map, .map): return true
      case (.number, .number): return true
      case (.numberSet, .numberSet): return true
      case (.string, .string): return true
      case (.stringSet, .stringSet): return true
      case (.null, .null): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelSizeInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }
}

public struct ModelBooleanInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Bool? = nil, eq: Bool? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Bool? {
    get {
      return graphQLMap["ne"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Bool? {
    get {
      return graphQLMap["eq"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public struct UpdateBucketItemInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, text: String? = nil, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var text: String? {
    get {
      return graphQLMap["text"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var category: String? {
    get {
      return graphQLMap["category"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var date: String? {
    get {
      return graphQLMap["date"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var link: String? {
    get {
      return graphQLMap["link"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteBucketItemInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateYearlyGoalInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var year: Int {
    get {
      return graphQLMap["year"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "year")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var details: String? {
    get {
      return graphQLMap["details"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "details")
    }
  }

  public var order: Int? {
    get {
      return graphQLMap["order"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelYearlyGoalConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(year: ModelIntInput? = nil, title: ModelStringInput? = nil, details: ModelStringInput? = nil, order: ModelIntInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, and: [ModelYearlyGoalConditionInput?]? = nil, or: [ModelYearlyGoalConditionInput?]? = nil, not: ModelYearlyGoalConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var year: ModelIntInput? {
    get {
      return graphQLMap["year"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "year")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var details: ModelStringInput? {
    get {
      return graphQLMap["details"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "details")
    }
  }

  public var order: ModelIntInput? {
    get {
      return graphQLMap["order"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelYearlyGoalConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelYearlyGoalConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelYearlyGoalConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelYearlyGoalConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelYearlyGoalConditionInput? {
    get {
      return graphQLMap["not"] as! ModelYearlyGoalConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct ModelIntInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public struct UpdateYearlyGoalInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, year: Int? = nil, title: String? = nil, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var year: Int? {
    get {
      return graphQLMap["year"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "year")
    }
  }

  public var title: String? {
    get {
      return graphQLMap["title"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var details: String? {
    get {
      return graphQLMap["details"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "details")
    }
  }

  public var order: Int? {
    get {
      return graphQLMap["order"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteYearlyGoalInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateDailyTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var date: String {
    get {
      return graphQLMap["date"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var text: String {
    get {
      return graphQLMap["text"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var time: String? {
    get {
      return graphQLMap["time"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var duration: String? {
    get {
      return graphQLMap["duration"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }

  public var order: Int? {
    get {
      return graphQLMap["order"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelDailyTaskConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(date: ModelStringInput? = nil, text: ModelStringInput? = nil, time: ModelStringInput? = nil, duration: ModelStringInput? = nil, order: ModelIntInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, and: [ModelDailyTaskConditionInput?]? = nil, or: [ModelDailyTaskConditionInput?]? = nil, not: ModelDailyTaskConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var text: ModelStringInput? {
    get {
      return graphQLMap["text"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var time: ModelStringInput? {
    get {
      return graphQLMap["time"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var duration: ModelStringInput? {
    get {
      return graphQLMap["duration"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }

  public var order: ModelIntInput? {
    get {
      return graphQLMap["order"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelDailyTaskConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelDailyTaskConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelDailyTaskConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelDailyTaskConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelDailyTaskConditionInput? {
    get {
      return graphQLMap["not"] as! ModelDailyTaskConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateDailyTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, date: String? = nil, text: String? = nil, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var date: String? {
    get {
      return graphQLMap["date"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var text: String? {
    get {
      return graphQLMap["text"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var time: String? {
    get {
      return graphQLMap["time"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var duration: String? {
    get {
      return graphQLMap["duration"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }

  public var order: Int? {
    get {
      return graphQLMap["order"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteDailyTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateHabitInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var icon: String? {
    get {
      return graphQLMap["icon"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "icon")
    }
  }

  public var mood: String? {
    get {
      return graphQLMap["mood"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mood")
    }
  }

  public var days: [String?]? {
    get {
      return graphQLMap["days"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "days")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var time: String? {
    get {
      return graphQLMap["time"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var plan: String? {
    get {
      return graphQLMap["plan"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "plan")
    }
  }

  public var log: String? {
    get {
      return graphQLMap["log"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "log")
    }
  }

  public var color: String? {
    get {
      return graphQLMap["color"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "color")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelHabitConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: ModelStringInput? = nil, icon: ModelStringInput? = nil, mood: ModelStringInput? = nil, days: ModelStringInput? = nil, description: ModelStringInput? = nil, time: ModelStringInput? = nil, plan: ModelStringInput? = nil, log: ModelStringInput? = nil, color: ModelStringInput? = nil, owner: ModelStringInput? = nil, and: [ModelHabitConditionInput?]? = nil, or: [ModelHabitConditionInput?]? = nil, not: ModelHabitConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var name: ModelStringInput? {
    get {
      return graphQLMap["name"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var icon: ModelStringInput? {
    get {
      return graphQLMap["icon"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "icon")
    }
  }

  public var mood: ModelStringInput? {
    get {
      return graphQLMap["mood"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mood")
    }
  }

  public var days: ModelStringInput? {
    get {
      return graphQLMap["days"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "days")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var time: ModelStringInput? {
    get {
      return graphQLMap["time"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var plan: ModelStringInput? {
    get {
      return graphQLMap["plan"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "plan")
    }
  }

  public var log: ModelStringInput? {
    get {
      return graphQLMap["log"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "log")
    }
  }

  public var color: ModelStringInput? {
    get {
      return graphQLMap["color"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "color")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelHabitConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelHabitConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelHabitConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelHabitConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelHabitConditionInput? {
    get {
      return graphQLMap["not"] as! ModelHabitConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateHabitInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, name: String? = nil, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String? {
    get {
      return graphQLMap["name"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var icon: String? {
    get {
      return graphQLMap["icon"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "icon")
    }
  }

  public var mood: String? {
    get {
      return graphQLMap["mood"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mood")
    }
  }

  public var days: [String?]? {
    get {
      return graphQLMap["days"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "days")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var time: String? {
    get {
      return graphQLMap["time"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var plan: String? {
    get {
      return graphQLMap["plan"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "plan")
    }
  }

  public var log: String? {
    get {
      return graphQLMap["log"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "log")
    }
  }

  public var color: String? {
    get {
      return graphQLMap["color"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "color")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteHabitInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateFutureGoalInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, category: String, title: String, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "category": category, "title": title, "done": done, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var category: String {
    get {
      return graphQLMap["category"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelFutureGoalConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(category: ModelStringInput? = nil, title: ModelStringInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, and: [ModelFutureGoalConditionInput?]? = nil, or: [ModelFutureGoalConditionInput?]? = nil, not: ModelFutureGoalConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["category": category, "title": title, "done": done, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var category: ModelStringInput? {
    get {
      return graphQLMap["category"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelFutureGoalConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelFutureGoalConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelFutureGoalConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelFutureGoalConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelFutureGoalConditionInput? {
    get {
      return graphQLMap["not"] as! ModelFutureGoalConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateFutureGoalInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, category: String? = nil, title: String? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "category": category, "title": title, "done": done, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var category: String? {
    get {
      return graphQLMap["category"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var title: String? {
    get {
      return graphQLMap["title"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteFutureGoalInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateYearlyPopupTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var month: String {
    get {
      return graphQLMap["month"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "month")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: String? {
    get {
      return graphQLMap["date"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var time: String? {
    get {
      return graphQLMap["time"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelYearlyPopupTaskConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(month: ModelStringInput? = nil, title: ModelStringInput? = nil, date: ModelStringInput? = nil, time: ModelStringInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, and: [ModelYearlyPopupTaskConditionInput?]? = nil, or: [ModelYearlyPopupTaskConditionInput?]? = nil, not: ModelYearlyPopupTaskConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var month: ModelStringInput? {
    get {
      return graphQLMap["month"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "month")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var time: ModelStringInput? {
    get {
      return graphQLMap["time"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelYearlyPopupTaskConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelYearlyPopupTaskConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelYearlyPopupTaskConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelYearlyPopupTaskConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelYearlyPopupTaskConditionInput? {
    get {
      return graphQLMap["not"] as! ModelYearlyPopupTaskConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateYearlyPopupTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, month: String? = nil, title: String? = nil, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var month: String? {
    get {
      return graphQLMap["month"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "month")
    }
  }

  public var title: String? {
    get {
      return graphQLMap["title"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: String? {
    get {
      return graphQLMap["date"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var time: String? {
    get {
      return graphQLMap["time"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteYearlyPopupTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateFocusTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "title": title, "date": date, "done": done, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: String? {
    get {
      return graphQLMap["date"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelFocusTaskConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(title: ModelStringInput? = nil, date: ModelStringInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, and: [ModelFocusTaskConditionInput?]? = nil, or: [ModelFocusTaskConditionInput?]? = nil, not: ModelFocusTaskConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["title": title, "date": date, "done": done, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelFocusTaskConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelFocusTaskConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelFocusTaskConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelFocusTaskConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelFocusTaskConditionInput? {
    get {
      return graphQLMap["not"] as! ModelFocusTaskConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateFocusTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, title: String? = nil, date: String? = nil, done: Bool? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "title": title, "date": date, "done": done, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String? {
    get {
      return graphQLMap["title"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: String? {
    get {
      return graphQLMap["date"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var done: Bool? {
    get {
      return graphQLMap["done"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteFocusTaskInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateMonthlyEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, title: String, start: String, end: String, owner: String? = nil) {
    graphQLMap = ["id": id, "title": title, "start": start, "end": end, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var start: String {
    get {
      return graphQLMap["start"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "start")
    }
  }

  public var end: String {
    get {
      return graphQLMap["end"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "end")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelMonthlyEventConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(title: ModelStringInput? = nil, start: ModelStringInput? = nil, end: ModelStringInput? = nil, owner: ModelStringInput? = nil, and: [ModelMonthlyEventConditionInput?]? = nil, or: [ModelMonthlyEventConditionInput?]? = nil, not: ModelMonthlyEventConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["title": title, "start": start, "end": end, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var start: ModelStringInput? {
    get {
      return graphQLMap["start"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "start")
    }
  }

  public var end: ModelStringInput? {
    get {
      return graphQLMap["end"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "end")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelMonthlyEventConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelMonthlyEventConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelMonthlyEventConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelMonthlyEventConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelMonthlyEventConditionInput? {
    get {
      return graphQLMap["not"] as! ModelMonthlyEventConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateMonthlyEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, title: String? = nil, start: String? = nil, end: String? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "title": title, "start": start, "end": end, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String? {
    get {
      return graphQLMap["title"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var start: String? {
    get {
      return graphQLMap["start"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "start")
    }
  }

  public var end: String? {
    get {
      return graphQLMap["end"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "end")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteMonthlyEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateGoogleAuthInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, token: String, owner: String? = nil) {
    graphQLMap = ["id": id, "token": token, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var token: String {
    get {
      return graphQLMap["token"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelGoogleAuthConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(token: ModelStringInput? = nil, owner: ModelStringInput? = nil, and: [ModelGoogleAuthConditionInput?]? = nil, or: [ModelGoogleAuthConditionInput?]? = nil, not: ModelGoogleAuthConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["token": token, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var token: ModelStringInput? {
    get {
      return graphQLMap["token"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelGoogleAuthConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelGoogleAuthConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelGoogleAuthConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelGoogleAuthConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelGoogleAuthConditionInput? {
    get {
      return graphQLMap["not"] as! ModelGoogleAuthConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateGoogleAuthInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, token: String? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "token": token, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var token: String? {
    get {
      return graphQLMap["token"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteGoogleAuthInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateUserSettingsInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var googleToken: String? {
    get {
      return graphQLMap["googleToken"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "googleToken")
    }
  }

  public var isSynced: Bool? {
    get {
      return graphQLMap["isSynced"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isSynced")
    }
  }

  public var theme: String? {
    get {
      return graphQLMap["theme"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "theme")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelUserSettingsConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(googleToken: ModelStringInput? = nil, isSynced: ModelBooleanInput? = nil, theme: ModelStringInput? = nil, owner: ModelStringInput? = nil, and: [ModelUserSettingsConditionInput?]? = nil, or: [ModelUserSettingsConditionInput?]? = nil, not: ModelUserSettingsConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var googleToken: ModelStringInput? {
    get {
      return graphQLMap["googleToken"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "googleToken")
    }
  }

  public var isSynced: ModelBooleanInput? {
    get {
      return graphQLMap["isSynced"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isSynced")
    }
  }

  public var theme: ModelStringInput? {
    get {
      return graphQLMap["theme"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "theme")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var and: [ModelUserSettingsConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelUserSettingsConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelUserSettingsConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelUserSettingsConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelUserSettingsConditionInput? {
    get {
      return graphQLMap["not"] as! ModelUserSettingsConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateUserSettingsInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil) {
    graphQLMap = ["id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var googleToken: String? {
    get {
      return graphQLMap["googleToken"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "googleToken")
    }
  }

  public var isSynced: Bool? {
    get {
      return graphQLMap["isSynced"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isSynced")
    }
  }

  public var theme: String? {
    get {
      return graphQLMap["theme"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "theme")
    }
  }

  public var owner: String? {
    get {
      return graphQLMap["owner"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct DeleteUserSettingsInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct ModelBucketItemFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, text: ModelStringInput? = nil, category: ModelStringInput? = nil, date: ModelStringInput? = nil, link: ModelStringInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelBucketItemFilterInput?]? = nil, or: [ModelBucketItemFilterInput?]? = nil, not: ModelBucketItemFilterInput? = nil) {
    graphQLMap = ["id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var text: ModelStringInput? {
    get {
      return graphQLMap["text"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var category: ModelStringInput? {
    get {
      return graphQLMap["category"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var link: ModelStringInput? {
    get {
      return graphQLMap["link"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelBucketItemFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelBucketItemFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelBucketItemFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelBucketItemFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelBucketItemFilterInput? {
    get {
      return graphQLMap["not"] as! ModelBucketItemFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelIDInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil, size: ModelSizeInput? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "attributeExists": attributeExists, "attributeType": attributeType, "size": size]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }

  public var size: ModelSizeInput? {
    get {
      return graphQLMap["size"] as! ModelSizeInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

public struct ModelYearlyGoalFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, year: ModelIntInput? = nil, title: ModelStringInput? = nil, details: ModelStringInput? = nil, order: ModelIntInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelYearlyGoalFilterInput?]? = nil, or: [ModelYearlyGoalFilterInput?]? = nil, not: ModelYearlyGoalFilterInput? = nil) {
    graphQLMap = ["id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var year: ModelIntInput? {
    get {
      return graphQLMap["year"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "year")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var details: ModelStringInput? {
    get {
      return graphQLMap["details"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "details")
    }
  }

  public var order: ModelIntInput? {
    get {
      return graphQLMap["order"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelYearlyGoalFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelYearlyGoalFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelYearlyGoalFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelYearlyGoalFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelYearlyGoalFilterInput? {
    get {
      return graphQLMap["not"] as! ModelYearlyGoalFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelDailyTaskFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, date: ModelStringInput? = nil, text: ModelStringInput? = nil, time: ModelStringInput? = nil, duration: ModelStringInput? = nil, order: ModelIntInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelDailyTaskFilterInput?]? = nil, or: [ModelDailyTaskFilterInput?]? = nil, not: ModelDailyTaskFilterInput? = nil) {
    graphQLMap = ["id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var text: ModelStringInput? {
    get {
      return graphQLMap["text"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var time: ModelStringInput? {
    get {
      return graphQLMap["time"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var duration: ModelStringInput? {
    get {
      return graphQLMap["duration"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }

  public var order: ModelIntInput? {
    get {
      return graphQLMap["order"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelDailyTaskFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelDailyTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelDailyTaskFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelDailyTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelDailyTaskFilterInput? {
    get {
      return graphQLMap["not"] as! ModelDailyTaskFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelHabitFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, name: ModelStringInput? = nil, icon: ModelStringInput? = nil, mood: ModelStringInput? = nil, days: ModelStringInput? = nil, description: ModelStringInput? = nil, time: ModelStringInput? = nil, plan: ModelStringInput? = nil, log: ModelStringInput? = nil, color: ModelStringInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelHabitFilterInput?]? = nil, or: [ModelHabitFilterInput?]? = nil, not: ModelHabitFilterInput? = nil) {
    graphQLMap = ["id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: ModelStringInput? {
    get {
      return graphQLMap["name"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var icon: ModelStringInput? {
    get {
      return graphQLMap["icon"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "icon")
    }
  }

  public var mood: ModelStringInput? {
    get {
      return graphQLMap["mood"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mood")
    }
  }

  public var days: ModelStringInput? {
    get {
      return graphQLMap["days"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "days")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var time: ModelStringInput? {
    get {
      return graphQLMap["time"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var plan: ModelStringInput? {
    get {
      return graphQLMap["plan"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "plan")
    }
  }

  public var log: ModelStringInput? {
    get {
      return graphQLMap["log"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "log")
    }
  }

  public var color: ModelStringInput? {
    get {
      return graphQLMap["color"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "color")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelHabitFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelHabitFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelHabitFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelHabitFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelHabitFilterInput? {
    get {
      return graphQLMap["not"] as! ModelHabitFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelFutureGoalFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, category: ModelStringInput? = nil, title: ModelStringInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelFutureGoalFilterInput?]? = nil, or: [ModelFutureGoalFilterInput?]? = nil, not: ModelFutureGoalFilterInput? = nil) {
    graphQLMap = ["id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var category: ModelStringInput? {
    get {
      return graphQLMap["category"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelFutureGoalFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelFutureGoalFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelFutureGoalFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelFutureGoalFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelFutureGoalFilterInput? {
    get {
      return graphQLMap["not"] as! ModelFutureGoalFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelYearlyPopupTaskFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, month: ModelStringInput? = nil, title: ModelStringInput? = nil, date: ModelStringInput? = nil, time: ModelStringInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelYearlyPopupTaskFilterInput?]? = nil, or: [ModelYearlyPopupTaskFilterInput?]? = nil, not: ModelYearlyPopupTaskFilterInput? = nil) {
    graphQLMap = ["id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var month: ModelStringInput? {
    get {
      return graphQLMap["month"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "month")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var time: ModelStringInput? {
    get {
      return graphQLMap["time"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelYearlyPopupTaskFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelYearlyPopupTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelYearlyPopupTaskFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelYearlyPopupTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelYearlyPopupTaskFilterInput? {
    get {
      return graphQLMap["not"] as! ModelYearlyPopupTaskFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelFocusTaskFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, title: ModelStringInput? = nil, date: ModelStringInput? = nil, done: ModelBooleanInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelFocusTaskFilterInput?]? = nil, or: [ModelFocusTaskFilterInput?]? = nil, not: ModelFocusTaskFilterInput? = nil) {
    graphQLMap = ["id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var done: ModelBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelFocusTaskFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelFocusTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelFocusTaskFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelFocusTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelFocusTaskFilterInput? {
    get {
      return graphQLMap["not"] as! ModelFocusTaskFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelMonthlyEventFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, title: ModelStringInput? = nil, start: ModelStringInput? = nil, end: ModelStringInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelMonthlyEventFilterInput?]? = nil, or: [ModelMonthlyEventFilterInput?]? = nil, not: ModelMonthlyEventFilterInput? = nil) {
    graphQLMap = ["id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var start: ModelStringInput? {
    get {
      return graphQLMap["start"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "start")
    }
  }

  public var end: ModelStringInput? {
    get {
      return graphQLMap["end"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "end")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelMonthlyEventFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelMonthlyEventFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelMonthlyEventFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelMonthlyEventFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelMonthlyEventFilterInput? {
    get {
      return graphQLMap["not"] as! ModelMonthlyEventFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelGoogleAuthFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, token: ModelStringInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelGoogleAuthFilterInput?]? = nil, or: [ModelGoogleAuthFilterInput?]? = nil, not: ModelGoogleAuthFilterInput? = nil) {
    graphQLMap = ["id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var token: ModelStringInput? {
    get {
      return graphQLMap["token"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelGoogleAuthFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelGoogleAuthFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelGoogleAuthFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelGoogleAuthFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelGoogleAuthFilterInput? {
    get {
      return graphQLMap["not"] as! ModelGoogleAuthFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelUserSettingsFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, googleToken: ModelStringInput? = nil, isSynced: ModelBooleanInput? = nil, theme: ModelStringInput? = nil, owner: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelUserSettingsFilterInput?]? = nil, or: [ModelUserSettingsFilterInput?]? = nil, not: ModelUserSettingsFilterInput? = nil) {
    graphQLMap = ["id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var googleToken: ModelStringInput? {
    get {
      return graphQLMap["googleToken"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "googleToken")
    }
  }

  public var isSynced: ModelBooleanInput? {
    get {
      return graphQLMap["isSynced"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isSynced")
    }
  }

  public var theme: ModelStringInput? {
    get {
      return graphQLMap["theme"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "theme")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelUserSettingsFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelUserSettingsFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelUserSettingsFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelUserSettingsFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelUserSettingsFilterInput? {
    get {
      return graphQLMap["not"] as! ModelUserSettingsFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelSubscriptionBucketItemFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, text: ModelSubscriptionStringInput? = nil, category: ModelSubscriptionStringInput? = nil, date: ModelSubscriptionStringInput? = nil, link: ModelSubscriptionStringInput? = nil, done: ModelSubscriptionBooleanInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionBucketItemFilterInput?]? = nil, or: [ModelSubscriptionBucketItemFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var text: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["text"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var category: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["category"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var date: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["date"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var link: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["link"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var done: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionBucketItemFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionBucketItemFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionBucketItemFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionBucketItemFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionIDInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "in": `in`, "notIn": notIn]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var `in`: [GraphQLID?]? {
    get {
      return graphQLMap["in"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [GraphQLID?]? {
    get {
      return graphQLMap["notIn"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionStringInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "in": `in`, "notIn": notIn]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var `in`: [String?]? {
    get {
      return graphQLMap["in"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [String?]? {
    get {
      return graphQLMap["notIn"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionBooleanInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Bool? = nil, eq: Bool? = nil) {
    graphQLMap = ["ne": ne, "eq": eq]
  }

  public var ne: Bool? {
    get {
      return graphQLMap["ne"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Bool? {
    get {
      return graphQLMap["eq"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }
}

public struct ModelSubscriptionYearlyGoalFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, year: ModelSubscriptionIntInput? = nil, title: ModelSubscriptionStringInput? = nil, details: ModelSubscriptionStringInput? = nil, order: ModelSubscriptionIntInput? = nil, done: ModelSubscriptionBooleanInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionYearlyGoalFilterInput?]? = nil, or: [ModelSubscriptionYearlyGoalFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var year: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["year"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "year")
    }
  }

  public var title: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["title"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var details: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["details"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "details")
    }
  }

  public var order: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["order"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionYearlyGoalFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionYearlyGoalFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionYearlyGoalFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionYearlyGoalFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionIntInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil, `in`: [Int?]? = nil, notIn: [Int?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "in": `in`, "notIn": notIn]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var `in`: [Int?]? {
    get {
      return graphQLMap["in"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [Int?]? {
    get {
      return graphQLMap["notIn"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionDailyTaskFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, date: ModelSubscriptionStringInput? = nil, text: ModelSubscriptionStringInput? = nil, time: ModelSubscriptionStringInput? = nil, duration: ModelSubscriptionStringInput? = nil, order: ModelSubscriptionIntInput? = nil, done: ModelSubscriptionBooleanInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionDailyTaskFilterInput?]? = nil, or: [ModelSubscriptionDailyTaskFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var date: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["date"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var text: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["text"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }

  public var time: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["time"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var duration: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["duration"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }

  public var order: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["order"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var done: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionDailyTaskFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionDailyTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionDailyTaskFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionDailyTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionHabitFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, name: ModelSubscriptionStringInput? = nil, icon: ModelSubscriptionStringInput? = nil, mood: ModelSubscriptionStringInput? = nil, days: ModelSubscriptionStringInput? = nil, description: ModelSubscriptionStringInput? = nil, time: ModelSubscriptionStringInput? = nil, plan: ModelSubscriptionStringInput? = nil, log: ModelSubscriptionStringInput? = nil, color: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionHabitFilterInput?]? = nil, or: [ModelSubscriptionHabitFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["name"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var icon: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["icon"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "icon")
    }
  }

  public var mood: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["mood"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mood")
    }
  }

  public var days: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["days"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "days")
    }
  }

  public var description: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["description"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var time: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["time"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var plan: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["plan"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "plan")
    }
  }

  public var log: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["log"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "log")
    }
  }

  public var color: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["color"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "color")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionHabitFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionHabitFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionHabitFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionHabitFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionFutureGoalFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, category: ModelSubscriptionStringInput? = nil, title: ModelSubscriptionStringInput? = nil, done: ModelSubscriptionBooleanInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionFutureGoalFilterInput?]? = nil, or: [ModelSubscriptionFutureGoalFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "category": category, "title": title, "done": done, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var category: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["category"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var title: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["title"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var done: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionFutureGoalFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionFutureGoalFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionFutureGoalFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionFutureGoalFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionYearlyPopupTaskFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, month: ModelSubscriptionStringInput? = nil, title: ModelSubscriptionStringInput? = nil, date: ModelSubscriptionStringInput? = nil, time: ModelSubscriptionStringInput? = nil, done: ModelSubscriptionBooleanInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionYearlyPopupTaskFilterInput?]? = nil, or: [ModelSubscriptionYearlyPopupTaskFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var month: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["month"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "month")
    }
  }

  public var title: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["title"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["date"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var time: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["time"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var done: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionYearlyPopupTaskFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionYearlyPopupTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionYearlyPopupTaskFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionYearlyPopupTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionFocusTaskFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, title: ModelSubscriptionStringInput? = nil, date: ModelSubscriptionStringInput? = nil, done: ModelSubscriptionBooleanInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionFocusTaskFilterInput?]? = nil, or: [ModelSubscriptionFocusTaskFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "title": title, "date": date, "done": done, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["title"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var date: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["date"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var done: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["done"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "done")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionFocusTaskFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionFocusTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionFocusTaskFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionFocusTaskFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionMonthlyEventFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, title: ModelSubscriptionStringInput? = nil, start: ModelSubscriptionStringInput? = nil, end: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionMonthlyEventFilterInput?]? = nil, or: [ModelSubscriptionMonthlyEventFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "title": title, "start": start, "end": end, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["title"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var start: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["start"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "start")
    }
  }

  public var end: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["end"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "end")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionMonthlyEventFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionMonthlyEventFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionMonthlyEventFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionMonthlyEventFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionGoogleAuthFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, token: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionGoogleAuthFilterInput?]? = nil, or: [ModelSubscriptionGoogleAuthFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "token": token, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var token: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["token"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionGoogleAuthFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionGoogleAuthFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionGoogleAuthFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionGoogleAuthFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionUserSettingsFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, googleToken: ModelSubscriptionStringInput? = nil, isSynced: ModelSubscriptionBooleanInput? = nil, theme: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionUserSettingsFilterInput?]? = nil, or: [ModelSubscriptionUserSettingsFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var googleToken: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["googleToken"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "googleToken")
    }
  }

  public var isSynced: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["isSynced"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isSynced")
    }
  }

  public var theme: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["theme"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "theme")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionUserSettingsFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionUserSettingsFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionUserSettingsFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionUserSettingsFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public final class CreateBucketItemMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateBucketItem($input: CreateBucketItemInput!, $condition: ModelBucketItemConditionInput) {\n  createBucketItem(input: $input, condition: $condition) {\n    __typename\n    id\n    text\n    category\n    date\n    link\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateBucketItemInput
  public var condition: ModelBucketItemConditionInput?

  public init(input: CreateBucketItemInput, condition: ModelBucketItemConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createBucketItem", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateBucketItem.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createBucketItem: CreateBucketItem? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createBucketItem": createBucketItem.flatMap { $0.snapshot }])
    }

    public var createBucketItem: CreateBucketItem? {
      get {
        return (snapshot["createBucketItem"] as? Snapshot).flatMap { CreateBucketItem(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createBucketItem")
      }
    }

    public struct CreateBucketItem: GraphQLSelectionSet {
      public static let possibleTypes = ["BucketItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .scalar(String.self)),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("link", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "BucketItem", "id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var category: String? {
        get {
          return snapshot["category"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var link: String? {
        get {
          return snapshot["link"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateBucketItemMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateBucketItem($input: UpdateBucketItemInput!, $condition: ModelBucketItemConditionInput) {\n  updateBucketItem(input: $input, condition: $condition) {\n    __typename\n    id\n    text\n    category\n    date\n    link\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateBucketItemInput
  public var condition: ModelBucketItemConditionInput?

  public init(input: UpdateBucketItemInput, condition: ModelBucketItemConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateBucketItem", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateBucketItem.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateBucketItem: UpdateBucketItem? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateBucketItem": updateBucketItem.flatMap { $0.snapshot }])
    }

    public var updateBucketItem: UpdateBucketItem? {
      get {
        return (snapshot["updateBucketItem"] as? Snapshot).flatMap { UpdateBucketItem(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateBucketItem")
      }
    }

    public struct UpdateBucketItem: GraphQLSelectionSet {
      public static let possibleTypes = ["BucketItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .scalar(String.self)),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("link", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "BucketItem", "id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var category: String? {
        get {
          return snapshot["category"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var link: String? {
        get {
          return snapshot["link"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteBucketItemMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteBucketItem($input: DeleteBucketItemInput!, $condition: ModelBucketItemConditionInput) {\n  deleteBucketItem(input: $input, condition: $condition) {\n    __typename\n    id\n    text\n    category\n    date\n    link\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteBucketItemInput
  public var condition: ModelBucketItemConditionInput?

  public init(input: DeleteBucketItemInput, condition: ModelBucketItemConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteBucketItem", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteBucketItem.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteBucketItem: DeleteBucketItem? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteBucketItem": deleteBucketItem.flatMap { $0.snapshot }])
    }

    public var deleteBucketItem: DeleteBucketItem? {
      get {
        return (snapshot["deleteBucketItem"] as? Snapshot).flatMap { DeleteBucketItem(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteBucketItem")
      }
    }

    public struct DeleteBucketItem: GraphQLSelectionSet {
      public static let possibleTypes = ["BucketItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .scalar(String.self)),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("link", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "BucketItem", "id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var category: String? {
        get {
          return snapshot["category"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var link: String? {
        get {
          return snapshot["link"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateYearlyGoalMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateYearlyGoal($input: CreateYearlyGoalInput!, $condition: ModelYearlyGoalConditionInput) {\n  createYearlyGoal(input: $input, condition: $condition) {\n    __typename\n    id\n    year\n    title\n    details\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateYearlyGoalInput
  public var condition: ModelYearlyGoalConditionInput?

  public init(input: CreateYearlyGoalInput, condition: ModelYearlyGoalConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createYearlyGoal", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateYearlyGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createYearlyGoal: CreateYearlyGoal? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createYearlyGoal": createYearlyGoal.flatMap { $0.snapshot }])
    }

    public var createYearlyGoal: CreateYearlyGoal? {
      get {
        return (snapshot["createYearlyGoal"] as? Snapshot).flatMap { CreateYearlyGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createYearlyGoal")
      }
    }

    public struct CreateYearlyGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("details", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyGoal", "id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var details: String? {
        get {
          return snapshot["details"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "details")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateYearlyGoalMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateYearlyGoal($input: UpdateYearlyGoalInput!, $condition: ModelYearlyGoalConditionInput) {\n  updateYearlyGoal(input: $input, condition: $condition) {\n    __typename\n    id\n    year\n    title\n    details\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateYearlyGoalInput
  public var condition: ModelYearlyGoalConditionInput?

  public init(input: UpdateYearlyGoalInput, condition: ModelYearlyGoalConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateYearlyGoal", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateYearlyGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateYearlyGoal: UpdateYearlyGoal? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateYearlyGoal": updateYearlyGoal.flatMap { $0.snapshot }])
    }

    public var updateYearlyGoal: UpdateYearlyGoal? {
      get {
        return (snapshot["updateYearlyGoal"] as? Snapshot).flatMap { UpdateYearlyGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateYearlyGoal")
      }
    }

    public struct UpdateYearlyGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("details", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyGoal", "id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var details: String? {
        get {
          return snapshot["details"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "details")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteYearlyGoalMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteYearlyGoal($input: DeleteYearlyGoalInput!, $condition: ModelYearlyGoalConditionInput) {\n  deleteYearlyGoal(input: $input, condition: $condition) {\n    __typename\n    id\n    year\n    title\n    details\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteYearlyGoalInput
  public var condition: ModelYearlyGoalConditionInput?

  public init(input: DeleteYearlyGoalInput, condition: ModelYearlyGoalConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteYearlyGoal", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteYearlyGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteYearlyGoal: DeleteYearlyGoal? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteYearlyGoal": deleteYearlyGoal.flatMap { $0.snapshot }])
    }

    public var deleteYearlyGoal: DeleteYearlyGoal? {
      get {
        return (snapshot["deleteYearlyGoal"] as? Snapshot).flatMap { DeleteYearlyGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteYearlyGoal")
      }
    }

    public struct DeleteYearlyGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("details", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyGoal", "id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var details: String? {
        get {
          return snapshot["details"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "details")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateDailyTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateDailyTask($input: CreateDailyTaskInput!, $condition: ModelDailyTaskConditionInput) {\n  createDailyTask(input: $input, condition: $condition) {\n    __typename\n    id\n    date\n    text\n    time\n    duration\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateDailyTaskInput
  public var condition: ModelDailyTaskConditionInput?

  public init(input: CreateDailyTaskInput, condition: ModelDailyTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createDailyTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateDailyTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createDailyTask: CreateDailyTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createDailyTask": createDailyTask.flatMap { $0.snapshot }])
    }

    public var createDailyTask: CreateDailyTask? {
      get {
        return (snapshot["createDailyTask"] as? Snapshot).flatMap { CreateDailyTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createDailyTask")
      }
    }

    public struct CreateDailyTask: GraphQLSelectionSet {
      public static let possibleTypes = ["DailyTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("duration", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "DailyTask", "id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var duration: String? {
        get {
          return snapshot["duration"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateDailyTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateDailyTask($input: UpdateDailyTaskInput!, $condition: ModelDailyTaskConditionInput) {\n  updateDailyTask(input: $input, condition: $condition) {\n    __typename\n    id\n    date\n    text\n    time\n    duration\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateDailyTaskInput
  public var condition: ModelDailyTaskConditionInput?

  public init(input: UpdateDailyTaskInput, condition: ModelDailyTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateDailyTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateDailyTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateDailyTask: UpdateDailyTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateDailyTask": updateDailyTask.flatMap { $0.snapshot }])
    }

    public var updateDailyTask: UpdateDailyTask? {
      get {
        return (snapshot["updateDailyTask"] as? Snapshot).flatMap { UpdateDailyTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateDailyTask")
      }
    }

    public struct UpdateDailyTask: GraphQLSelectionSet {
      public static let possibleTypes = ["DailyTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("duration", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "DailyTask", "id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var duration: String? {
        get {
          return snapshot["duration"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteDailyTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteDailyTask($input: DeleteDailyTaskInput!, $condition: ModelDailyTaskConditionInput) {\n  deleteDailyTask(input: $input, condition: $condition) {\n    __typename\n    id\n    date\n    text\n    time\n    duration\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteDailyTaskInput
  public var condition: ModelDailyTaskConditionInput?

  public init(input: DeleteDailyTaskInput, condition: ModelDailyTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteDailyTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteDailyTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteDailyTask: DeleteDailyTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteDailyTask": deleteDailyTask.flatMap { $0.snapshot }])
    }

    public var deleteDailyTask: DeleteDailyTask? {
      get {
        return (snapshot["deleteDailyTask"] as? Snapshot).flatMap { DeleteDailyTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteDailyTask")
      }
    }

    public struct DeleteDailyTask: GraphQLSelectionSet {
      public static let possibleTypes = ["DailyTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("duration", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "DailyTask", "id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var duration: String? {
        get {
          return snapshot["duration"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateHabitMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateHabit($input: CreateHabitInput!, $condition: ModelHabitConditionInput) {\n  createHabit(input: $input, condition: $condition) {\n    __typename\n    id\n    name\n    icon\n    mood\n    days\n    description\n    time\n    plan\n    log\n    color\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateHabitInput
  public var condition: ModelHabitConditionInput?

  public init(input: CreateHabitInput, condition: ModelHabitConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createHabit", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateHabit.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createHabit: CreateHabit? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createHabit": createHabit.flatMap { $0.snapshot }])
    }

    public var createHabit: CreateHabit? {
      get {
        return (snapshot["createHabit"] as? Snapshot).flatMap { CreateHabit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createHabit")
      }
    }

    public struct CreateHabit: GraphQLSelectionSet {
      public static let possibleTypes = ["Habit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("icon", type: .scalar(String.self)),
        GraphQLField("mood", type: .scalar(String.self)),
        GraphQLField("days", type: .list(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("plan", type: .scalar(String.self)),
        GraphQLField("log", type: .scalar(String.self)),
        GraphQLField("color", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "Habit", "id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var icon: String? {
        get {
          return snapshot["icon"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "icon")
        }
      }

      public var mood: String? {
        get {
          return snapshot["mood"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "mood")
        }
      }

      public var days: [String?]? {
        get {
          return snapshot["days"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "days")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var plan: String? {
        get {
          return snapshot["plan"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "plan")
        }
      }

      public var log: String? {
        get {
          return snapshot["log"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "log")
        }
      }

      public var color: String? {
        get {
          return snapshot["color"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "color")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateHabitMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateHabit($input: UpdateHabitInput!, $condition: ModelHabitConditionInput) {\n  updateHabit(input: $input, condition: $condition) {\n    __typename\n    id\n    name\n    icon\n    mood\n    days\n    description\n    time\n    plan\n    log\n    color\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateHabitInput
  public var condition: ModelHabitConditionInput?

  public init(input: UpdateHabitInput, condition: ModelHabitConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateHabit", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateHabit.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateHabit: UpdateHabit? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateHabit": updateHabit.flatMap { $0.snapshot }])
    }

    public var updateHabit: UpdateHabit? {
      get {
        return (snapshot["updateHabit"] as? Snapshot).flatMap { UpdateHabit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateHabit")
      }
    }

    public struct UpdateHabit: GraphQLSelectionSet {
      public static let possibleTypes = ["Habit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("icon", type: .scalar(String.self)),
        GraphQLField("mood", type: .scalar(String.self)),
        GraphQLField("days", type: .list(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("plan", type: .scalar(String.self)),
        GraphQLField("log", type: .scalar(String.self)),
        GraphQLField("color", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "Habit", "id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var icon: String? {
        get {
          return snapshot["icon"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "icon")
        }
      }

      public var mood: String? {
        get {
          return snapshot["mood"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "mood")
        }
      }

      public var days: [String?]? {
        get {
          return snapshot["days"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "days")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var plan: String? {
        get {
          return snapshot["plan"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "plan")
        }
      }

      public var log: String? {
        get {
          return snapshot["log"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "log")
        }
      }

      public var color: String? {
        get {
          return snapshot["color"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "color")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteHabitMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteHabit($input: DeleteHabitInput!, $condition: ModelHabitConditionInput) {\n  deleteHabit(input: $input, condition: $condition) {\n    __typename\n    id\n    name\n    icon\n    mood\n    days\n    description\n    time\n    plan\n    log\n    color\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteHabitInput
  public var condition: ModelHabitConditionInput?

  public init(input: DeleteHabitInput, condition: ModelHabitConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteHabit", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteHabit.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteHabit: DeleteHabit? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteHabit": deleteHabit.flatMap { $0.snapshot }])
    }

    public var deleteHabit: DeleteHabit? {
      get {
        return (snapshot["deleteHabit"] as? Snapshot).flatMap { DeleteHabit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteHabit")
      }
    }

    public struct DeleteHabit: GraphQLSelectionSet {
      public static let possibleTypes = ["Habit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("icon", type: .scalar(String.self)),
        GraphQLField("mood", type: .scalar(String.self)),
        GraphQLField("days", type: .list(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("plan", type: .scalar(String.self)),
        GraphQLField("log", type: .scalar(String.self)),
        GraphQLField("color", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "Habit", "id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var icon: String? {
        get {
          return snapshot["icon"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "icon")
        }
      }

      public var mood: String? {
        get {
          return snapshot["mood"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "mood")
        }
      }

      public var days: [String?]? {
        get {
          return snapshot["days"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "days")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var plan: String? {
        get {
          return snapshot["plan"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "plan")
        }
      }

      public var log: String? {
        get {
          return snapshot["log"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "log")
        }
      }

      public var color: String? {
        get {
          return snapshot["color"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "color")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateFutureGoalMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateFutureGoal($input: CreateFutureGoalInput!, $condition: ModelFutureGoalConditionInput) {\n  createFutureGoal(input: $input, condition: $condition) {\n    __typename\n    id\n    category\n    title\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateFutureGoalInput
  public var condition: ModelFutureGoalConditionInput?

  public init(input: CreateFutureGoalInput, condition: ModelFutureGoalConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createFutureGoal", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateFutureGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createFutureGoal: CreateFutureGoal? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createFutureGoal": createFutureGoal.flatMap { $0.snapshot }])
    }

    public var createFutureGoal: CreateFutureGoal? {
      get {
        return (snapshot["createFutureGoal"] as? Snapshot).flatMap { CreateFutureGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createFutureGoal")
      }
    }

    public struct CreateFutureGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["FutureGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("category", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, category: String, title: String, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FutureGoal", "id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var category: String {
        get {
          return snapshot["category"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateFutureGoalMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateFutureGoal($input: UpdateFutureGoalInput!, $condition: ModelFutureGoalConditionInput) {\n  updateFutureGoal(input: $input, condition: $condition) {\n    __typename\n    id\n    category\n    title\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateFutureGoalInput
  public var condition: ModelFutureGoalConditionInput?

  public init(input: UpdateFutureGoalInput, condition: ModelFutureGoalConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateFutureGoal", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateFutureGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateFutureGoal: UpdateFutureGoal? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateFutureGoal": updateFutureGoal.flatMap { $0.snapshot }])
    }

    public var updateFutureGoal: UpdateFutureGoal? {
      get {
        return (snapshot["updateFutureGoal"] as? Snapshot).flatMap { UpdateFutureGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateFutureGoal")
      }
    }

    public struct UpdateFutureGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["FutureGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("category", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, category: String, title: String, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FutureGoal", "id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var category: String {
        get {
          return snapshot["category"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteFutureGoalMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteFutureGoal($input: DeleteFutureGoalInput!, $condition: ModelFutureGoalConditionInput) {\n  deleteFutureGoal(input: $input, condition: $condition) {\n    __typename\n    id\n    category\n    title\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteFutureGoalInput
  public var condition: ModelFutureGoalConditionInput?

  public init(input: DeleteFutureGoalInput, condition: ModelFutureGoalConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteFutureGoal", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteFutureGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteFutureGoal: DeleteFutureGoal? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteFutureGoal": deleteFutureGoal.flatMap { $0.snapshot }])
    }

    public var deleteFutureGoal: DeleteFutureGoal? {
      get {
        return (snapshot["deleteFutureGoal"] as? Snapshot).flatMap { DeleteFutureGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteFutureGoal")
      }
    }

    public struct DeleteFutureGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["FutureGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("category", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, category: String, title: String, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FutureGoal", "id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var category: String {
        get {
          return snapshot["category"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateYearlyPopupTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateYearlyPopupTask($input: CreateYearlyPopupTaskInput!, $condition: ModelYearlyPopupTaskConditionInput) {\n  createYearlyPopupTask(input: $input, condition: $condition) {\n    __typename\n    id\n    month\n    title\n    date\n    time\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateYearlyPopupTaskInput
  public var condition: ModelYearlyPopupTaskConditionInput?

  public init(input: CreateYearlyPopupTaskInput, condition: ModelYearlyPopupTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createYearlyPopupTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateYearlyPopupTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createYearlyPopupTask: CreateYearlyPopupTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createYearlyPopupTask": createYearlyPopupTask.flatMap { $0.snapshot }])
    }

    public var createYearlyPopupTask: CreateYearlyPopupTask? {
      get {
        return (snapshot["createYearlyPopupTask"] as? Snapshot).flatMap { CreateYearlyPopupTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createYearlyPopupTask")
      }
    }

    public struct CreateYearlyPopupTask: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyPopupTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("month", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyPopupTask", "id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var month: String {
        get {
          return snapshot["month"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "month")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateYearlyPopupTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateYearlyPopupTask($input: UpdateYearlyPopupTaskInput!, $condition: ModelYearlyPopupTaskConditionInput) {\n  updateYearlyPopupTask(input: $input, condition: $condition) {\n    __typename\n    id\n    month\n    title\n    date\n    time\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateYearlyPopupTaskInput
  public var condition: ModelYearlyPopupTaskConditionInput?

  public init(input: UpdateYearlyPopupTaskInput, condition: ModelYearlyPopupTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateYearlyPopupTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateYearlyPopupTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateYearlyPopupTask: UpdateYearlyPopupTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateYearlyPopupTask": updateYearlyPopupTask.flatMap { $0.snapshot }])
    }

    public var updateYearlyPopupTask: UpdateYearlyPopupTask? {
      get {
        return (snapshot["updateYearlyPopupTask"] as? Snapshot).flatMap { UpdateYearlyPopupTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateYearlyPopupTask")
      }
    }

    public struct UpdateYearlyPopupTask: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyPopupTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("month", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyPopupTask", "id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var month: String {
        get {
          return snapshot["month"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "month")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteYearlyPopupTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteYearlyPopupTask($input: DeleteYearlyPopupTaskInput!, $condition: ModelYearlyPopupTaskConditionInput) {\n  deleteYearlyPopupTask(input: $input, condition: $condition) {\n    __typename\n    id\n    month\n    title\n    date\n    time\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteYearlyPopupTaskInput
  public var condition: ModelYearlyPopupTaskConditionInput?

  public init(input: DeleteYearlyPopupTaskInput, condition: ModelYearlyPopupTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteYearlyPopupTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteYearlyPopupTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteYearlyPopupTask: DeleteYearlyPopupTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteYearlyPopupTask": deleteYearlyPopupTask.flatMap { $0.snapshot }])
    }

    public var deleteYearlyPopupTask: DeleteYearlyPopupTask? {
      get {
        return (snapshot["deleteYearlyPopupTask"] as? Snapshot).flatMap { DeleteYearlyPopupTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteYearlyPopupTask")
      }
    }

    public struct DeleteYearlyPopupTask: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyPopupTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("month", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyPopupTask", "id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var month: String {
        get {
          return snapshot["month"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "month")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateFocusTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateFocusTask($input: CreateFocusTaskInput!, $condition: ModelFocusTaskConditionInput) {\n  createFocusTask(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    date\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateFocusTaskInput
  public var condition: ModelFocusTaskConditionInput?

  public init(input: CreateFocusTaskInput, condition: ModelFocusTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createFocusTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateFocusTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createFocusTask: CreateFocusTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createFocusTask": createFocusTask.flatMap { $0.snapshot }])
    }

    public var createFocusTask: CreateFocusTask? {
      get {
        return (snapshot["createFocusTask"] as? Snapshot).flatMap { CreateFocusTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createFocusTask")
      }
    }

    public struct CreateFocusTask: GraphQLSelectionSet {
      public static let possibleTypes = ["FocusTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FocusTask", "id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateFocusTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateFocusTask($input: UpdateFocusTaskInput!, $condition: ModelFocusTaskConditionInput) {\n  updateFocusTask(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    date\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateFocusTaskInput
  public var condition: ModelFocusTaskConditionInput?

  public init(input: UpdateFocusTaskInput, condition: ModelFocusTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateFocusTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateFocusTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateFocusTask: UpdateFocusTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateFocusTask": updateFocusTask.flatMap { $0.snapshot }])
    }

    public var updateFocusTask: UpdateFocusTask? {
      get {
        return (snapshot["updateFocusTask"] as? Snapshot).flatMap { UpdateFocusTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateFocusTask")
      }
    }

    public struct UpdateFocusTask: GraphQLSelectionSet {
      public static let possibleTypes = ["FocusTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FocusTask", "id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteFocusTaskMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteFocusTask($input: DeleteFocusTaskInput!, $condition: ModelFocusTaskConditionInput) {\n  deleteFocusTask(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    date\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteFocusTaskInput
  public var condition: ModelFocusTaskConditionInput?

  public init(input: DeleteFocusTaskInput, condition: ModelFocusTaskConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteFocusTask", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteFocusTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteFocusTask: DeleteFocusTask? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteFocusTask": deleteFocusTask.flatMap { $0.snapshot }])
    }

    public var deleteFocusTask: DeleteFocusTask? {
      get {
        return (snapshot["deleteFocusTask"] as? Snapshot).flatMap { DeleteFocusTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteFocusTask")
      }
    }

    public struct DeleteFocusTask: GraphQLSelectionSet {
      public static let possibleTypes = ["FocusTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FocusTask", "id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateMonthlyEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateMonthlyEvent($input: CreateMonthlyEventInput!, $condition: ModelMonthlyEventConditionInput) {\n  createMonthlyEvent(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    start\n    end\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateMonthlyEventInput
  public var condition: ModelMonthlyEventConditionInput?

  public init(input: CreateMonthlyEventInput, condition: ModelMonthlyEventConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createMonthlyEvent", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateMonthlyEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createMonthlyEvent: CreateMonthlyEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createMonthlyEvent": createMonthlyEvent.flatMap { $0.snapshot }])
    }

    public var createMonthlyEvent: CreateMonthlyEvent? {
      get {
        return (snapshot["createMonthlyEvent"] as? Snapshot).flatMap { CreateMonthlyEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createMonthlyEvent")
      }
    }

    public struct CreateMonthlyEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["MonthlyEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("start", type: .nonNull(.scalar(String.self))),
        GraphQLField("end", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, start: String, end: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "MonthlyEvent", "id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var start: String {
        get {
          return snapshot["start"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "start")
        }
      }

      public var end: String {
        get {
          return snapshot["end"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "end")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateMonthlyEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateMonthlyEvent($input: UpdateMonthlyEventInput!, $condition: ModelMonthlyEventConditionInput) {\n  updateMonthlyEvent(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    start\n    end\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateMonthlyEventInput
  public var condition: ModelMonthlyEventConditionInput?

  public init(input: UpdateMonthlyEventInput, condition: ModelMonthlyEventConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateMonthlyEvent", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateMonthlyEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateMonthlyEvent: UpdateMonthlyEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateMonthlyEvent": updateMonthlyEvent.flatMap { $0.snapshot }])
    }

    public var updateMonthlyEvent: UpdateMonthlyEvent? {
      get {
        return (snapshot["updateMonthlyEvent"] as? Snapshot).flatMap { UpdateMonthlyEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateMonthlyEvent")
      }
    }

    public struct UpdateMonthlyEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["MonthlyEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("start", type: .nonNull(.scalar(String.self))),
        GraphQLField("end", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, start: String, end: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "MonthlyEvent", "id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var start: String {
        get {
          return snapshot["start"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "start")
        }
      }

      public var end: String {
        get {
          return snapshot["end"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "end")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteMonthlyEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteMonthlyEvent($input: DeleteMonthlyEventInput!, $condition: ModelMonthlyEventConditionInput) {\n  deleteMonthlyEvent(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    start\n    end\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteMonthlyEventInput
  public var condition: ModelMonthlyEventConditionInput?

  public init(input: DeleteMonthlyEventInput, condition: ModelMonthlyEventConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteMonthlyEvent", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteMonthlyEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteMonthlyEvent: DeleteMonthlyEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteMonthlyEvent": deleteMonthlyEvent.flatMap { $0.snapshot }])
    }

    public var deleteMonthlyEvent: DeleteMonthlyEvent? {
      get {
        return (snapshot["deleteMonthlyEvent"] as? Snapshot).flatMap { DeleteMonthlyEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteMonthlyEvent")
      }
    }

    public struct DeleteMonthlyEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["MonthlyEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("start", type: .nonNull(.scalar(String.self))),
        GraphQLField("end", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, start: String, end: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "MonthlyEvent", "id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var start: String {
        get {
          return snapshot["start"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "start")
        }
      }

      public var end: String {
        get {
          return snapshot["end"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "end")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateGoogleAuthMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateGoogleAuth($input: CreateGoogleAuthInput!, $condition: ModelGoogleAuthConditionInput) {\n  createGoogleAuth(input: $input, condition: $condition) {\n    __typename\n    id\n    token\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateGoogleAuthInput
  public var condition: ModelGoogleAuthConditionInput?

  public init(input: CreateGoogleAuthInput, condition: ModelGoogleAuthConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createGoogleAuth", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateGoogleAuth.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createGoogleAuth: CreateGoogleAuth? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createGoogleAuth": createGoogleAuth.flatMap { $0.snapshot }])
    }

    public var createGoogleAuth: CreateGoogleAuth? {
      get {
        return (snapshot["createGoogleAuth"] as? Snapshot).flatMap { CreateGoogleAuth(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createGoogleAuth")
      }
    }

    public struct CreateGoogleAuth: GraphQLSelectionSet {
      public static let possibleTypes = ["GoogleAuth"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("token", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, token: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "GoogleAuth", "id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var token: String {
        get {
          return snapshot["token"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "token")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateGoogleAuthMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateGoogleAuth($input: UpdateGoogleAuthInput!, $condition: ModelGoogleAuthConditionInput) {\n  updateGoogleAuth(input: $input, condition: $condition) {\n    __typename\n    id\n    token\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateGoogleAuthInput
  public var condition: ModelGoogleAuthConditionInput?

  public init(input: UpdateGoogleAuthInput, condition: ModelGoogleAuthConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateGoogleAuth", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateGoogleAuth.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateGoogleAuth: UpdateGoogleAuth? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateGoogleAuth": updateGoogleAuth.flatMap { $0.snapshot }])
    }

    public var updateGoogleAuth: UpdateGoogleAuth? {
      get {
        return (snapshot["updateGoogleAuth"] as? Snapshot).flatMap { UpdateGoogleAuth(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateGoogleAuth")
      }
    }

    public struct UpdateGoogleAuth: GraphQLSelectionSet {
      public static let possibleTypes = ["GoogleAuth"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("token", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, token: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "GoogleAuth", "id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var token: String {
        get {
          return snapshot["token"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "token")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteGoogleAuthMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteGoogleAuth($input: DeleteGoogleAuthInput!, $condition: ModelGoogleAuthConditionInput) {\n  deleteGoogleAuth(input: $input, condition: $condition) {\n    __typename\n    id\n    token\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteGoogleAuthInput
  public var condition: ModelGoogleAuthConditionInput?

  public init(input: DeleteGoogleAuthInput, condition: ModelGoogleAuthConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteGoogleAuth", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteGoogleAuth.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteGoogleAuth: DeleteGoogleAuth? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteGoogleAuth": deleteGoogleAuth.flatMap { $0.snapshot }])
    }

    public var deleteGoogleAuth: DeleteGoogleAuth? {
      get {
        return (snapshot["deleteGoogleAuth"] as? Snapshot).flatMap { DeleteGoogleAuth(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteGoogleAuth")
      }
    }

    public struct DeleteGoogleAuth: GraphQLSelectionSet {
      public static let possibleTypes = ["GoogleAuth"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("token", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, token: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "GoogleAuth", "id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var token: String {
        get {
          return snapshot["token"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "token")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateUserSettingsMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateUserSettings($input: CreateUserSettingsInput!, $condition: ModelUserSettingsConditionInput) {\n  createUserSettings(input: $input, condition: $condition) {\n    __typename\n    id\n    googleToken\n    isSynced\n    theme\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateUserSettingsInput
  public var condition: ModelUserSettingsConditionInput?

  public init(input: CreateUserSettingsInput, condition: ModelUserSettingsConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createUserSettings", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateUserSetting.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createUserSettings: CreateUserSetting? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createUserSettings": createUserSettings.flatMap { $0.snapshot }])
    }

    public var createUserSettings: CreateUserSetting? {
      get {
        return (snapshot["createUserSettings"] as? Snapshot).flatMap { CreateUserSetting(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createUserSettings")
      }
    }

    public struct CreateUserSetting: GraphQLSelectionSet {
      public static let possibleTypes = ["UserSettings"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("googleToken", type: .scalar(String.self)),
        GraphQLField("isSynced", type: .scalar(Bool.self)),
        GraphQLField("theme", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserSettings", "id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var googleToken: String? {
        get {
          return snapshot["googleToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "googleToken")
        }
      }

      public var isSynced: Bool? {
        get {
          return snapshot["isSynced"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isSynced")
        }
      }

      public var theme: String? {
        get {
          return snapshot["theme"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "theme")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateUserSettingsMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateUserSettings($input: UpdateUserSettingsInput!, $condition: ModelUserSettingsConditionInput) {\n  updateUserSettings(input: $input, condition: $condition) {\n    __typename\n    id\n    googleToken\n    isSynced\n    theme\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateUserSettingsInput
  public var condition: ModelUserSettingsConditionInput?

  public init(input: UpdateUserSettingsInput, condition: ModelUserSettingsConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateUserSettings", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateUserSetting.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateUserSettings: UpdateUserSetting? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateUserSettings": updateUserSettings.flatMap { $0.snapshot }])
    }

    public var updateUserSettings: UpdateUserSetting? {
      get {
        return (snapshot["updateUserSettings"] as? Snapshot).flatMap { UpdateUserSetting(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateUserSettings")
      }
    }

    public struct UpdateUserSetting: GraphQLSelectionSet {
      public static let possibleTypes = ["UserSettings"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("googleToken", type: .scalar(String.self)),
        GraphQLField("isSynced", type: .scalar(Bool.self)),
        GraphQLField("theme", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserSettings", "id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var googleToken: String? {
        get {
          return snapshot["googleToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "googleToken")
        }
      }

      public var isSynced: Bool? {
        get {
          return snapshot["isSynced"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isSynced")
        }
      }

      public var theme: String? {
        get {
          return snapshot["theme"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "theme")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteUserSettingsMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteUserSettings($input: DeleteUserSettingsInput!, $condition: ModelUserSettingsConditionInput) {\n  deleteUserSettings(input: $input, condition: $condition) {\n    __typename\n    id\n    googleToken\n    isSynced\n    theme\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteUserSettingsInput
  public var condition: ModelUserSettingsConditionInput?

  public init(input: DeleteUserSettingsInput, condition: ModelUserSettingsConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteUserSettings", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteUserSetting.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteUserSettings: DeleteUserSetting? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteUserSettings": deleteUserSettings.flatMap { $0.snapshot }])
    }

    public var deleteUserSettings: DeleteUserSetting? {
      get {
        return (snapshot["deleteUserSettings"] as? Snapshot).flatMap { DeleteUserSetting(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteUserSettings")
      }
    }

    public struct DeleteUserSetting: GraphQLSelectionSet {
      public static let possibleTypes = ["UserSettings"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("googleToken", type: .scalar(String.self)),
        GraphQLField("isSynced", type: .scalar(Bool.self)),
        GraphQLField("theme", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserSettings", "id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var googleToken: String? {
        get {
          return snapshot["googleToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "googleToken")
        }
      }

      public var isSynced: Bool? {
        get {
          return snapshot["isSynced"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isSynced")
        }
      }

      public var theme: String? {
        get {
          return snapshot["theme"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "theme")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class GetBucketItemQuery: GraphQLQuery {
  public static let operationString =
    "query GetBucketItem($id: ID!) {\n  getBucketItem(id: $id) {\n    __typename\n    id\n    text\n    category\n    date\n    link\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getBucketItem", arguments: ["id": GraphQLVariable("id")], type: .object(GetBucketItem.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getBucketItem: GetBucketItem? = nil) {
      self.init(snapshot: ["__typename": "Query", "getBucketItem": getBucketItem.flatMap { $0.snapshot }])
    }

    public var getBucketItem: GetBucketItem? {
      get {
        return (snapshot["getBucketItem"] as? Snapshot).flatMap { GetBucketItem(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getBucketItem")
      }
    }

    public struct GetBucketItem: GraphQLSelectionSet {
      public static let possibleTypes = ["BucketItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .scalar(String.self)),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("link", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "BucketItem", "id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var category: String? {
        get {
          return snapshot["category"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var link: String? {
        get {
          return snapshot["link"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListBucketItemsQuery: GraphQLQuery {
  public static let operationString =
    "query ListBucketItems($filter: ModelBucketItemFilterInput, $limit: Int, $nextToken: String) {\n  listBucketItems(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      text\n      category\n      date\n      link\n      done\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelBucketItemFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelBucketItemFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listBucketItems", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListBucketItem.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listBucketItems: ListBucketItem? = nil) {
      self.init(snapshot: ["__typename": "Query", "listBucketItems": listBucketItems.flatMap { $0.snapshot }])
    }

    public var listBucketItems: ListBucketItem? {
      get {
        return (snapshot["listBucketItems"] as? Snapshot).flatMap { ListBucketItem(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listBucketItems")
      }
    }

    public struct ListBucketItem: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelBucketItemConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelBucketItemConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["BucketItem"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("text", type: .nonNull(.scalar(String.self))),
          GraphQLField("category", type: .scalar(String.self)),
          GraphQLField("date", type: .scalar(String.self)),
          GraphQLField("link", type: .scalar(String.self)),
          GraphQLField("done", type: .scalar(Bool.self)),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "BucketItem", "id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var text: String {
          get {
            return snapshot["text"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "text")
          }
        }

        public var category: String? {
          get {
            return snapshot["category"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "category")
          }
        }

        public var date: String? {
          get {
            return snapshot["date"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "date")
          }
        }

        public var link: String? {
          get {
            return snapshot["link"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "link")
          }
        }

        public var done: Bool? {
          get {
            return snapshot["done"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "done")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetYearlyGoalQuery: GraphQLQuery {
  public static let operationString =
    "query GetYearlyGoal($id: ID!) {\n  getYearlyGoal(id: $id) {\n    __typename\n    id\n    year\n    title\n    details\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getYearlyGoal", arguments: ["id": GraphQLVariable("id")], type: .object(GetYearlyGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getYearlyGoal: GetYearlyGoal? = nil) {
      self.init(snapshot: ["__typename": "Query", "getYearlyGoal": getYearlyGoal.flatMap { $0.snapshot }])
    }

    public var getYearlyGoal: GetYearlyGoal? {
      get {
        return (snapshot["getYearlyGoal"] as? Snapshot).flatMap { GetYearlyGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getYearlyGoal")
      }
    }

    public struct GetYearlyGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("details", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyGoal", "id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var details: String? {
        get {
          return snapshot["details"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "details")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListYearlyGoalsQuery: GraphQLQuery {
  public static let operationString =
    "query ListYearlyGoals($filter: ModelYearlyGoalFilterInput, $limit: Int, $nextToken: String) {\n  listYearlyGoals(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      year\n      title\n      details\n      order\n      done\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelYearlyGoalFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelYearlyGoalFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listYearlyGoals", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListYearlyGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listYearlyGoals: ListYearlyGoal? = nil) {
      self.init(snapshot: ["__typename": "Query", "listYearlyGoals": listYearlyGoals.flatMap { $0.snapshot }])
    }

    public var listYearlyGoals: ListYearlyGoal? {
      get {
        return (snapshot["listYearlyGoals"] as? Snapshot).flatMap { ListYearlyGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listYearlyGoals")
      }
    }

    public struct ListYearlyGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelYearlyGoalConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelYearlyGoalConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["YearlyGoal"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("year", type: .nonNull(.scalar(Int.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("details", type: .scalar(String.self)),
          GraphQLField("order", type: .scalar(Int.self)),
          GraphQLField("done", type: .scalar(Bool.self)),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "YearlyGoal", "id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var year: Int {
          get {
            return snapshot["year"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "year")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var details: String? {
          get {
            return snapshot["details"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "details")
          }
        }

        public var order: Int? {
          get {
            return snapshot["order"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "order")
          }
        }

        public var done: Bool? {
          get {
            return snapshot["done"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "done")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetDailyTaskQuery: GraphQLQuery {
  public static let operationString =
    "query GetDailyTask($id: ID!) {\n  getDailyTask(id: $id) {\n    __typename\n    id\n    date\n    text\n    time\n    duration\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getDailyTask", arguments: ["id": GraphQLVariable("id")], type: .object(GetDailyTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getDailyTask: GetDailyTask? = nil) {
      self.init(snapshot: ["__typename": "Query", "getDailyTask": getDailyTask.flatMap { $0.snapshot }])
    }

    public var getDailyTask: GetDailyTask? {
      get {
        return (snapshot["getDailyTask"] as? Snapshot).flatMap { GetDailyTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getDailyTask")
      }
    }

    public struct GetDailyTask: GraphQLSelectionSet {
      public static let possibleTypes = ["DailyTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("duration", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "DailyTask", "id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var duration: String? {
        get {
          return snapshot["duration"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListDailyTasksQuery: GraphQLQuery {
  public static let operationString =
    "query ListDailyTasks($filter: ModelDailyTaskFilterInput, $limit: Int, $nextToken: String) {\n  listDailyTasks(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      date\n      text\n      time\n      duration\n      order\n      done\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelDailyTaskFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelDailyTaskFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listDailyTasks", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListDailyTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listDailyTasks: ListDailyTask? = nil) {
      self.init(snapshot: ["__typename": "Query", "listDailyTasks": listDailyTasks.flatMap { $0.snapshot }])
    }

    public var listDailyTasks: ListDailyTask? {
      get {
        return (snapshot["listDailyTasks"] as? Snapshot).flatMap { ListDailyTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listDailyTasks")
      }
    }

    public struct ListDailyTask: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelDailyTaskConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelDailyTaskConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["DailyTask"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("date", type: .nonNull(.scalar(String.self))),
          GraphQLField("text", type: .nonNull(.scalar(String.self))),
          GraphQLField("time", type: .scalar(String.self)),
          GraphQLField("duration", type: .scalar(String.self)),
          GraphQLField("order", type: .scalar(Int.self)),
          GraphQLField("done", type: .scalar(Bool.self)),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "DailyTask", "id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var date: String {
          get {
            return snapshot["date"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "date")
          }
        }

        public var text: String {
          get {
            return snapshot["text"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "text")
          }
        }

        public var time: String? {
          get {
            return snapshot["time"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "time")
          }
        }

        public var duration: String? {
          get {
            return snapshot["duration"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "duration")
          }
        }

        public var order: Int? {
          get {
            return snapshot["order"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "order")
          }
        }

        public var done: Bool? {
          get {
            return snapshot["done"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "done")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetHabitQuery: GraphQLQuery {
  public static let operationString =
    "query GetHabit($id: ID!) {\n  getHabit(id: $id) {\n    __typename\n    id\n    name\n    icon\n    mood\n    days\n    description\n    time\n    plan\n    log\n    color\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getHabit", arguments: ["id": GraphQLVariable("id")], type: .object(GetHabit.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getHabit: GetHabit? = nil) {
      self.init(snapshot: ["__typename": "Query", "getHabit": getHabit.flatMap { $0.snapshot }])
    }

    public var getHabit: GetHabit? {
      get {
        return (snapshot["getHabit"] as? Snapshot).flatMap { GetHabit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getHabit")
      }
    }

    public struct GetHabit: GraphQLSelectionSet {
      public static let possibleTypes = ["Habit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("icon", type: .scalar(String.self)),
        GraphQLField("mood", type: .scalar(String.self)),
        GraphQLField("days", type: .list(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("plan", type: .scalar(String.self)),
        GraphQLField("log", type: .scalar(String.self)),
        GraphQLField("color", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "Habit", "id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var icon: String? {
        get {
          return snapshot["icon"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "icon")
        }
      }

      public var mood: String? {
        get {
          return snapshot["mood"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "mood")
        }
      }

      public var days: [String?]? {
        get {
          return snapshot["days"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "days")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var plan: String? {
        get {
          return snapshot["plan"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "plan")
        }
      }

      public var log: String? {
        get {
          return snapshot["log"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "log")
        }
      }

      public var color: String? {
        get {
          return snapshot["color"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "color")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListHabitsQuery: GraphQLQuery {
  public static let operationString =
    "query ListHabits($filter: ModelHabitFilterInput, $limit: Int, $nextToken: String) {\n  listHabits(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      name\n      icon\n      mood\n      days\n      description\n      time\n      plan\n      log\n      color\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelHabitFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelHabitFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listHabits", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListHabit.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listHabits: ListHabit? = nil) {
      self.init(snapshot: ["__typename": "Query", "listHabits": listHabits.flatMap { $0.snapshot }])
    }

    public var listHabits: ListHabit? {
      get {
        return (snapshot["listHabits"] as? Snapshot).flatMap { ListHabit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listHabits")
      }
    }

    public struct ListHabit: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelHabitConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelHabitConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Habit"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("icon", type: .scalar(String.self)),
          GraphQLField("mood", type: .scalar(String.self)),
          GraphQLField("days", type: .list(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("time", type: .scalar(String.self)),
          GraphQLField("plan", type: .scalar(String.self)),
          GraphQLField("log", type: .scalar(String.self)),
          GraphQLField("color", type: .scalar(String.self)),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "Habit", "id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var icon: String? {
          get {
            return snapshot["icon"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "icon")
          }
        }

        public var mood: String? {
          get {
            return snapshot["mood"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "mood")
          }
        }

        public var days: [String?]? {
          get {
            return snapshot["days"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "days")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var time: String? {
          get {
            return snapshot["time"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "time")
          }
        }

        public var plan: String? {
          get {
            return snapshot["plan"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "plan")
          }
        }

        public var log: String? {
          get {
            return snapshot["log"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "log")
          }
        }

        public var color: String? {
          get {
            return snapshot["color"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "color")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetFutureGoalQuery: GraphQLQuery {
  public static let operationString =
    "query GetFutureGoal($id: ID!) {\n  getFutureGoal(id: $id) {\n    __typename\n    id\n    category\n    title\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getFutureGoal", arguments: ["id": GraphQLVariable("id")], type: .object(GetFutureGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getFutureGoal: GetFutureGoal? = nil) {
      self.init(snapshot: ["__typename": "Query", "getFutureGoal": getFutureGoal.flatMap { $0.snapshot }])
    }

    public var getFutureGoal: GetFutureGoal? {
      get {
        return (snapshot["getFutureGoal"] as? Snapshot).flatMap { GetFutureGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getFutureGoal")
      }
    }

    public struct GetFutureGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["FutureGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("category", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, category: String, title: String, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FutureGoal", "id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var category: String {
        get {
          return snapshot["category"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListFutureGoalsQuery: GraphQLQuery {
  public static let operationString =
    "query ListFutureGoals($filter: ModelFutureGoalFilterInput, $limit: Int, $nextToken: String) {\n  listFutureGoals(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      category\n      title\n      done\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelFutureGoalFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelFutureGoalFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listFutureGoals", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListFutureGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listFutureGoals: ListFutureGoal? = nil) {
      self.init(snapshot: ["__typename": "Query", "listFutureGoals": listFutureGoals.flatMap { $0.snapshot }])
    }

    public var listFutureGoals: ListFutureGoal? {
      get {
        return (snapshot["listFutureGoals"] as? Snapshot).flatMap { ListFutureGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listFutureGoals")
      }
    }

    public struct ListFutureGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelFutureGoalConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelFutureGoalConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["FutureGoal"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("category", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("done", type: .scalar(Bool.self)),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, category: String, title: String, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "FutureGoal", "id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var category: String {
          get {
            return snapshot["category"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "category")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var done: Bool? {
          get {
            return snapshot["done"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "done")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetYearlyPopupTaskQuery: GraphQLQuery {
  public static let operationString =
    "query GetYearlyPopupTask($id: ID!) {\n  getYearlyPopupTask(id: $id) {\n    __typename\n    id\n    month\n    title\n    date\n    time\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getYearlyPopupTask", arguments: ["id": GraphQLVariable("id")], type: .object(GetYearlyPopupTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getYearlyPopupTask: GetYearlyPopupTask? = nil) {
      self.init(snapshot: ["__typename": "Query", "getYearlyPopupTask": getYearlyPopupTask.flatMap { $0.snapshot }])
    }

    public var getYearlyPopupTask: GetYearlyPopupTask? {
      get {
        return (snapshot["getYearlyPopupTask"] as? Snapshot).flatMap { GetYearlyPopupTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getYearlyPopupTask")
      }
    }

    public struct GetYearlyPopupTask: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyPopupTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("month", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyPopupTask", "id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var month: String {
        get {
          return snapshot["month"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "month")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListYearlyPopupTasksQuery: GraphQLQuery {
  public static let operationString =
    "query ListYearlyPopupTasks($filter: ModelYearlyPopupTaskFilterInput, $limit: Int, $nextToken: String) {\n  listYearlyPopupTasks(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      month\n      title\n      date\n      time\n      done\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelYearlyPopupTaskFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelYearlyPopupTaskFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listYearlyPopupTasks", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListYearlyPopupTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listYearlyPopupTasks: ListYearlyPopupTask? = nil) {
      self.init(snapshot: ["__typename": "Query", "listYearlyPopupTasks": listYearlyPopupTasks.flatMap { $0.snapshot }])
    }

    public var listYearlyPopupTasks: ListYearlyPopupTask? {
      get {
        return (snapshot["listYearlyPopupTasks"] as? Snapshot).flatMap { ListYearlyPopupTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listYearlyPopupTasks")
      }
    }

    public struct ListYearlyPopupTask: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelYearlyPopupTaskConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelYearlyPopupTaskConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["YearlyPopupTask"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("month", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("date", type: .scalar(String.self)),
          GraphQLField("time", type: .scalar(String.self)),
          GraphQLField("done", type: .scalar(Bool.self)),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "YearlyPopupTask", "id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var month: String {
          get {
            return snapshot["month"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "month")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var date: String? {
          get {
            return snapshot["date"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "date")
          }
        }

        public var time: String? {
          get {
            return snapshot["time"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "time")
          }
        }

        public var done: Bool? {
          get {
            return snapshot["done"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "done")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetFocusTaskQuery: GraphQLQuery {
  public static let operationString =
    "query GetFocusTask($id: ID!) {\n  getFocusTask(id: $id) {\n    __typename\n    id\n    title\n    date\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getFocusTask", arguments: ["id": GraphQLVariable("id")], type: .object(GetFocusTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getFocusTask: GetFocusTask? = nil) {
      self.init(snapshot: ["__typename": "Query", "getFocusTask": getFocusTask.flatMap { $0.snapshot }])
    }

    public var getFocusTask: GetFocusTask? {
      get {
        return (snapshot["getFocusTask"] as? Snapshot).flatMap { GetFocusTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getFocusTask")
      }
    }

    public struct GetFocusTask: GraphQLSelectionSet {
      public static let possibleTypes = ["FocusTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FocusTask", "id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListFocusTasksQuery: GraphQLQuery {
  public static let operationString =
    "query ListFocusTasks($filter: ModelFocusTaskFilterInput, $limit: Int, $nextToken: String) {\n  listFocusTasks(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      title\n      date\n      done\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelFocusTaskFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelFocusTaskFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listFocusTasks", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListFocusTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listFocusTasks: ListFocusTask? = nil) {
      self.init(snapshot: ["__typename": "Query", "listFocusTasks": listFocusTasks.flatMap { $0.snapshot }])
    }

    public var listFocusTasks: ListFocusTask? {
      get {
        return (snapshot["listFocusTasks"] as? Snapshot).flatMap { ListFocusTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listFocusTasks")
      }
    }

    public struct ListFocusTask: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelFocusTaskConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelFocusTaskConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["FocusTask"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("date", type: .scalar(String.self)),
          GraphQLField("done", type: .scalar(Bool.self)),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "FocusTask", "id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var date: String? {
          get {
            return snapshot["date"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "date")
          }
        }

        public var done: Bool? {
          get {
            return snapshot["done"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "done")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetMonthlyEventQuery: GraphQLQuery {
  public static let operationString =
    "query GetMonthlyEvent($id: ID!) {\n  getMonthlyEvent(id: $id) {\n    __typename\n    id\n    title\n    start\n    end\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getMonthlyEvent", arguments: ["id": GraphQLVariable("id")], type: .object(GetMonthlyEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getMonthlyEvent: GetMonthlyEvent? = nil) {
      self.init(snapshot: ["__typename": "Query", "getMonthlyEvent": getMonthlyEvent.flatMap { $0.snapshot }])
    }

    public var getMonthlyEvent: GetMonthlyEvent? {
      get {
        return (snapshot["getMonthlyEvent"] as? Snapshot).flatMap { GetMonthlyEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getMonthlyEvent")
      }
    }

    public struct GetMonthlyEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["MonthlyEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("start", type: .nonNull(.scalar(String.self))),
        GraphQLField("end", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, start: String, end: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "MonthlyEvent", "id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var start: String {
        get {
          return snapshot["start"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "start")
        }
      }

      public var end: String {
        get {
          return snapshot["end"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "end")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListMonthlyEventsQuery: GraphQLQuery {
  public static let operationString =
    "query ListMonthlyEvents($filter: ModelMonthlyEventFilterInput, $limit: Int, $nextToken: String) {\n  listMonthlyEvents(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      title\n      start\n      end\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelMonthlyEventFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelMonthlyEventFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listMonthlyEvents", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListMonthlyEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listMonthlyEvents: ListMonthlyEvent? = nil) {
      self.init(snapshot: ["__typename": "Query", "listMonthlyEvents": listMonthlyEvents.flatMap { $0.snapshot }])
    }

    public var listMonthlyEvents: ListMonthlyEvent? {
      get {
        return (snapshot["listMonthlyEvents"] as? Snapshot).flatMap { ListMonthlyEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listMonthlyEvents")
      }
    }

    public struct ListMonthlyEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelMonthlyEventConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelMonthlyEventConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["MonthlyEvent"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("start", type: .nonNull(.scalar(String.self))),
          GraphQLField("end", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, title: String, start: String, end: String, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "MonthlyEvent", "id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var start: String {
          get {
            return snapshot["start"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "start")
          }
        }

        public var end: String {
          get {
            return snapshot["end"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "end")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetGoogleAuthQuery: GraphQLQuery {
  public static let operationString =
    "query GetGoogleAuth($id: ID!) {\n  getGoogleAuth(id: $id) {\n    __typename\n    id\n    token\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getGoogleAuth", arguments: ["id": GraphQLVariable("id")], type: .object(GetGoogleAuth.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getGoogleAuth: GetGoogleAuth? = nil) {
      self.init(snapshot: ["__typename": "Query", "getGoogleAuth": getGoogleAuth.flatMap { $0.snapshot }])
    }

    public var getGoogleAuth: GetGoogleAuth? {
      get {
        return (snapshot["getGoogleAuth"] as? Snapshot).flatMap { GetGoogleAuth(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getGoogleAuth")
      }
    }

    public struct GetGoogleAuth: GraphQLSelectionSet {
      public static let possibleTypes = ["GoogleAuth"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("token", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, token: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "GoogleAuth", "id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var token: String {
        get {
          return snapshot["token"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "token")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListGoogleAuthsQuery: GraphQLQuery {
  public static let operationString =
    "query ListGoogleAuths($filter: ModelGoogleAuthFilterInput, $limit: Int, $nextToken: String) {\n  listGoogleAuths(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      token\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelGoogleAuthFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelGoogleAuthFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listGoogleAuths", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListGoogleAuth.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listGoogleAuths: ListGoogleAuth? = nil) {
      self.init(snapshot: ["__typename": "Query", "listGoogleAuths": listGoogleAuths.flatMap { $0.snapshot }])
    }

    public var listGoogleAuths: ListGoogleAuth? {
      get {
        return (snapshot["listGoogleAuths"] as? Snapshot).flatMap { ListGoogleAuth(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listGoogleAuths")
      }
    }

    public struct ListGoogleAuth: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelGoogleAuthConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelGoogleAuthConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["GoogleAuth"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("token", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, token: String, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "GoogleAuth", "id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var token: String {
          get {
            return snapshot["token"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "token")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetUserSettingsQuery: GraphQLQuery {
  public static let operationString =
    "query GetUserSettings($id: ID!) {\n  getUserSettings(id: $id) {\n    __typename\n    id\n    googleToken\n    isSynced\n    theme\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getUserSettings", arguments: ["id": GraphQLVariable("id")], type: .object(GetUserSetting.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getUserSettings: GetUserSetting? = nil) {
      self.init(snapshot: ["__typename": "Query", "getUserSettings": getUserSettings.flatMap { $0.snapshot }])
    }

    public var getUserSettings: GetUserSetting? {
      get {
        return (snapshot["getUserSettings"] as? Snapshot).flatMap { GetUserSetting(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getUserSettings")
      }
    }

    public struct GetUserSetting: GraphQLSelectionSet {
      public static let possibleTypes = ["UserSettings"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("googleToken", type: .scalar(String.self)),
        GraphQLField("isSynced", type: .scalar(Bool.self)),
        GraphQLField("theme", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserSettings", "id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var googleToken: String? {
        get {
          return snapshot["googleToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "googleToken")
        }
      }

      public var isSynced: Bool? {
        get {
          return snapshot["isSynced"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isSynced")
        }
      }

      public var theme: String? {
        get {
          return snapshot["theme"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "theme")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListUserSettingsQuery: GraphQLQuery {
  public static let operationString =
    "query ListUserSettings($filter: ModelUserSettingsFilterInput, $limit: Int, $nextToken: String) {\n  listUserSettings(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      googleToken\n      isSynced\n      theme\n      owner\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelUserSettingsFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelUserSettingsFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listUserSettings", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListUserSetting.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listUserSettings: ListUserSetting? = nil) {
      self.init(snapshot: ["__typename": "Query", "listUserSettings": listUserSettings.flatMap { $0.snapshot }])
    }

    public var listUserSettings: ListUserSetting? {
      get {
        return (snapshot["listUserSettings"] as? Snapshot).flatMap { ListUserSetting(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listUserSettings")
      }
    }

    public struct ListUserSetting: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelUserSettingsConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelUserSettingsConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["UserSettings"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("googleToken", type: .scalar(String.self)),
          GraphQLField("isSynced", type: .scalar(Bool.self)),
          GraphQLField("theme", type: .scalar(String.self)),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserSettings", "id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var googleToken: String? {
          get {
            return snapshot["googleToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "googleToken")
          }
        }

        public var isSynced: Bool? {
          get {
            return snapshot["isSynced"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isSynced")
          }
        }

        public var theme: String? {
          get {
            return snapshot["theme"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "theme")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnCreateBucketItemSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateBucketItem($filter: ModelSubscriptionBucketItemFilterInput, $owner: String) {\n  onCreateBucketItem(filter: $filter, owner: $owner) {\n    __typename\n    id\n    text\n    category\n    date\n    link\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionBucketItemFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionBucketItemFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateBucketItem", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateBucketItem.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateBucketItem: OnCreateBucketItem? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateBucketItem": onCreateBucketItem.flatMap { $0.snapshot }])
    }

    public var onCreateBucketItem: OnCreateBucketItem? {
      get {
        return (snapshot["onCreateBucketItem"] as? Snapshot).flatMap { OnCreateBucketItem(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateBucketItem")
      }
    }

    public struct OnCreateBucketItem: GraphQLSelectionSet {
      public static let possibleTypes = ["BucketItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .scalar(String.self)),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("link", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "BucketItem", "id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var category: String? {
        get {
          return snapshot["category"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var link: String? {
        get {
          return snapshot["link"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateBucketItemSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateBucketItem($filter: ModelSubscriptionBucketItemFilterInput, $owner: String) {\n  onUpdateBucketItem(filter: $filter, owner: $owner) {\n    __typename\n    id\n    text\n    category\n    date\n    link\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionBucketItemFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionBucketItemFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateBucketItem", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateBucketItem.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateBucketItem: OnUpdateBucketItem? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateBucketItem": onUpdateBucketItem.flatMap { $0.snapshot }])
    }

    public var onUpdateBucketItem: OnUpdateBucketItem? {
      get {
        return (snapshot["onUpdateBucketItem"] as? Snapshot).flatMap { OnUpdateBucketItem(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateBucketItem")
      }
    }

    public struct OnUpdateBucketItem: GraphQLSelectionSet {
      public static let possibleTypes = ["BucketItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .scalar(String.self)),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("link", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "BucketItem", "id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var category: String? {
        get {
          return snapshot["category"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var link: String? {
        get {
          return snapshot["link"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteBucketItemSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteBucketItem($filter: ModelSubscriptionBucketItemFilterInput, $owner: String) {\n  onDeleteBucketItem(filter: $filter, owner: $owner) {\n    __typename\n    id\n    text\n    category\n    date\n    link\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionBucketItemFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionBucketItemFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteBucketItem", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteBucketItem.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteBucketItem: OnDeleteBucketItem? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteBucketItem": onDeleteBucketItem.flatMap { $0.snapshot }])
    }

    public var onDeleteBucketItem: OnDeleteBucketItem? {
      get {
        return (snapshot["onDeleteBucketItem"] as? Snapshot).flatMap { OnDeleteBucketItem(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteBucketItem")
      }
    }

    public struct OnDeleteBucketItem: GraphQLSelectionSet {
      public static let possibleTypes = ["BucketItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .scalar(String.self)),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("link", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, text: String, category: String? = nil, date: String? = nil, link: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "BucketItem", "id": id, "text": text, "category": category, "date": date, "link": link, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var category: String? {
        get {
          return snapshot["category"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var link: String? {
        get {
          return snapshot["link"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateYearlyGoalSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateYearlyGoal($filter: ModelSubscriptionYearlyGoalFilterInput, $owner: String) {\n  onCreateYearlyGoal(filter: $filter, owner: $owner) {\n    __typename\n    id\n    year\n    title\n    details\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionYearlyGoalFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionYearlyGoalFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateYearlyGoal", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateYearlyGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateYearlyGoal: OnCreateYearlyGoal? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateYearlyGoal": onCreateYearlyGoal.flatMap { $0.snapshot }])
    }

    public var onCreateYearlyGoal: OnCreateYearlyGoal? {
      get {
        return (snapshot["onCreateYearlyGoal"] as? Snapshot).flatMap { OnCreateYearlyGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateYearlyGoal")
      }
    }

    public struct OnCreateYearlyGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("details", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyGoal", "id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var details: String? {
        get {
          return snapshot["details"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "details")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateYearlyGoalSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateYearlyGoal($filter: ModelSubscriptionYearlyGoalFilterInput, $owner: String) {\n  onUpdateYearlyGoal(filter: $filter, owner: $owner) {\n    __typename\n    id\n    year\n    title\n    details\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionYearlyGoalFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionYearlyGoalFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateYearlyGoal", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateYearlyGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateYearlyGoal: OnUpdateYearlyGoal? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateYearlyGoal": onUpdateYearlyGoal.flatMap { $0.snapshot }])
    }

    public var onUpdateYearlyGoal: OnUpdateYearlyGoal? {
      get {
        return (snapshot["onUpdateYearlyGoal"] as? Snapshot).flatMap { OnUpdateYearlyGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateYearlyGoal")
      }
    }

    public struct OnUpdateYearlyGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("details", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyGoal", "id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var details: String? {
        get {
          return snapshot["details"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "details")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteYearlyGoalSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteYearlyGoal($filter: ModelSubscriptionYearlyGoalFilterInput, $owner: String) {\n  onDeleteYearlyGoal(filter: $filter, owner: $owner) {\n    __typename\n    id\n    year\n    title\n    details\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionYearlyGoalFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionYearlyGoalFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteYearlyGoal", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteYearlyGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteYearlyGoal: OnDeleteYearlyGoal? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteYearlyGoal": onDeleteYearlyGoal.flatMap { $0.snapshot }])
    }

    public var onDeleteYearlyGoal: OnDeleteYearlyGoal? {
      get {
        return (snapshot["onDeleteYearlyGoal"] as? Snapshot).flatMap { OnDeleteYearlyGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteYearlyGoal")
      }
    }

    public struct OnDeleteYearlyGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("details", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, year: Int, title: String, details: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyGoal", "id": id, "year": year, "title": title, "details": details, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var details: String? {
        get {
          return snapshot["details"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "details")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateDailyTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateDailyTask($filter: ModelSubscriptionDailyTaskFilterInput, $owner: String) {\n  onCreateDailyTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    date\n    text\n    time\n    duration\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionDailyTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionDailyTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateDailyTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateDailyTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateDailyTask: OnCreateDailyTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateDailyTask": onCreateDailyTask.flatMap { $0.snapshot }])
    }

    public var onCreateDailyTask: OnCreateDailyTask? {
      get {
        return (snapshot["onCreateDailyTask"] as? Snapshot).flatMap { OnCreateDailyTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateDailyTask")
      }
    }

    public struct OnCreateDailyTask: GraphQLSelectionSet {
      public static let possibleTypes = ["DailyTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("duration", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "DailyTask", "id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var duration: String? {
        get {
          return snapshot["duration"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateDailyTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateDailyTask($filter: ModelSubscriptionDailyTaskFilterInput, $owner: String) {\n  onUpdateDailyTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    date\n    text\n    time\n    duration\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionDailyTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionDailyTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateDailyTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateDailyTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateDailyTask: OnUpdateDailyTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateDailyTask": onUpdateDailyTask.flatMap { $0.snapshot }])
    }

    public var onUpdateDailyTask: OnUpdateDailyTask? {
      get {
        return (snapshot["onUpdateDailyTask"] as? Snapshot).flatMap { OnUpdateDailyTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateDailyTask")
      }
    }

    public struct OnUpdateDailyTask: GraphQLSelectionSet {
      public static let possibleTypes = ["DailyTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("duration", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "DailyTask", "id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var duration: String? {
        get {
          return snapshot["duration"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteDailyTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteDailyTask($filter: ModelSubscriptionDailyTaskFilterInput, $owner: String) {\n  onDeleteDailyTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    date\n    text\n    time\n    duration\n    order\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionDailyTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionDailyTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteDailyTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteDailyTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteDailyTask: OnDeleteDailyTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteDailyTask": onDeleteDailyTask.flatMap { $0.snapshot }])
    }

    public var onDeleteDailyTask: OnDeleteDailyTask? {
      get {
        return (snapshot["onDeleteDailyTask"] as? Snapshot).flatMap { OnDeleteDailyTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteDailyTask")
      }
    }

    public struct OnDeleteDailyTask: GraphQLSelectionSet {
      public static let possibleTypes = ["DailyTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("duration", type: .scalar(String.self)),
        GraphQLField("order", type: .scalar(Int.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, date: String, text: String, time: String? = nil, duration: String? = nil, order: Int? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "DailyTask", "id": id, "date": date, "text": text, "time": time, "duration": duration, "order": order, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var text: String {
        get {
          return snapshot["text"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "text")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var duration: String? {
        get {
          return snapshot["duration"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var order: Int? {
        get {
          return snapshot["order"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "order")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateHabitSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateHabit($filter: ModelSubscriptionHabitFilterInput, $owner: String) {\n  onCreateHabit(filter: $filter, owner: $owner) {\n    __typename\n    id\n    name\n    icon\n    mood\n    days\n    description\n    time\n    plan\n    log\n    color\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionHabitFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionHabitFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateHabit", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateHabit.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateHabit: OnCreateHabit? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateHabit": onCreateHabit.flatMap { $0.snapshot }])
    }

    public var onCreateHabit: OnCreateHabit? {
      get {
        return (snapshot["onCreateHabit"] as? Snapshot).flatMap { OnCreateHabit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateHabit")
      }
    }

    public struct OnCreateHabit: GraphQLSelectionSet {
      public static let possibleTypes = ["Habit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("icon", type: .scalar(String.self)),
        GraphQLField("mood", type: .scalar(String.self)),
        GraphQLField("days", type: .list(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("plan", type: .scalar(String.self)),
        GraphQLField("log", type: .scalar(String.self)),
        GraphQLField("color", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "Habit", "id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var icon: String? {
        get {
          return snapshot["icon"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "icon")
        }
      }

      public var mood: String? {
        get {
          return snapshot["mood"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "mood")
        }
      }

      public var days: [String?]? {
        get {
          return snapshot["days"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "days")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var plan: String? {
        get {
          return snapshot["plan"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "plan")
        }
      }

      public var log: String? {
        get {
          return snapshot["log"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "log")
        }
      }

      public var color: String? {
        get {
          return snapshot["color"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "color")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateHabitSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateHabit($filter: ModelSubscriptionHabitFilterInput, $owner: String) {\n  onUpdateHabit(filter: $filter, owner: $owner) {\n    __typename\n    id\n    name\n    icon\n    mood\n    days\n    description\n    time\n    plan\n    log\n    color\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionHabitFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionHabitFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateHabit", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateHabit.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateHabit: OnUpdateHabit? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateHabit": onUpdateHabit.flatMap { $0.snapshot }])
    }

    public var onUpdateHabit: OnUpdateHabit? {
      get {
        return (snapshot["onUpdateHabit"] as? Snapshot).flatMap { OnUpdateHabit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateHabit")
      }
    }

    public struct OnUpdateHabit: GraphQLSelectionSet {
      public static let possibleTypes = ["Habit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("icon", type: .scalar(String.self)),
        GraphQLField("mood", type: .scalar(String.self)),
        GraphQLField("days", type: .list(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("plan", type: .scalar(String.self)),
        GraphQLField("log", type: .scalar(String.self)),
        GraphQLField("color", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "Habit", "id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var icon: String? {
        get {
          return snapshot["icon"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "icon")
        }
      }

      public var mood: String? {
        get {
          return snapshot["mood"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "mood")
        }
      }

      public var days: [String?]? {
        get {
          return snapshot["days"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "days")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var plan: String? {
        get {
          return snapshot["plan"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "plan")
        }
      }

      public var log: String? {
        get {
          return snapshot["log"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "log")
        }
      }

      public var color: String? {
        get {
          return snapshot["color"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "color")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteHabitSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteHabit($filter: ModelSubscriptionHabitFilterInput, $owner: String) {\n  onDeleteHabit(filter: $filter, owner: $owner) {\n    __typename\n    id\n    name\n    icon\n    mood\n    days\n    description\n    time\n    plan\n    log\n    color\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionHabitFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionHabitFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteHabit", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteHabit.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteHabit: OnDeleteHabit? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteHabit": onDeleteHabit.flatMap { $0.snapshot }])
    }

    public var onDeleteHabit: OnDeleteHabit? {
      get {
        return (snapshot["onDeleteHabit"] as? Snapshot).flatMap { OnDeleteHabit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteHabit")
      }
    }

    public struct OnDeleteHabit: GraphQLSelectionSet {
      public static let possibleTypes = ["Habit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("icon", type: .scalar(String.self)),
        GraphQLField("mood", type: .scalar(String.self)),
        GraphQLField("days", type: .list(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("plan", type: .scalar(String.self)),
        GraphQLField("log", type: .scalar(String.self)),
        GraphQLField("color", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, icon: String? = nil, mood: String? = nil, days: [String?]? = nil, description: String? = nil, time: String? = nil, plan: String? = nil, log: String? = nil, color: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "Habit", "id": id, "name": name, "icon": icon, "mood": mood, "days": days, "description": description, "time": time, "plan": plan, "log": log, "color": color, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var icon: String? {
        get {
          return snapshot["icon"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "icon")
        }
      }

      public var mood: String? {
        get {
          return snapshot["mood"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "mood")
        }
      }

      public var days: [String?]? {
        get {
          return snapshot["days"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "days")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var plan: String? {
        get {
          return snapshot["plan"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "plan")
        }
      }

      public var log: String? {
        get {
          return snapshot["log"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "log")
        }
      }

      public var color: String? {
        get {
          return snapshot["color"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "color")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateFutureGoalSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateFutureGoal($filter: ModelSubscriptionFutureGoalFilterInput, $owner: String) {\n  onCreateFutureGoal(filter: $filter, owner: $owner) {\n    __typename\n    id\n    category\n    title\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFutureGoalFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionFutureGoalFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateFutureGoal", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateFutureGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateFutureGoal: OnCreateFutureGoal? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateFutureGoal": onCreateFutureGoal.flatMap { $0.snapshot }])
    }

    public var onCreateFutureGoal: OnCreateFutureGoal? {
      get {
        return (snapshot["onCreateFutureGoal"] as? Snapshot).flatMap { OnCreateFutureGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateFutureGoal")
      }
    }

    public struct OnCreateFutureGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["FutureGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("category", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, category: String, title: String, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FutureGoal", "id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var category: String {
        get {
          return snapshot["category"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateFutureGoalSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateFutureGoal($filter: ModelSubscriptionFutureGoalFilterInput, $owner: String) {\n  onUpdateFutureGoal(filter: $filter, owner: $owner) {\n    __typename\n    id\n    category\n    title\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFutureGoalFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionFutureGoalFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateFutureGoal", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateFutureGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateFutureGoal: OnUpdateFutureGoal? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateFutureGoal": onUpdateFutureGoal.flatMap { $0.snapshot }])
    }

    public var onUpdateFutureGoal: OnUpdateFutureGoal? {
      get {
        return (snapshot["onUpdateFutureGoal"] as? Snapshot).flatMap { OnUpdateFutureGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateFutureGoal")
      }
    }

    public struct OnUpdateFutureGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["FutureGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("category", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, category: String, title: String, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FutureGoal", "id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var category: String {
        get {
          return snapshot["category"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteFutureGoalSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteFutureGoal($filter: ModelSubscriptionFutureGoalFilterInput, $owner: String) {\n  onDeleteFutureGoal(filter: $filter, owner: $owner) {\n    __typename\n    id\n    category\n    title\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFutureGoalFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionFutureGoalFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteFutureGoal", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteFutureGoal.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteFutureGoal: OnDeleteFutureGoal? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteFutureGoal": onDeleteFutureGoal.flatMap { $0.snapshot }])
    }

    public var onDeleteFutureGoal: OnDeleteFutureGoal? {
      get {
        return (snapshot["onDeleteFutureGoal"] as? Snapshot).flatMap { OnDeleteFutureGoal(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteFutureGoal")
      }
    }

    public struct OnDeleteFutureGoal: GraphQLSelectionSet {
      public static let possibleTypes = ["FutureGoal"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("category", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, category: String, title: String, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FutureGoal", "id": id, "category": category, "title": title, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var category: String {
        get {
          return snapshot["category"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateYearlyPopupTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateYearlyPopupTask($filter: ModelSubscriptionYearlyPopupTaskFilterInput, $owner: String) {\n  onCreateYearlyPopupTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    month\n    title\n    date\n    time\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionYearlyPopupTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionYearlyPopupTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateYearlyPopupTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateYearlyPopupTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateYearlyPopupTask: OnCreateYearlyPopupTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateYearlyPopupTask": onCreateYearlyPopupTask.flatMap { $0.snapshot }])
    }

    public var onCreateYearlyPopupTask: OnCreateYearlyPopupTask? {
      get {
        return (snapshot["onCreateYearlyPopupTask"] as? Snapshot).flatMap { OnCreateYearlyPopupTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateYearlyPopupTask")
      }
    }

    public struct OnCreateYearlyPopupTask: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyPopupTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("month", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyPopupTask", "id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var month: String {
        get {
          return snapshot["month"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "month")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateYearlyPopupTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateYearlyPopupTask($filter: ModelSubscriptionYearlyPopupTaskFilterInput, $owner: String) {\n  onUpdateYearlyPopupTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    month\n    title\n    date\n    time\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionYearlyPopupTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionYearlyPopupTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateYearlyPopupTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateYearlyPopupTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateYearlyPopupTask: OnUpdateYearlyPopupTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateYearlyPopupTask": onUpdateYearlyPopupTask.flatMap { $0.snapshot }])
    }

    public var onUpdateYearlyPopupTask: OnUpdateYearlyPopupTask? {
      get {
        return (snapshot["onUpdateYearlyPopupTask"] as? Snapshot).flatMap { OnUpdateYearlyPopupTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateYearlyPopupTask")
      }
    }

    public struct OnUpdateYearlyPopupTask: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyPopupTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("month", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyPopupTask", "id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var month: String {
        get {
          return snapshot["month"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "month")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteYearlyPopupTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteYearlyPopupTask($filter: ModelSubscriptionYearlyPopupTaskFilterInput, $owner: String) {\n  onDeleteYearlyPopupTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    month\n    title\n    date\n    time\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionYearlyPopupTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionYearlyPopupTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteYearlyPopupTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteYearlyPopupTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteYearlyPopupTask: OnDeleteYearlyPopupTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteYearlyPopupTask": onDeleteYearlyPopupTask.flatMap { $0.snapshot }])
    }

    public var onDeleteYearlyPopupTask: OnDeleteYearlyPopupTask? {
      get {
        return (snapshot["onDeleteYearlyPopupTask"] as? Snapshot).flatMap { OnDeleteYearlyPopupTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteYearlyPopupTask")
      }
    }

    public struct OnDeleteYearlyPopupTask: GraphQLSelectionSet {
      public static let possibleTypes = ["YearlyPopupTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("month", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("time", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, month: String, title: String, date: String? = nil, time: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "YearlyPopupTask", "id": id, "month": month, "title": title, "date": date, "time": time, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var month: String {
        get {
          return snapshot["month"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "month")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var time: String? {
        get {
          return snapshot["time"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateFocusTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateFocusTask($filter: ModelSubscriptionFocusTaskFilterInput, $owner: String) {\n  onCreateFocusTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    date\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFocusTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionFocusTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateFocusTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateFocusTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateFocusTask: OnCreateFocusTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateFocusTask": onCreateFocusTask.flatMap { $0.snapshot }])
    }

    public var onCreateFocusTask: OnCreateFocusTask? {
      get {
        return (snapshot["onCreateFocusTask"] as? Snapshot).flatMap { OnCreateFocusTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateFocusTask")
      }
    }

    public struct OnCreateFocusTask: GraphQLSelectionSet {
      public static let possibleTypes = ["FocusTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FocusTask", "id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateFocusTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateFocusTask($filter: ModelSubscriptionFocusTaskFilterInput, $owner: String) {\n  onUpdateFocusTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    date\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFocusTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionFocusTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateFocusTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateFocusTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateFocusTask: OnUpdateFocusTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateFocusTask": onUpdateFocusTask.flatMap { $0.snapshot }])
    }

    public var onUpdateFocusTask: OnUpdateFocusTask? {
      get {
        return (snapshot["onUpdateFocusTask"] as? Snapshot).flatMap { OnUpdateFocusTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateFocusTask")
      }
    }

    public struct OnUpdateFocusTask: GraphQLSelectionSet {
      public static let possibleTypes = ["FocusTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FocusTask", "id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteFocusTaskSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteFocusTask($filter: ModelSubscriptionFocusTaskFilterInput, $owner: String) {\n  onDeleteFocusTask(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    date\n    done\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFocusTaskFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionFocusTaskFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteFocusTask", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteFocusTask.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteFocusTask: OnDeleteFocusTask? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteFocusTask": onDeleteFocusTask.flatMap { $0.snapshot }])
    }

    public var onDeleteFocusTask: OnDeleteFocusTask? {
      get {
        return (snapshot["onDeleteFocusTask"] as? Snapshot).flatMap { OnDeleteFocusTask(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteFocusTask")
      }
    }

    public struct OnDeleteFocusTask: GraphQLSelectionSet {
      public static let possibleTypes = ["FocusTask"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .scalar(String.self)),
        GraphQLField("done", type: .scalar(Bool.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, date: String? = nil, done: Bool? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FocusTask", "id": id, "title": title, "date": date, "done": done, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var date: String? {
        get {
          return snapshot["date"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var done: Bool? {
        get {
          return snapshot["done"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "done")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateMonthlyEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateMonthlyEvent($filter: ModelSubscriptionMonthlyEventFilterInput, $owner: String) {\n  onCreateMonthlyEvent(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    start\n    end\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionMonthlyEventFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionMonthlyEventFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateMonthlyEvent", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateMonthlyEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateMonthlyEvent: OnCreateMonthlyEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateMonthlyEvent": onCreateMonthlyEvent.flatMap { $0.snapshot }])
    }

    public var onCreateMonthlyEvent: OnCreateMonthlyEvent? {
      get {
        return (snapshot["onCreateMonthlyEvent"] as? Snapshot).flatMap { OnCreateMonthlyEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateMonthlyEvent")
      }
    }

    public struct OnCreateMonthlyEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["MonthlyEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("start", type: .nonNull(.scalar(String.self))),
        GraphQLField("end", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, start: String, end: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "MonthlyEvent", "id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var start: String {
        get {
          return snapshot["start"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "start")
        }
      }

      public var end: String {
        get {
          return snapshot["end"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "end")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateMonthlyEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateMonthlyEvent($filter: ModelSubscriptionMonthlyEventFilterInput, $owner: String) {\n  onUpdateMonthlyEvent(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    start\n    end\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionMonthlyEventFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionMonthlyEventFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateMonthlyEvent", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateMonthlyEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateMonthlyEvent: OnUpdateMonthlyEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateMonthlyEvent": onUpdateMonthlyEvent.flatMap { $0.snapshot }])
    }

    public var onUpdateMonthlyEvent: OnUpdateMonthlyEvent? {
      get {
        return (snapshot["onUpdateMonthlyEvent"] as? Snapshot).flatMap { OnUpdateMonthlyEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateMonthlyEvent")
      }
    }

    public struct OnUpdateMonthlyEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["MonthlyEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("start", type: .nonNull(.scalar(String.self))),
        GraphQLField("end", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, start: String, end: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "MonthlyEvent", "id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var start: String {
        get {
          return snapshot["start"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "start")
        }
      }

      public var end: String {
        get {
          return snapshot["end"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "end")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteMonthlyEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteMonthlyEvent($filter: ModelSubscriptionMonthlyEventFilterInput, $owner: String) {\n  onDeleteMonthlyEvent(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    start\n    end\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionMonthlyEventFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionMonthlyEventFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteMonthlyEvent", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteMonthlyEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteMonthlyEvent: OnDeleteMonthlyEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteMonthlyEvent": onDeleteMonthlyEvent.flatMap { $0.snapshot }])
    }

    public var onDeleteMonthlyEvent: OnDeleteMonthlyEvent? {
      get {
        return (snapshot["onDeleteMonthlyEvent"] as? Snapshot).flatMap { OnDeleteMonthlyEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteMonthlyEvent")
      }
    }

    public struct OnDeleteMonthlyEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["MonthlyEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("start", type: .nonNull(.scalar(String.self))),
        GraphQLField("end", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, start: String, end: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "MonthlyEvent", "id": id, "title": title, "start": start, "end": end, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var start: String {
        get {
          return snapshot["start"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "start")
        }
      }

      public var end: String {
        get {
          return snapshot["end"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "end")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateGoogleAuthSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateGoogleAuth($filter: ModelSubscriptionGoogleAuthFilterInput, $owner: String) {\n  onCreateGoogleAuth(filter: $filter, owner: $owner) {\n    __typename\n    id\n    token\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionGoogleAuthFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionGoogleAuthFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateGoogleAuth", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateGoogleAuth.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateGoogleAuth: OnCreateGoogleAuth? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateGoogleAuth": onCreateGoogleAuth.flatMap { $0.snapshot }])
    }

    public var onCreateGoogleAuth: OnCreateGoogleAuth? {
      get {
        return (snapshot["onCreateGoogleAuth"] as? Snapshot).flatMap { OnCreateGoogleAuth(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateGoogleAuth")
      }
    }

    public struct OnCreateGoogleAuth: GraphQLSelectionSet {
      public static let possibleTypes = ["GoogleAuth"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("token", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, token: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "GoogleAuth", "id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var token: String {
        get {
          return snapshot["token"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "token")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateGoogleAuthSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateGoogleAuth($filter: ModelSubscriptionGoogleAuthFilterInput, $owner: String) {\n  onUpdateGoogleAuth(filter: $filter, owner: $owner) {\n    __typename\n    id\n    token\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionGoogleAuthFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionGoogleAuthFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateGoogleAuth", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateGoogleAuth.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateGoogleAuth: OnUpdateGoogleAuth? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateGoogleAuth": onUpdateGoogleAuth.flatMap { $0.snapshot }])
    }

    public var onUpdateGoogleAuth: OnUpdateGoogleAuth? {
      get {
        return (snapshot["onUpdateGoogleAuth"] as? Snapshot).flatMap { OnUpdateGoogleAuth(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateGoogleAuth")
      }
    }

    public struct OnUpdateGoogleAuth: GraphQLSelectionSet {
      public static let possibleTypes = ["GoogleAuth"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("token", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, token: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "GoogleAuth", "id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var token: String {
        get {
          return snapshot["token"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "token")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteGoogleAuthSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteGoogleAuth($filter: ModelSubscriptionGoogleAuthFilterInput, $owner: String) {\n  onDeleteGoogleAuth(filter: $filter, owner: $owner) {\n    __typename\n    id\n    token\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionGoogleAuthFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionGoogleAuthFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteGoogleAuth", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteGoogleAuth.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteGoogleAuth: OnDeleteGoogleAuth? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteGoogleAuth": onDeleteGoogleAuth.flatMap { $0.snapshot }])
    }

    public var onDeleteGoogleAuth: OnDeleteGoogleAuth? {
      get {
        return (snapshot["onDeleteGoogleAuth"] as? Snapshot).flatMap { OnDeleteGoogleAuth(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteGoogleAuth")
      }
    }

    public struct OnDeleteGoogleAuth: GraphQLSelectionSet {
      public static let possibleTypes = ["GoogleAuth"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("token", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, token: String, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "GoogleAuth", "id": id, "token": token, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var token: String {
        get {
          return snapshot["token"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "token")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateUserSettingsSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateUserSettings($filter: ModelSubscriptionUserSettingsFilterInput, $owner: String) {\n  onCreateUserSettings(filter: $filter, owner: $owner) {\n    __typename\n    id\n    googleToken\n    isSynced\n    theme\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionUserSettingsFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionUserSettingsFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateUserSettings", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateUserSetting.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateUserSettings: OnCreateUserSetting? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateUserSettings": onCreateUserSettings.flatMap { $0.snapshot }])
    }

    public var onCreateUserSettings: OnCreateUserSetting? {
      get {
        return (snapshot["onCreateUserSettings"] as? Snapshot).flatMap { OnCreateUserSetting(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateUserSettings")
      }
    }

    public struct OnCreateUserSetting: GraphQLSelectionSet {
      public static let possibleTypes = ["UserSettings"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("googleToken", type: .scalar(String.self)),
        GraphQLField("isSynced", type: .scalar(Bool.self)),
        GraphQLField("theme", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserSettings", "id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var googleToken: String? {
        get {
          return snapshot["googleToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "googleToken")
        }
      }

      public var isSynced: Bool? {
        get {
          return snapshot["isSynced"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isSynced")
        }
      }

      public var theme: String? {
        get {
          return snapshot["theme"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "theme")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateUserSettingsSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateUserSettings($filter: ModelSubscriptionUserSettingsFilterInput, $owner: String) {\n  onUpdateUserSettings(filter: $filter, owner: $owner) {\n    __typename\n    id\n    googleToken\n    isSynced\n    theme\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionUserSettingsFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionUserSettingsFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateUserSettings", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateUserSetting.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateUserSettings: OnUpdateUserSetting? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateUserSettings": onUpdateUserSettings.flatMap { $0.snapshot }])
    }

    public var onUpdateUserSettings: OnUpdateUserSetting? {
      get {
        return (snapshot["onUpdateUserSettings"] as? Snapshot).flatMap { OnUpdateUserSetting(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateUserSettings")
      }
    }

    public struct OnUpdateUserSetting: GraphQLSelectionSet {
      public static let possibleTypes = ["UserSettings"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("googleToken", type: .scalar(String.self)),
        GraphQLField("isSynced", type: .scalar(Bool.self)),
        GraphQLField("theme", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserSettings", "id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var googleToken: String? {
        get {
          return snapshot["googleToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "googleToken")
        }
      }

      public var isSynced: Bool? {
        get {
          return snapshot["isSynced"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isSynced")
        }
      }

      public var theme: String? {
        get {
          return snapshot["theme"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "theme")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteUserSettingsSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteUserSettings($filter: ModelSubscriptionUserSettingsFilterInput, $owner: String) {\n  onDeleteUserSettings(filter: $filter, owner: $owner) {\n    __typename\n    id\n    googleToken\n    isSynced\n    theme\n    owner\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionUserSettingsFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionUserSettingsFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteUserSettings", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteUserSetting.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteUserSettings: OnDeleteUserSetting? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteUserSettings": onDeleteUserSettings.flatMap { $0.snapshot }])
    }

    public var onDeleteUserSettings: OnDeleteUserSetting? {
      get {
        return (snapshot["onDeleteUserSettings"] as? Snapshot).flatMap { OnDeleteUserSetting(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteUserSettings")
      }
    }

    public struct OnDeleteUserSetting: GraphQLSelectionSet {
      public static let possibleTypes = ["UserSettings"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("googleToken", type: .scalar(String.self)),
        GraphQLField("isSynced", type: .scalar(Bool.self)),
        GraphQLField("theme", type: .scalar(String.self)),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, googleToken: String? = nil, isSynced: Bool? = nil, theme: String? = nil, owner: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserSettings", "id": id, "googleToken": googleToken, "isSynced": isSynced, "theme": theme, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var googleToken: String? {
        get {
          return snapshot["googleToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "googleToken")
        }
      }

      public var isSynced: Bool? {
        get {
          return snapshot["isSynced"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isSynced")
        }
      }

      public var theme: String? {
        get {
          return snapshot["theme"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "theme")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}