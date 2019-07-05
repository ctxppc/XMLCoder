// XMLCoder © 2019 Creatunit

import Foundation
import XMLCoder

struct Logbook : Decodable, Equatable {
	
	static let namespace = Namespace(name: "http://shipbuilding.example.com/yarrgh/2019")
	
	let lastEdited: Date
	let owner: Contact
	let auditor: Contact
	let entries: [Entry]
	let notes: [Note]
	let stamps: [Stamp]
	
	struct Contact : Decodable, Equatable {
		
		let name: String
		let email: String
		
		enum CodingKeys : XMLCodingKey {
			case name, email
			var namespace: Namespace? { Logbook.namespace }
			var nodeKind: CodingNodeKind { .element }
		}
		
	}
	
	struct Entry : Decodable, Equatable {
		
		let date: Date
		let title: String
		let severity: Severity
		
		enum Severity : String, Decodable, Equatable {
			case info
			case warning
			case alert
		}
		
		enum CodingKeys : XMLCodingKey {
			case date, title, severity
			var namespace: Namespace? { self == .date ? nil : Logbook.namespace }
			var nodeKind: CodingNodeKind { self == .date ? .attribute : .element }
		}
		
	}
	
	struct Note : Decodable, Equatable {
		
		init(date: Date, text: String) {
			self.date = date
			self.text = text
		}
		
		init(from decoder: Decoder) throws {
			date = try decoder.container(keyedBy: CodingKey.self).decode(key: .date)
			text = try decoder.singleValueContainer().decode(String.self)
		}
		
		let date: Date
		let text: String
		
		enum CodingKey : String, XMLCodingKey {
			case date
			var namespace: Namespace? { nil }
			var nodeKind: CodingNodeKind { .attribute }
		}
		
	}
	
	struct Stamp : Decodable, Equatable {
		let date: Date
		let stamper: Contact
	}
	
	enum CodingKeys : XMLCodingKey {
		case owner, auditor, entries, notes, stamps, lastEdited
		var namespace: Namespace? { self == .lastEdited ? nil : Logbook.namespace }
		var nodeKind: CodingNodeKind { self == .lastEdited ? .attribute : .element }
	}
	
}
