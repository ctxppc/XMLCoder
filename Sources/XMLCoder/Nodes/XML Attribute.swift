// XMLCoder © 2019 Creatunit

public struct XMLAttribute : TypedXMLNode {
	
	/// Creates an attribute node with given unprocessed attribute name, attribute value, and scope.
	internal init(unprocessedName: String, value: String, scope: XMLScope) {
		
		let nameComponents = unprocessedName.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
		if nameComponents.count == 2 {
			type = .init(
				namespace:	scope.namespace(forPrefix: .init(nameComponents[0])),
				localName:	.init(nameComponents[1])
			)
		} else {
			type = .init(
				namespace:	nil,
				localName:	.init(nameComponents[0])
			)
		}
		
		self.value = value
		
	}
	
	// See protocol`.
	public let type: XMLNodeType
	
	/// The raw attribute value.
	public let value: String
	
	// See protocol.
	public static var codingKind: CodingXMLNodeKind { .attribute }
	
}
