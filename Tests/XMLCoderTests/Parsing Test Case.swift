// XMLCoder © 2019 Creatunit

import XCTest
@testable import XMLCoder

final class ParsingTestCase : XCTestCase {
	
	static let namespace = "so much whitespace"
	
	static let flatXMLString = """
	<?xml version="1.0" encoding="utf-8"?>
	<c:contactList xmlns:c="\(namespace)">
		<c:person c:firstName="Jake" c:lastName="Andrews">
			<c:gender>m</c:gender>
			<c:mother c:firstName="Lisa" c:lastName="Anitsen" />
			<c:father c:firstName="Rob" c:lastName="Andrews" />
			<c:hobby>Hiking</c:hobby>
			<c:hobby>Tennis</c:hobby>
		</c:person>
		<c:person c:firstName="Lotte" c:lastName="Bewyok">
			<c:gender>f</c:gender>
			<c:mother c:firstName="Pam" c:lastName="Bewyok" />
			<c:father c:firstName="Prem" c:lastName="Bewyok" />
			<c:hobby>Biking</c:hobby>
		</c:person>
			<c:person c:firstName="Jeff" c:lastName="Cook">
			<c:mother c:firstName="Pam" c:lastName="Bewyok" />
		</c:person>
	</c:contactList>
	"""
	
}
