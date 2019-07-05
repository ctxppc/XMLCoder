// XMLCoder © 2019 Creatunit

import XCTest
import XMLCoder

final class LogbookTestCase : XCTestCase {
	
	let xmlString = """
		<?xml version="1.1" encoding="UTF-8"?>
		<logbook xmlns="\(Logbook.namespace)" lastEdited="2019-07-05T13:49:27Z">
			<owner>
				<name>Jeff Appleton</name>
				<email>j.appleton@shipbuilding.example.com</email>
			</owner>
			<auditor>
				<name>Blake Inspector</name>
				<email>blake@inspections.example.gov</email>
			</auditor>
			<entries ignorableAttribute="ignore-me-please">
				<entry date="2018-01-01T00:01:55Z">
					<title>Happy New Year's!</title>
					<severity>info</severity>
				</entry>
				<entry date="2019-07-04T13:21:11Z">
					<severity>warning</severity>
					<title>Fireworks supply stolen</title>
				</entry>
			</entries>
			<notes>
				<note date="2019-07-04T16:00:30Z">I think Jake might've used them. Blame Jake.</note>
			</notes>
			<stamps>
				<!-- Add approval stamps here -->
			</stamps>
		</logbook>
		"""
	
	let expected = Logbook(
		lastEdited:	"2019-07-05T13:49:27Z",
		owner:		.init(name: "Jeff Appleton", email: "j.appleton@shipbuilding.example.com"),
		auditor:	.init(name: "Blake Inspector", email: "blake@inspections.example.gov"),
		entries:	[
			.init(date: "2018-01-01T00:01:55Z", title: "Happy New Year's!", severity: .info),
			.init(date: "2019-07-04T13:21:11Z", title: "Fireworks supply stolen", severity: .warning)
		],
		notes:		[
			.init(date: "2019-07-04T16:00:30Z", text: "I think Jake might've used them. Blame Jake.")
		],
		stamps:		[]
	)
	
	func testDecoding() throws {
		
		var configuration = DecodingConfiguration()
		configuration.unkeyedDecodingContainersUseContainerElements = true
		let decoder = try ElementDecoder(from: xmlString.data(using: .utf8)!, configuration: configuration)
		
		let actual = try decoder.decodeRootValue(ofType: Logbook.self)
		
		XCTAssertEqual(expected, actual)
		
	}
	
}

extension Date : ExpressibleByStringLiteral {
	
	public typealias StringLiteralType = String
	
	public init(stringLiteral stringValue: String) {
		self = ISO8601DateFormatter().date(from: stringValue)!
	}
	
}
