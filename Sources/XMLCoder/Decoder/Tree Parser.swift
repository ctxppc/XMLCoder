// XMLCoder © 2019 Creatunit

import Foundation

final class TreeParser : NSObject, XMLParserDelegate {
	
	/// Parses a tree from given data.
	init(data: Data) throws {
		super.init()
		let parser = XMLParser(data: data)
		parser.delegate = self
		parser.shouldProcessNamespaces = true
		parser.shouldReportNamespacePrefixes = true
		parser.parse()
		if let error = self.error {
			throw error
		}
	}
	
	/// The root element, if any.
	var rootElement: Element?
	
	/// The depth of the deepest element that hasn't been closed yet.
	private var openDepth: Int = -1
	
	/// The active scope of the parser.
	private var scope: Scope = .init()
	
	/// An error during parsing, or `nil` if no error occurred.
	var error: Error?
	
	// See protocol.
	func parser(_ parser: XMLParser, didStartElement localName: String, namespaceURI namespaceName: String?, qualifiedName: String?, attributes: [String : String] = [:]) {
		
		let newElement = Element(
			namespaceName:	namespaceName,
			localName:		localName,
			attributes:		attributes,
			scope:			scope
		)
		
		rootElement?.append(newElement, depth: openDepth) ?? (rootElement = newElement)
		openDepth += 1
		
	}
	
	// See protocol.
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
		openDepth -= 1
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		rootElement?.append(TextNode(stringValue: string), depth: openDepth)
	}
	
	func parser(_ parser: XMLParser, foundCDATA data: Data) {
		guard let string = String(data: data, encoding: .utf8) else { return }
		rootElement?.append(TextNode(stringValue: string), depth: openDepth)
	}
	
	// See protocol.
	func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceName: String) {
		if prefix.isEmpty {
			scope.beginDefaultNamespaceScope(.init(name: namespaceName))
		} else {
			scope.beginScope(.init(name: namespaceName), prefix: prefix)
		}
		
	}
	
	// See protocol.
	func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
		if prefix.isEmpty {
			scope.endDefaultNamespaceScope()
		} else {
			scope.endScope(prefix: prefix)
		}
	}
	
	// See protocol.
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		error = parseError
	}
	
}
