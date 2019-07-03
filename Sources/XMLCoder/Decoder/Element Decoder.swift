// XMLCoder © 2019 Creatunit

import DepthKit
import Foundation

/// A decoder and decoding container that decodes a value from an element.
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
	public private(set) var element: Element
	
	// See protocol.
	public private(set) var codingPath: CodingPath
	
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
	/// For every key during decoding with a keyed decoding container, the decoder looks for a matching attribute or matching elements within `element`. An error is thrown when decoding a primitive value for which there is more than one matching node (of the coding key's node kind).
	public func container<Key : CodingKey>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> {
		.init(KeyedElementDecodingContainer(decoder: self))
	}
	
	/// Returns an unkeyed decoder container for decoding values contained within `element`.
	///
	/// The decoder decodes values in an unkeyed decoding container by decoding every element contained within `element`. The attributes of `element` are ignored.
	public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		try ElementSequenceDecoder(
			derivedFrom:		self,
			enteringCodingKey:	nil,
			elements:			element.children.compactMap { $0 as? Element }
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
		nodesByKeyString.keys.contains(key.stringValue)
	}
	
	/// The nodes contained in `element`, keyed by coding key string value.
	private let nodesByKeyString: [String : [TypedNode]]
	
	/// Returns the node matching given key.
	private func node(forKey key: Key) throws -> Node {
		let path = codingPath.appending(key)
		let matchingNodes = try nodes(forKey: key)
		guard let node = matchingNodes.first else { throw DecodingError.keyNotFound(path: path) }
		guard matchingNodes.count <= 1 else { throw DecodingError.multipleNodesForKey(path: path) }
		return node
	}
	
	/// Returns the nodes matching given key.
	private func nodes(forKey key: Key) throws -> [Node] {
		nodesByKeyString[key.stringValue] ?? []
	}
	
	private func decode<Value : Decodable>(key: Key) throws -> Value {
		let matchedNodes = try nodes(forKey: key)
		guard let matchedNode = matchedNodes.first else { throw DecodingError.keyNotFound(path: codingPath.appending(key)) }
		if matchedNodes.count > 1 {
			return try Value(from: ElementSequenceDecoder(derivedFrom: decoder, enteringCodingKey: key, elements: matchedNodes.compactMap { $0 as? Element }))
		} else {
			switch matchedNode {
				case let element as Element:		return try ElementDecoder(derivedFrom: decoder, enteringCodingKey: key, element: element).singleValueContainer().decode(Value.self)
				case let attribute as Attribute:	return try AttributeDecoder(derivedFrom: decoder, key: key, attribute: attribute).singleValueContainer().decode(Value.self)
				case let other:						fatalError("Cannot create single-value container over \(type(of: other))")
			}
		}
	}
	
	// See protocol.
	func decodeNil(forKey key: Key) throws -> Bool {
		decoder.configuration.nilFormatter(try decode(key: key)) ?? false
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
	
	/// Returns a decoder for decoding from the node matched with given key.
	private func decoder(forKey key: Key) throws -> Decoder {
		switch try node(forKey: key) {
			case let element as Element:		return ElementDecoder(derivedFrom: decoder, enteringCodingKey: key, element: element)
			case let attribute as Attribute:	return AttributeDecoder(derivedFrom: decoder, key: key, attribute: attribute)
			case let other:						fatalError("Cannot create decoder over \(type(of: other))")
		}
	}
	
	// See protocol.
	func nestedContainer<NestedKey : CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
		try decoder(forKey: key).container(keyedBy: NestedKey.self)
	}
	
	// See protocol.
	func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		let matchedNodes = try nodes(forKey: key)
		guard let matchedNode = matchedNodes.first else { throw DecodingError.keyNotFound(path: codingPath.appending(key)) }
		if matchedNodes.count > 1 {
			return try ElementSequenceDecoder(derivedFrom: decoder, enteringCodingKey: key, elements: matchedNodes.compactMap { $0 as? Element }).unkeyedContainer()
		} else {
			switch matchedNode {
				case let element as Element:		return try ElementDecoder(derivedFrom: decoder, enteringCodingKey: key, element: element).unkeyedContainer()
				case let attribute as Attribute:	return try AttributeDecoder(derivedFrom: decoder, key: key, attribute: attribute).unkeyedContainer()	// this will throw the appropriate error
				case let other:						fatalError("Cannot create unkeyed container over \(type(of: other))")
			}
		}
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
	
	private func decodeValue<Value>(using formatter: DecodingConfiguration.Formatter<Value>) throws -> Value {
		guard let value = formatter(try stringValue()) else { throw DecodingError.typeMismatch(attemptedType: Value.self, path: codingPath) }
		return value
	}
	
	func decodeNil() -> Bool {
		do {
			return configuration.nilFormatter(try stringValue()) ?? false
		} catch {
			return false
		}
	}
	
	func decode(_ type: Bool.Type) throws -> Bool {
		try decodeValue(using: configuration.boolFormatter)
	}
	
	func decode(_ type: String.Type) throws -> String {
		try stringValue()
	}
	
	func decode(_ type: Double.Type) throws -> Double {
		try decodeValue(using: configuration.numberFormatter).doubleValue
	}
	
	func decode(_ type: Float.Type) throws -> Float {
		try decodeValue(using: configuration.numberFormatter).floatValue
	}
	
	func decode(_ type: Int.Type) throws -> Int {
		try decodeValue(using: configuration.numberFormatter).intValue
	}
	
	func decode(_ type: Int8.Type) throws -> Int8 {
		try decodeValue(using: configuration.numberFormatter).int8Value
	}
	
	func decode(_ type: Int16.Type) throws -> Int16 {
		try decodeValue(using: configuration.numberFormatter).int16Value
	}
	
	func decode(_ type: Int32.Type) throws -> Int32 {
		try decodeValue(using: configuration.numberFormatter).int32Value
	}
	
	func decode(_ type: Int64.Type) throws -> Int64 {
		try decodeValue(using: configuration.numberFormatter).int64Value
	}
	
	func decode(_ type: UInt.Type) throws -> UInt {
		try decodeValue(using: configuration.numberFormatter).uintValue
	}
	
	func decode(_ type: UInt8.Type) throws -> UInt8 {
		try decodeValue(using: configuration.numberFormatter).uint8Value
	}
	
	func decode(_ type: UInt16.Type) throws -> UInt16 {
		try decodeValue(using: configuration.numberFormatter).uint16Value
	}
	
	func decode(_ type: UInt32.Type) throws -> UInt32 {
		try decodeValue(using: configuration.numberFormatter).uint32Value
	}
	
	func decode(_ type: UInt64.Type) throws -> UInt64 {
		try decodeValue(using: configuration.numberFormatter).uint64Value
	}
	
	func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		try T(from: decoder)
	}
	
}
