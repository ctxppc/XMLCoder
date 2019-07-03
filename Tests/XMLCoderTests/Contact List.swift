// XMLCoder © 2019 Creatunit

import XMLCoder

struct ContactList : Decodable, Equatable {
	
	var people: [Person]
	
	static let namespace = Namespace(name: "http://example.org/my-contact-lists/2019a")
	
	enum CodingKeys : String, XMLCodingKey {
		case people = "person"
		var namespace: Namespace? { ContactList.namespace }
		var nodeKind: CodingNodeKind { .element }
	}
	
}

struct Person : Decodable, Equatable {
	
	var firstName: String
	var lastName: String
	var gender: Gender?
	var mother: Parent?
	var father: Parent?
	var hobbies: [Hobby] = []
	
	enum CodingKeys : String, XMLCodingKey {
		
		case firstName
		case lastName
		case gender
		case mother
		case father
		case hobbies = "hobby"
		
		var namespace: Namespace? {
			ContactList.namespace
		}
		
		var nodeKind: CodingNodeKind {
			switch self {
				case .firstName, .lastName:	return .attribute
				default:					return .element
			}
		}
		
	}
	
}

struct Parent : Decodable, Equatable {
	
	var firstName: String
	var lastName: String
	
	enum CodingKeys : XMLCodingKey {
		case firstName
		case lastName
		var namespace: Namespace? { ContactList.namespace }
		var nodeKind: CodingNodeKind { .attribute }
	}
	
}

enum Gender : String, Decodable, Equatable {
	case male = "m"
	case female = "f"
	case other = "x"
}

struct Hobby : Decodable, Equatable {
	
	init(shortDescription: String, obsession: Int? = nil) {
		self.shortDescription = shortDescription
		self.obsession = obsession
	}
	
	init(from decoder: Decoder) throws {
		shortDescription = try decoder.singleValueContainer().decode(String.self)
		obsession = try decoder.container(keyedBy: CodingKey.self).decodeIfPresent(key: .obsession)
	}
	
	enum CodingKey : XMLCodingKey {
		case obsession
		var namespace: Namespace? { ContactList.namespace }
		var nodeKind: CodingNodeKind { .attribute }
	}
	
	var shortDescription: String
	var obsession: Int?
	
}
