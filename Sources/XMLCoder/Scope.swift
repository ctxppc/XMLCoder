// XMLCoder © 2019 Creatunit

/// A value encapsulating a scope for namespace names.
internal struct Scope {
	
	/// The namespaces by prefix, ordered by scope depth.
	///
	/// The current namespace for a given prefix is the last element in the array.
	private var namespacesByPrefix: [String : [Namespace]] = [:]
	
	/// Returns the namespace associated with a given prefix.
	func namespace(forPrefix prefix: String) -> Namespace? {
		namespacesByPrefix[prefix, default: []].last
	}
	
	/// Associates a given prefix with a given namespace.
	mutating func beginScope(_ namespace: Namespace, prefix: String) {
		namespacesByPrefix[prefix, default: []].append(namespace)
	}
	
	/// Disassociates a given prefix from its current namespace.
	mutating func endScope(prefix: String) {
		namespacesByPrefix[prefix, default: []].removeLast()
	}
	
	/// The default namespaces, ordered by scope depth.
	///
	/// The current default namespace is the last element in the array.
	private var defaultNamespaces: [Namespace] = []
	
	/// The current default namespace.
	var defaultNamespace: Namespace? { defaultNamespaces.last }
	
	/// Sets the default namespace.
	mutating func beginDefaultNamespaceScope(_ namespace: Namespace) {
		defaultNamespaces.append(namespace)
	}
	
	/// Removes the default namespace, reverting to the previous default namespace if available.
	mutating func endDefaultNamespaceScope() {
		defaultNamespaces.removeLast()
	}
	
}
