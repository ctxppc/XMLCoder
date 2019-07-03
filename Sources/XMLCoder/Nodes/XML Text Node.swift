// XMLCoder © 2019 Creatunit

/// A text node.
public struct XMLTextNode : XMLNode {
	
	/// The node's string value.
	public var stringValue: String
	
}

extension XMLTextNode : ExpressibleByStringLiteral {
	public init(stringLiteral: String) {
		self.stringValue = stringLiteral
	}
}
