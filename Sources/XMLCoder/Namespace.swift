// XMLCoder © 2019 Creatunit

public struct Namespace : Hashable, CustomStringConvertible {
	
	/// Defines a namespace with given name.
	public init(name: String) {
		self.name = name
	}
	
	/// The namespace's name.
	public var name: String
	
	// See protocol.
	public var description: String {
		name
	}
	
}
