// XMLCoder © 2019 Creatunit

/// An error during XML decoding.
public enum DecodingError : Error {
	
	/// An error indicating that the document has no root element.
	case noRootElement
	
	/// An error indicating a type mismatch.
	case typeMismatch(attemptedType: Any.Type, path: CodingPath)
	
	/// An error indicating that no matching node can be found at given path.
	case keyNotFound(path: CodingPath)
	
	/// An error indicating that multiple nodes match for decoding a single value.
	case multipleNodesForKey(path: CodingPath)
	
	/// An error indicating that a primitive value is being decoded over an element with mixed content.
	case mixedElementContent(path: CodingPath)
	
	/// An error indicating that a keyed decoding container is being created over an attribute node.
	///
	/// XMLCoder does not support keyed or plural decoding from attribute values.
	case keyedContainerOverAttributeNode(path: CodingPath)
	
	/// An error indicating that an unkeyed decoding container is being created over an attribute node.
	///
	/// Plural decoding from attribute values is not supported.
	case unkeyedContainerOverAttributeNode(path: CodingPath)
	
}
