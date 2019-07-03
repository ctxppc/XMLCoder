// XMLCoder © 2019 Creatunit

import Foundation

public struct XMLNamespace : Hashable {
	
	/// Defines a namespace with given name.
	public init(name: String) {
		self.name = name
	}
	
	/// The namespace's name.
	public var name: String
	
}
