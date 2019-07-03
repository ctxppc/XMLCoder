// XMLCoder © 2019 Creatunit

/// A node in an XML tree.
public protocol XMLNode {}

/// A node that is assigned a (possibly namespaced) type.
public protocol TypedXMLNode : XMLNode {
	
	/// The coding node kind of instances of `Self`.
	static var codingKind: CodingXMLNodeKind { get }
	
	/// The node's type.
	var type: XMLNodeType { get }
	
}

/// A node that can contain child nodes.
public protocol InternalXMLNode : XMLNode {
	
	/// The node's children.
	var children: [XMLNode] { get }
	
	/// Appends a node at a given depth.
	///
	/// - Parameter newNode: The node to insert.
	/// - Parameter depth: The depth to insert the node to, 0 being `self.children`.
	mutating func append(_ newNode: XMLNode, depth: Int)
	
}
