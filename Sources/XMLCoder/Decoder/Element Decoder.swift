// XMLCoder © 2019 Creatunit

import DepthKit
import Foundation

/// A decoder and decoding container that decodes a value from an element.
///
/// An element decoder is used whenever decoding from a single element and derived whenever a single matching element is found during keyed decoding. When zero or more than one matching element is found, an element sequence decoder is derived instead.
public struct ElementDecoder : Decoder {
	
	/// Creates a decoder to decode a value from the root element of given XML data.
	public init(from data: Data, configuration: DecodingConfiguration = .init()) throws {
		guard let element = try TreeParser(data: data).rootElement else { throw DecodingError.noRootElement }
		self.init(element: element, configuration: configuration)
	}
	
	/// Creates a decoder to decode a value from given element.
	public init(element: Element, configuration: DecodingConfiguration = .init()) {
		self.init(element: element, codingPath: [], configuration: configuration, userInfo: [:])
	}
	
	/// Derives a decoder from given decoder.
	///
	/// - Parameter decoder:			The element decoder to derive the element sequence decoder from.
	/// - Parameter enteringCodingKey:	A coding key to get from the element decoder's element to the element sequence decoder's elements, or `nil` if there is no traversal between the two decoders.
	/// - Parameter element:			The element to decode from.
	init(derivedFrom decoder: ElementDecoder, enteringCodingKey: CodingKey, element: Element) {
		self.init(
			element:		element,
			codingPath:		decoder.codingPath.appending(enteringCodingKey),
			configuration:	decoder.configuration,
			userInfo: 		decoder.userInfo
		)
	}
	
	/// Creates a decoder to decode a value from given element.
	init(element: Element, codingPath: CodingPath, configuration: DecodingConfiguration, userInfo: [CodingUserInfoKey : Any]) {
		self.element		= element
		self.codingPath		= codingPath
		self.configuration	= configuration
		self.userInfo		= userInfo
	}
	
	/// The element being decoded.
	public let element: Element
	
	// See protocol.
	public let codingPath: CodingPath
	
	/// The decoder's configuration.
	public var configuration: DecodingConfiguration
	
	// See protocol.
	public var userInfo: [CodingUserInfoKey : Any]
	
	/// Decodes the root value.
	///
	/// - Returns: `singleValueContainer().decode(Value.self)`
	public func decodeRootValue<Value : Decodable>() throws -> Value {
		try singleValueContainer().decode(Value.self)
	}
	
	/// Returns a keyed decoding container for decoding a value from `element`.
	///
	/// For every key during decoding with a keyed decoding container, the decoder looks for a matching attribute or matching elements within `element`. An error is thrown when decoding a _primitive_ value for which there is more than one matching node (of the coding key's node kind).
	public func container<Key : CodingKey>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> {
		.init(KeyedElementDecodingContainer(decoder: self))
	}
	
	/// Returns an unkeyed decoder container for decoding values contained within `element`.
	///
	/// If `configuration.unkeyedDecodingContainersUseContainerElements` is `false`, the returned decoder decodes a single element, namely `element`. This case happens when `element` represents the only item of its collection and the collection isn't represented by a dedicated container element.
	///
	/// If `configuration.unkeyedDecodingContainersUseContainerElements` is `true`, the returned decoder decodes every element contained within `element`. The attributes of `element` are ignored. This case happens when `element` represents a container element.
	public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		try ElementSequenceDecoder(
			derivedFrom:		self,
			enteringCodingKey:	nil,
			elements:			configuration.unkeyedDecodingContainersUseContainerElements ? element.children.compactMap { $0 as? Element } : [element]
		).unkeyedContainer()
	}
	
	/// Returns a single-value container for decoding a value from `element`'s contents.
	public func singleValueContainer() -> SingleValueDecodingContainer {
		SingleValueElementDecodingContainer(decoder: self)
	}
	
}

/// A keyed decoding container for decoding from an XML element.
private struct KeyedElementDecodingContainer<Key : CodingKey> : KeyedDecodingContainerProtocol {
	
	/// Creates a keyed XML element decoding container using given decoder.
	init(decoder: ElementDecoder) {
		
		self.decoder = decoder
		
		var nodesByKeyString: [String : [TypedNode]] = [:]
		var keys: [Key] = []
		
		let keyForNode: (TypedNode) -> Key?
		if let keyType = Key.self as? XMLCodingKey.Type {
			keyForNode = { keyType.init(for: $0) as! Key? }	// forced downcasting to optional (instead of … as? Key) because we are asserting the subtyping condition is sound
		} else {
			keyForNode = Key.init(for:)
		}
		
		for child in decoder.element.children {
			guard let child = child as? TypedNode, let key = keyForNode(child) else { continue }
			if let otherChildren = nodesByKeyString[key.stringValue] {
				nodesByKeyString[key.stringValue] = otherChildren.appending(child)
			} else {
				nodesByKeyString[key.stringValue] = [child]
				keys.append(key)
			}
		}
		
		self.nodesByKeyString = nodesByKeyString
		self.allKeys = keys
		
	}
	
	/// The decoder.
	private let decoder: ElementDecoder
	
	/// The element being decoded.
	private var element: Element {
		decoder.element
	}
	
	// See protocol.
	var codingPath: CodingPath {
		decoder.codingPath
	}
	
	// See protocol.
	let allKeys: [Key]
	
	// See protocol.
	func contains(_ key: Key) -> Bool {
		nodesByKeyString[key.stringValue].flatMap { !$0.isEmpty } ?? false
	}
	
	/// The nodes contained in `element`, keyed by coding key string value.
	private let nodesByKeyString: [String : [TypedNode]]
	
	/// Returns a decoder for decoding a value resp. values from the node resp. nodes matching given key.
	///
	/// If no matching nodes are found,
	/// - an element sequence decoder with zero elements is returned if `configuration.unkeyedDecodingContainersUseContainerElements` is `false`, or
	/// - an error is thrown otherwise.
	private func decoder(forKey key: Key) throws -> Decoder {
		let codingPath = self.codingPath.appending(key)
		let matchedNodes = nodesByKeyString[key.stringValue] ?? []
		if let matchedNode = matchedNodes.first {											// at least one node found, great!
			if matchedNodes.count > 1 {														// at least two nodes found: return an element sequence decoder if acceptable
				guard !decoder.configuration.unkeyedDecodingContainersUseContainerElements else { throw DecodingError.multipleNodesForKey(path: codingPath.appending(key)) }
				return ElementSequenceDecoder(derivedFrom: decoder, enteringCodingKey: key, elements: matchedNodes.compactMap { $0 as? Element })
			} else {																		// exactly one node found: return appropriate decoder for node
				switch matchedNode {
					case let element as Element:		return ElementDecoder(derivedFrom: decoder, enteringCodingKey: key, element: element)
					case let attribute as Attribute:	return AttributeDecoder(derivedFrom: decoder, key: key, attribute: attribute)
					case let other:						fatalError("Cannot create decoder over \(type(of: other))")	// escape hatch for unknown node types
				}
			}
		} else if !decoder.configuration.unkeyedDecodingContainersUseContainerElements {	// zero nodes found but that might mean an empty unkeyed container (the returned decoder will itself throw an error if necessary)
			return ElementSequenceDecoder(derivedFrom: decoder, enteringCodingKey: key, elements: [])
		} else {																			// zero nodes found and no empty unkeyed container possible
			throw DecodingError.keyNotFound(path: codingPath)
		}
	}
	
	/// Decodes the value with given key.
	private func decode<Value : Decodable>(key: Key) throws -> Value {
		return try decoder(forKey: key).singleValueContainer().decode(Value.self)
	}
	
	// See protocol.
	func decodeNil(forKey key: Key) throws -> Bool {
		try decoder(forKey: key).singleValueContainer().decodeNil()
	}
	
	// See protocol.
	func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: String.Type, forKey key: Key) throws -> String {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
		try decode(key: key)
	}
	
	// See protocol.
	func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
		try decode(key: key)
	}
	
	// See protocol.
	func decode<Value : Decodable>(_ type: Value.Type, forKey key: Key) throws -> Value {
		try decode(key: key)
	}
	
	// See protocol.
	func nestedContainer<NestedKey : CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
		try decoder(forKey: key).container(keyedBy: NestedKey.self)
	}
	
	// See protocol.
	func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		try decoder(forKey: key).unkeyedContainer()
	}
	
	// See protocol.
	func superDecoder() -> Decoder {
		decoder		// currently no special support for subclassing
	}
	
	// See protocol.
	func superDecoder(forKey key: Key) throws -> Decoder {
		try decoder(forKey: key)
	}
	
}

/// A decoding container for decoding a single (unkeyed) value from an XML element.
///
/// When decoding a primitive value, the container converts the element's string value to a value of the requested type. An error is thrown if the decoder's element contains elements.
///
/// When decoding a decodable value, the container delegates decoding to the decodable type's initialiser. The element decoder is passed so that the initialiser can decode its structure using keyed, unkeyed, or single-value decoding containers as appropriate.
private struct SingleValueElementDecodingContainer : SingleValueDecodingContainer {
	
	/// The decoder.
	let decoder: ElementDecoder
	
	var codingPath: CodingPath {
		decoder.codingPath
	}
	
	private func stringValue() throws -> String {
		guard !decoder.element.children.contains(where: { $0 is Element }) else { throw DecodingError.mixedElementContent(path: codingPath) }
		return decoder.element.children.compactMap { ($0 as? TextNode)?.stringValue }.joined()
	}
	
	private var configuration: DecodingConfiguration {
		decoder.configuration
	}
	
	private func decode<Value>(using formatter: DecodingConfiguration.Formatter<Value>) throws -> Value {
		guard let value = formatter(try stringValue()) else { throw DecodingError.typeMismatch(attemptedType: Value.self, path: codingPath) }
		return value
	}
	
	func decodeNil() -> Bool {
		configuration.elementRepresentsNil(decoder.element)
	}
	
	func decode(_ type: Bool.Type) throws -> Bool {
		try decode(using: configuration.boolFormatter)
	}
	
	func decode(_ type: String.Type) throws -> String {
		try stringValue()
	}
	
	func decode(_ type: Double.Type) throws -> Double {
		try decode(using: configuration.numberFormatter).doubleValue
	}
	
	func decode(_ type: Float.Type) throws -> Float {
		try decode(using: configuration.numberFormatter).floatValue
	}
	
	func decode(_ type: Int.Type) throws -> Int {
		try decode(using: configuration.numberFormatter).intValue
	}
	
	func decode(_ type: Int8.Type) throws -> Int8 {
		try decode(using: configuration.numberFormatter).int8Value
	}
	
	func decode(_ type: Int16.Type) throws -> Int16 {
		try decode(using: configuration.numberFormatter).int16Value
	}
	
	func decode(_ type: Int32.Type) throws -> Int32 {
		try decode(using: configuration.numberFormatter).int32Value
	}
	
	func decode(_ type: Int64.Type) throws -> Int64 {
		try decode(using: configuration.numberFormatter).int64Value
	}
	
	func decode(_ type: UInt.Type) throws -> UInt {
		try decode(using: configuration.numberFormatter).uintValue
	}
	
	func decode(_ type: UInt8.Type) throws -> UInt8 {
		try decode(using: configuration.numberFormatter).uint8Value
	}
	
	func decode(_ type: UInt16.Type) throws -> UInt16 {
		try decode(using: configuration.numberFormatter).uint16Value
	}
	
	func decode(_ type: UInt32.Type) throws -> UInt32 {
		try decode(using: configuration.numberFormatter).uint32Value
	}
	
	func decode(_ type: UInt64.Type) throws -> UInt64 {
		try decode(using: configuration.numberFormatter).uint64Value
	}
	
	func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		try T(from: decoder)
	}
	
}
