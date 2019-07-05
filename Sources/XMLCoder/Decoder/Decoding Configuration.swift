// XMLCoder © 2019 Creatunit

import DepthKit
import Foundation

/// A value that decodes an XML tree.
///
/// XMLCoder currently does not support extracting strings from mixed elements, i.e., elements containing elements interspersed with textual content. An error is thrown when attempting to decode a string from a mixed element. Strings are ignored when decoding an aggregate value from a mixed element, i.e., only the elements can be used to decode the aggregate value.
public struct DecodingConfiguration {
	
	/// Creates a configuration.
	public init() {}
	
	/// A function that determines whether a given element encodes `nil`.
	///
	/// The default value returns `true` has a XML Schema Instances `nil` attribute with value `true`, and `false` otherwise.
	public var elementRepresentsNil: (Element) -> Bool = { element in
		
		struct NillableValue : Decodable {
			
			init(from decoder: Decoder) throws {
				isNil = try decoder.container(keyedBy: CodingKey.self).decodeIfPresent(key: .isNil) ?? false
			}
			
			enum CodingKey : String, XMLCodingKey {
				case isNil = "nil"
				var namespace: Namespace? { DecodingConfiguration.xsiNamespace }
				var nodeKind: CodingNodeKind { .attribute }
			}
			
			let isNil: Bool
			
		}
		
		do {
			return try ElementDecoder(element: element).singleValueContainer().decode(NillableValue.self).isNil
		} catch {
			return false
		}
		
	}
	
	/// A function that determines whether a given attribute encodes `nil`.
	///
	/// The default value always returns `false`.
	public var attributeRepresentsNil: (Attribute) -> Bool = { _ in false }
	
	/// The XML Schema Instances `nil` attribute type.
	private static let xsiNilAttributeType = NodeType(namespace: xsiNamespace, localName: "nil")
	
	/// The XML Schema Instances namespace.
	private static let xsiNamespace = Namespace(name: "http://www.w3.org/2001/XMLSchema-instance")
	
	/// A function that maps string values to Boolean values, returning `nil` for strings that do not represent valid Boolean values.
	///
	/// The default value maps "false" (case-insensitive) and 0 to `false`, and "true" (case-insensitive) and 1 to `true`.
	public var boolFormatter: Formatter<Bool> = { string in
		switch string {
			case "0", "false":	return false
			case "1", "true":	return true
			default:			return nil
		}
	}
	
	/// A function that maps string values to numbers, returning `nil` for strings that do not represent valid numbers.
	///
	/// The default value uses a `NumberFormatter` value configured with the (neutral) system locale to convert strings into numbers.
	public var numberFormatter: Formatter<NSNumber> = {
		let formatter = NumberFormatter()
		formatter.locale = NSLocale.system
		return formatter.number(from:)
	}()
	
	/// A function that maps string values to dates, returning `nil` for strings that do not represent valid dates.
	///
	/// The default value uses an `ISO8601DateFormatter` value to convert strings into dates.
	public var dateFormatter: Formatter<Date> = ISO8601DateFormatter().date(from:)
	
	/// A function that maps string values to values of some type `Value`, returning `nil` for strings that do not represent valid values of that type.
	public typealias Formatter<Value> = (String) -> Value?
	
	/// A function that maps qualified tag names to coding key raw values.
	///
	/// The default value returns the tag name unchanged.
	public var codingKeyTransform: CodingKeyTransform = { $0 }
	public typealias CodingKeyTransform = (String) -> String
	
	/// User-provided information for use during decoding.
	public var userInfo: [CodingUserInfoKey : Any] = [:]
	
	/// A Boolean value indicating whether unkeyed decoding containers use container elements.
	///
	/// As an illustration, the aggregate value `Person(name: "John", hobbies: ["Tennis", "Piano"])` of type
	///
	///     struct Person : Codable {
	///       let name: String
	///       let hobbies: [String]
	///     }
	///
	/// can be encoded as
	///
	///     <person>
	///       <name>John</name>
	///       <hobbies>
	///         <hobby>Tennis</hobby>
	///         <hobby>Football</hobby>
	///       </hobbies>
	///     </person>
	///
	/// or as
	///
	///     <person>
	///       <name>John</name>
	///       <hobby>Tennis</hobby>
	///       <hobby>Football</hobby>
	///     </person>
	///
	/// To decode using the first structure, set this property to `true` (the default value) and use the container element's local name as the coding key's string value (in this example "hobbies"). To decode using the second structure, set this property to `false` and use the individual elements' local name as the coding key's string value (in this example "hobby").
	///
	/// The use of container elements mirrors more closely the structure of `Codable` types which (arguably) are designed for property list and JSON encoding formats, which is why this is the default value. Common XML encoding formats like RSS and Atom do not use container elements, e.g., `entry` elements are contained directly in `feed` elements instead of in "`entries`" container elements.
	public var unkeyedDecodingContainersUseContainerElements: Bool = true
	
}
