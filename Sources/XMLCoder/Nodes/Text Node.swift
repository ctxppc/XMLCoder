// XMLCoder © 2019 Creatunit

/// A text node.
public struct TextNode : Node {
	
	/// The node's string value.
	public var stringValue: String
	
}

extension TextNode : ExpressibleByStringLiteral {
	public init(stringLiteral: String) {
		self.stringValue = stringLiteral
	}
}
