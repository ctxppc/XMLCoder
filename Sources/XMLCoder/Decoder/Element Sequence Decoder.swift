// XMLCoder © 2019 Creatunit

import DepthKit

/// A decoder and decoding container that decodes a value from a sequence of (at least two) elements.
///
/// An element sequence decoder is derived from an element decoder when more than one element matches a coding key during keyed decoding. An element sequence decoder enables unkeyed decoding when `unkeyedDecodingContainersUseContainerElements` is `false`. Keyed decoding is not available, nor is primitive value decoding.
struct ElementSequenceDecoder : Decoder {
	
	/// Derives an element sequence decoder from given element decoder.
	///
	/// - Requires: `elements` contains more than one element.
	///
	/// - Parameter elementDecoder: The element decoder to derive the element sequence decoder from.
	/// - Parameter enteringCodingKey: A coding key to get from the element decoder's element to the element sequence decoder's elements, or `nil` if there is no traversal between the two decoders.
	/// - Parameter elements: The elements to decode from.
	init(derivedFrom elementDecoder: ElementDecoder, enteringCodingKey: CodingKey?, elements: [Element]) {
		precondition(elements.count > 1, "Cannot create element sequence decoder over zero or one elements")
		self.elements		= elements
		self.codingPath		= enteringCodingKey.flatMap(elementDecoder.codingPath.appending) ?? elementDecoder.codingPath
		self.configuration	= elementDecoder.configuration
		self.userInfo		= elementDecoder.userInfo
	}
	
	/// The elements being decoded.
	///
	/// - Invariant: elements` contains more than one element.
	fileprivate private(set) var elements: [Element]
	
	// See protocol.
	private(set) var codingPath: CodingPath
	
	/// The decoder's configuration.
	var configuration: DecodingConfiguration
	
	// See protocol.
	var userInfo: [CodingUserInfoKey : Any]
	
	// See protocol.
	func container<Key : CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	// See protocol.
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		guard !configuration.unkeyedDecodingContainersUseContainerElements else { throw DecodingError.multipleNodesForKey(path: codingPath) }
		return UnkeyedElementSequenceDecodingContainer(decoder: self)
	}
	
	// See protocol.
	func singleValueContainer() -> SingleValueDecodingContainer {
		SingleValueElementSequenceDecodingContainer(decoder: self)
	}
	
}

private struct UnkeyedElementSequenceDecodingContainer : UnkeyedDecodingContainer {
	
	/// Creates an unkeyed decoding container using given decoder.
	init(decoder: ElementSequenceDecoder) {
		self.decoder = decoder
	}
	
	/// The decoder.
	let decoder: ElementSequenceDecoder
	
	/// The elements to be decoded.
	var elements: [Element] {
		return decoder.elements
	}
	
	// See protocol.
	var codingPath: CodingPath {
		decoder.codingPath
	}
	
	// See protocol.
	private(set) var currentIndex: Int = 0
	
	// See protocol.
	var count: Int? {
		elements.count
	}
	
	// See protocol.
	var isAtEnd: Bool {
		currentIndex == count
	}
	
	private struct NumericKey : CodingKey {
		
		init?(stringValue: String) {
			guard let value = Int(stringValue) else { return nil }
			self.stringValue = stringValue
			self.intValue = value
		}
		
		init(intValue: Int) {
			self.stringValue = .init(intValue)
			self.intValue = intValue
		}
		
		// See protocol.
		var stringValue: String
		
		// See protocol.
		var intValue: Int?
		
	}
	
	/// Returns a decoder that decodes the next element.
	///
	/// This method does *not* advance the container's current index.
	private func decoderForNextElement() -> ElementDecoder {
		ElementDecoder(
			element: 		elements[currentIndex],
			codingPath:		decoder.codingPath.appending(NumericKey(intValue: currentIndex)),
			configuration:	decoder.configuration,
			userInfo:		decoder.userInfo
		)
	}
	
	private mutating func decode<Value : Decodable>() throws -> Value {
		let value = try decoderForNextElement().singleValueContainer().decode(Value.self)
		currentIndex += 1	// only increase when no error is thrown
		return value
	}
	
	// See protocol.
	mutating func decodeNil() -> Bool {
		let hasNil = decoderForNextElement().singleValueContainer().decodeNil()
		hasNil --> (currentIndex += 1)
		return hasNil
	}
	
	// See protocol.
	mutating func decode(_ type: Bool.Type) throws -> Bool {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: String.Type) throws -> String {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: Double.Type) throws -> Double {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: Float.Type) throws -> Float {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: Int.Type) throws -> Int {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: Int8.Type) throws -> Int8 {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: Int16.Type) throws -> Int16 {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: Int32.Type) throws -> Int32 {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: Int64.Type) throws -> Int64 {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: UInt.Type) throws -> UInt {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
		try decode()
	}
	
	// See protocol.
	mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
		try decode()
	}
	
	// See protocol.
	mutating func decode<Value : Decodable>(_ type: Value.Type) throws -> Value {
		try decode()
	}
	
	// See protocol.
	mutating func nestedContainer<NestedKey : CodingKey>(keyedBy type: NestedKey.Type) -> KeyedDecodingContainer<NestedKey> {
		let container = decoderForNextElement().container(keyedBy: NestedKey.self)
		currentIndex += 1
		return container
	}
	
	// See protocol.
	mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
		let container = try decoderForNextElement().unkeyedContainer()
		currentIndex += 1
		return container
	}
	
	// See protocol.
	mutating func superDecoder() throws -> Decoder {
		let decoder = decoderForNextElement()
		currentIndex += 1
		return decoder
	}
	
}

private struct SingleValueElementSequenceDecodingContainer : SingleValueDecodingContainer {
	
	let decoder: ElementSequenceDecoder
	
	var codingPath: CodingPath {
		decoder.codingPath
	}
	
	func decodeNil() -> Bool {
		return false
	}
	
	func decode(_ type: Bool.Type) throws -> Bool {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: String.Type) throws -> String {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: Double.Type) throws -> Double {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: Float.Type) throws -> Float {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: Int.Type) throws -> Int {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: Int8.Type) throws -> Int8 {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: Int16.Type) throws -> Int16 {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: Int32.Type) throws -> Int32 {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: Int64.Type) throws -> Int64 {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: UInt.Type) throws -> UInt {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: UInt8.Type) throws -> UInt8 {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: UInt16.Type) throws -> UInt16 {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: UInt32.Type) throws -> UInt32 {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode(_ type: UInt64.Type) throws -> UInt64 {
		throw DecodingError.multipleNodesForKey(path: codingPath)
	}
	
	func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		try T(from: decoder)
	}
	
}
