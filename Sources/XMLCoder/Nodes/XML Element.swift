// XMLCoder © 2019 Creatunit

public struct XMLElement : TypedXMLNode, InternalXMLNode {
	
	/// Creates an element node with given namespace name, local name, and unprocessed attributes.
	internal init(namespaceName: String?, localName: String, attributes: [String : String], scope: XMLScope) {
		type = XMLNodeType(
			namespace:	namespaceName.flatMap { .init(name: $0) },
			localName:	localName
		)
		children = attributes.map { XMLAttribute(unprocessedName: $0.key, value: $0.value, scope: scope) }
	}
	
	// See protocol.
	public var type: XMLNodeType
	
	/// The element's children nodes.
	///
	/// Every attribute node, if any, precedes every non-attribute node.
	public var children: [XMLNode] = []
	
	/// Returns a Boolean value indicating whether the element contains a mix of text nodes and elements.
	public var hasMixedContent: Bool {
		let hasText = children.lazy
			.compactMap { $0 as? XMLTextNode }
			.map { $0.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) }
			.contains { !$0.isEmpty }
		let hasElements = children.contains { $0 is XMLElement }
		return (hasText && !hasElements) || (!hasText && hasElements)
	}
	
	/// Appends given node at given depth.
	///
	/// - Parameter newNode: The node to insert.
	/// - Parameter depth: The depth of the insertion point. A depth of 0 indicates that `newNode` should be inserted directly in `self.children`.
	public mutating func append(_ newNode: XMLNode, depth: Int) {
		if depth > 0 {
			guard var openNode = children.removeLast() as? InternalXMLNode else { fatalError("Cannot append to a leaf node") }
			openNode.append(newNode, depth: depth - 1)
			children.append(openNode)
		} else {
			children.append(newNode)
		}
	}
	
	// See protocol.
	public static var codingKind: CodingXMLNodeKind { .element }
	
}

fileprivate struct StandardisedCodingKey : XMLCodingKey {
	
	init?(stringValue: String) {
		self.stringValue = stringValue
		intValue = nil
		namespace = nil
		nodeKind = .element
	}
	
	init?(intValue: Int) {
		stringValue = .init(intValue)
		self.intValue = intValue
		namespace = nil
		nodeKind = .element
	}
	
	init(for key: CodingKey) {
		stringValue = key.stringValue
		intValue = key.intValue
		namespace = nil
		nodeKind = .element
	}
	
	// See protocol.
	let stringValue: String
	
	// See protocol.
	let intValue: Int?
	
	// See protocol.
	let namespace: XMLNamespace?
	
	// See protocol.
	let nodeKind: CodingXMLNodeKind
	
}
