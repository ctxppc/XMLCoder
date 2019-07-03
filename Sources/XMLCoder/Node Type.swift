// XMLCoder © 2019 Creatunit

/// A value indicating the type of a node (not to be confused with a node's _kind_ such as `.element` or `.attribute`).
public struct NodeType {
	
	/// The type's namespace, or `nil`if the type isn't assigned to any namespace.
	public var namespace: Namespace?
	
	/// The name of the type, localised to its namespace if applicable.
	public var localName: String
	
}
