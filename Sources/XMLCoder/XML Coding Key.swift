// XMLCoder © 2019 Creatunit

/// A coding key that is encoded as an XML node.
///
/// The string value is used to identify nodes, optionally after transformation (cf. `codingKeyTransform` in `XMLDecoder`). `XMLDecoder` does not support decoding from elements containing both an attribute and one or more elements with the same XML type; an unsupported workaround is to use two different types conforming to `XMLCodingKey`.
///
/// Coding keys that do not conform to this protocol are not associated to any particular namespace and are coded as elements.
public protocol XMLCodingKey : CodingKey {
	
	/// The namespace where the key's associated element or attribute type is defined, or `nil` if the type doesn't belong to any specific namespace.
	var namespace: XMLNamespace? { get }
	
	/// The kind of node the key is coded by.
	var nodeKind: CodingXMLNodeKind { get }
	
}

extension XMLCodingKey {
	
	internal init?(for node: TypedXMLNode) {
		
		self.init(stringValue: node.type.localName)
		
		switch (self.namespace, node.type.namespace) {
			case (let a?, let b?) where a == b:	break
			case (nil, nil):					break
			default:							return nil
		}
		
		guard type(of: node).codingKind == self.nodeKind else { return nil }
		
	}
	
}

extension CodingKey {
	
	internal init?(for node: TypedXMLNode) {
		guard node.type.namespace == nil, type(of: node).codingKind == .element else { return nil }
		self.init(stringValue: node.type.localName)
	}
	
}

public typealias CodingPath = [CodingKey]
