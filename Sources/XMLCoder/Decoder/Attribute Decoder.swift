// XMLCoder © 2019 Creatunit

/// A decoder and decoding container that decodes a value from an attribute.
///
/// An attribute decoder only supports single-value decoding.
struct AttributeDecoder : Decoder {
	
	/// Creates an attribute decoder derived from an element decoder.
	init(derivedFrom elementDecoder: ElementDecoder, key: CodingKey, attribute: Attribute) {
		self.attribute		= attribute
		self.codingPath		= elementDecoder.codingPath.appending(key)
		self.configuration	= elementDecoder.configuration
		self.userInfo		= elementDecoder.userInfo
	}
	
	/// The element being decoded.
	let attribute: Attribute
	
	// See protocol.
	let codingPath: CodingPath
	
	/// The decoder's configuration.
	var configuration: DecodingConfiguration
	
	// See protocol.
	let userInfo: [CodingUserInfoKey : Any]
	
	// See protocol.
	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		throw DecodingError.keyedContainerOverAttributeNode(path: codingPath)
	}
	
	// See protocol.
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		throw DecodingError.unkeyedContainerOverAttributeNode(path: codingPath)
	}
	
	// See protocol.
	func singleValueContainer() -> SingleValueDecodingContainer {
		SingleValueAttributeDecodingContainer(decoder: self)
	}
	
}

private struct SingleValueAttributeDecodingContainer : SingleValueDecodingContainer {
	
	fileprivate let decoder: AttributeDecoder
	
	var codingPath: CodingPath {
		decoder.codingPath
	}
	
	private var stringValue: String {
		decoder.attribute.value
	}
	
	private var configuration: DecodingConfiguration {
		decoder.configuration
	}
	
	private func decode<Value>(using formatter: DecodingConfiguration.Formatter<Value>) throws -> Value {
		guard let value = formatter(stringValue) else { throw DecodingError.typeMismatch(attemptedType: Value.self, path: codingPath) }
		return value
	}
	
	func decodeNil() -> Bool {
		configuration.attributeRepresentsNil(decoder.attribute)
	}
	
	func decode(_ type: Bool.Type) throws -> Bool {
		try decode(using: configuration.boolFormatter)
	}
	
	func decode(_ type: String.Type) -> String {
		stringValue
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
