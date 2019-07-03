// XMLCoder © 2019 Creatunit

/// A node in an XML tree.
public protocol Node {}

/// A node that is assigned a (possibly namespaced) type.
public protocol TypedNode : Node {
	
	/// The coding node kind of instances of `Self`.
	static var codingKind: CodingNodeKind { get }
	
	/// The node's type.
	var type: NodeType { get }
	
}

/// A node that can contain child nodes.
public protocol InternalNode : Node {
	
	/// The node's children.
	var children: [Node] { get }
	
	/// Appends a node at a given depth.
	///
	/// - Parameter newNode: The node to insert.
	/// - Parameter depth: The depth to insert the node to, 0 being `self.children`.
	mutating func append(_ newNode: Node, depth: Int)
	
}
