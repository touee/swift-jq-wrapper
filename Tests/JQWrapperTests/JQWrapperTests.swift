import XCTest
@testable import JQWrapper

let json1 = #"[{"a": 1, "b": 2}, {"a": 2, "c": 3}, {"a": "%@"}]"#

final class JQWrapperTests: XCTestCase {
    func testOne() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(JQWrapper().text, "Hello, World!")
        let jq = try! JQ(query: #"[.[].a]"#)
        XCTAssertEqual(#"[1,2,"foo"]"#, try! jq.executeOne(input: json1))
    }
    
    func testOneReuse() {
        let jq = try! JQ(query: #"[.[].a]"#)
        for i in 0..<10000 {
            let rand = String((0..<10000000).randomElement()!)
            print(i, rand)
            XCTAssertEqual(String(format: #"[1,2,"%@"]"#, rand) , try! jq.executeOne(input: String(format: json1, rand)))
        }
    }

    func testOneMultiInstances() {
        for i in 0..<100 {
        let jq = try! JQ(query: #"[.[].a]"#)
            let rand = String((0..<10000000).randomElement()!)
            print(i, rand)
            XCTAssertEqual(String(format: #"[1,2,"%@"]"#, rand) , try! jq.executeOne(input: String(format: json1, rand)))
        }
    }

    static var allTests = [
        ("testOne", testOne),
        ("testOneReuse", testOneReuse),
        ("testOneMultiInstances", testOneMultiInstances),
    ]
}
