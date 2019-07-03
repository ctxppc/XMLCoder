// XMLCoder © 2019 Creatunit

import DepthKit
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
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI namespaceName: String?, qualifiedName localName: String?, attributes: [String : String] = [:]) {
		
		let newElement = Element(
			namespaceName:	namespaceName,
			localName:		localName !! "Unexpected nil local name",
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
	
	// See protocol.
	func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceName: String) {
		if prefix.isEmpty {
			scope.beginScope(.init(name: namespaceName), prefix: prefix)
		} else {
			scope.beginDefaultNamespaceScope(.init(name: namespaceName))
		}
		
	}
	
	// See protocol.
	func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
		if prefix.isEmpty {
			scope.endScope(prefix: prefix)
		} else {
			scope.endDefaultNamespaceScope()
		}
	}
	
	// See protocol.
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		error = parseError
	}
	
}
