// XMLCoder © 2019 Creatunit

import XCTest
import XMLCoder

final class ContactListTestCase : XCTestCase {
	
	let expected = ContactList(people: [
		.init(
			firstName:	"Jake",
			lastName:	"Andrews",
			gender:		.male,
			mother:		.init(firstName: "Lisa", lastName: "Anitsen"),
			father:		.init(firstName: "Rob", lastName: "Andrews"),
			hobbies:	[.init(shortDescription: "Hiking"), .init(shortDescription: "Tennis")]
		),
		.init(
			firstName:	"Lotte",
			lastName:	"Bewyok",
			gender:		.female,
			mother:		.init(firstName: "Pam", lastName: "Bewyok"),
			father:		.init(firstName: "Prem", lastName: "Bewyok"),
			hobbies:	[.init(shortDescription: "Biking", obsession: 9001)]
		),
		.init(
			firstName:	"Jeff",
			lastName:	"Cook",
			gender:		.male,
			mother:		.init(firstName: "Gwen", lastName: "Cook")
		)
	])
	
	let xmlString = """
		<?xml version="1.1" encoding="UTF-8"?>
		<c:contactList xmlns:c="\(ContactList.namespace)">
			<c:person c:firstName="Jake" c:lastName="Andrews">
				<c:gender>m</c:gender>
				<c:mother c:firstName="Lisa" c:lastName="Anitsen" />
				<c:father c:firstName="Rob" c:lastName="Andrews" />
				<c:hobby>Hiking</c:hobby>
				<c:hobby>Tennis</c:hobby>
			</c:person>
			<c:person c:firstName="Lotte" c:lastName="Bewyok">
				<c:gender>f</c:gender>
				<c:father c:firstName="Prem" c:lastName="Bewyok" />
				<c:mother c:firstName="Pam" c:lastName="Bewyok" />
				<c:hobby c:obsession="9001">Biking</c:hobby>
			</c:person>
			<c:person c:firstName="Jeff" c:lastName="Cook">
				<c:gender>m</c:gender>
				<c:mother c:firstName="Gwen" c:lastName="Cook" />
			</c:person>
		</c:contactList>
		"""
	
	func testDecoding() throws {
		
		var configuration = DecodingConfiguration()
		configuration.unkeyedDecodingContainersUseContainerElements = false
		let decoder = try ElementDecoder(from: xmlString.data(using: .utf8)!, configuration: configuration)
		
		let actual = try decoder.decodeRootValue(ofType: ContactList.self)
		
		XCTAssertEqual(expected, actual)
		
	}
	
}
