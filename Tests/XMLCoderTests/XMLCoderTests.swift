import XCTest
@testable import XMLCoder

final class XMLCoderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XMLCoder().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
