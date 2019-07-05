// XMLCoder © 2019 Creatunit

import XCTest
@testable import XMLCoder

final class ContactListTestCase : XCTestCase {
	
	static let list = ContactList(people: [
		Person(
			firstName:	"Jake",
			lastName:	"Andrews",
			gender:		.male,
			mother:		Parent(firstName: "Lisa", lastName: "Anitsen"),
			father:		Parent(firstName: "Rob", lastName: "Andrews"),
			hobbies:	[Hobby(shortDescription: "Hiking"), Hobby(shortDescription: "Tennis")]
		),
		Person(
			firstName:	"Lotte",
			lastName:	"Bewyok",
			gender:		.female,
			mother:		Parent(firstName: "Pam", lastName: "Bewyok"),
			father:		Parent(firstName: "Prem", lastName: "Bewyok"),
			hobbies:	[Hobby(shortDescription: "Biking", obsession: 9001)]
		),
		Person(
			firstName:	"Jeff",
			lastName:	"Cook",
			gender:		.male,
			mother:		Parent(firstName: "Gwen", lastName: "Cook")
		)
	])
	
	static let flatXMLString = """
		<?xml version="1.0" encoding="utf-8"?>
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
	
	func testFlatString() throws {
		
		var configuration = DecodingConfiguration()
		configuration.unkeyedDecodingContainersUseContainerElements = false
		let decoder = try ElementDecoder(from: Self.flatXMLString.data(using: .utf8)!, configuration: configuration)
		
		let expected = Self.list
		let actual: ContactList = try decoder.decodeRootValue()
		
		XCTAssertEqual(expected, actual)
		
	}
	
}
