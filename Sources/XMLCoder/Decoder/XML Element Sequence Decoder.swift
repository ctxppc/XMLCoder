// XMLCoder © 2019 Creatunit

import DepthKit

/// A decoder and decoding container that decodes a value from a sequence of elements.
///
/// An element sequence decoder is derived from an element decoder when more than one element matches a coding key during keyed decoding.
internal struct XMLElementSequenceDecoder : Decoder {
	
	/// Derives an element sequence decoder from given element decoder.
	///
	/// - Requires: `elements` contains more than one element.
	///
	/// - Parameter elementDecoder: The element decoder to derive the element sequence decoder from.
	/// - Parameter enteringCodingKey: A coding key to get from the element decoder's element to the element sequence decoder's elements, or `nil` if there is no traversal between the two decoders.
	/// - Parameter elements: The elements to decode from.
	init(derivedFrom elementDecoder: XMLElementDecoder, enteringCodingKey: CodingKey?, elements: [XMLElement]) {
		precondition(elements.count > 1, "Cannot create element sequence decoder over zero or one elements")
		self.elements		= elements
		self.codingPath		= enteringCodingKey.flatMap(elementDecoder.codingPath.appending) ?? elementDecoder.codingPath
		self.configuration	= elementDecoder.configuration
		self.userInfo		= elementDecoder.userInfo
	}
	
	/// The elements being decoded.
	///
	/// - Invariant: elements` contains more than one element.
	fileprivate private(set) var elements: [XMLElement]
	
	// See protocol.
	private(set) var codingPath: CodingPath
	
	/// The decoder's configuration.
	var configuration: XMLDecodingConfiguration
	
	// See protocol.
	var userInfo: [CodingUserInfoKey : Any]
	
	// See protocol.
	func container<Key : CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
		throw XMLDecodingError.multipleNodesForKey(path: codingPath)
	}
	
	// See protocol.
	func unkeyedContainer() -> UnkeyedDecodingContainer {
		TODO.unimplemented
	}
	
	// See protocol.
	func singleValueContainer() -> SingleValueDecodingContainer {
		TODO.unimplemented
	}
	
}

private struct UnkeyedXMLElementSequenceDecodingContainer : UnkeyedDecodingContainer {
	
	/// Creates an unkeyed decoding container using given decoder.
	init(decoder: XMLElementSequenceDecoder) {
		self.decoder = decoder
	}
	
	/// The decoder.
	let decoder: XMLElementSequenceDecoder
	
	/// The elements to be decoded.
	var elements: [XMLElement] {
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
	private func decoderForNextElement() -> XMLElementDecoder {
		XMLElementDecoder(
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
	mutating func nestedUnkeyedContainer() -> UnkeyedDecodingContainer {
		let container = decoderForNextElement().unkeyedContainer()
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
