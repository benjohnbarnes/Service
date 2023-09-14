import Foundation
import XCTest
import Service
import ServiceDemo

final class GreetingServiceDefinitionTests: XCTestCase {

    let mockServer = MockURLRequesting()
    lazy var subject = GreetingServiceDefinition.implementation(in: .test, using: mockServer)

    func test_requestHasCorrectURL() async throws {
        _ = await subject("hello")
        XCTAssertEqual(mockServer.spyRequest?.url, URL(string: "example.com/greeting/hello"))
    }

    func test_requestHasCorrectMethod() async throws {
        _ = await subject("hello")
        XCTAssertEqual(mockServer.spyRequest?.httpMethod, "GET")
    }

    func test_requestHasCorrectHeaders() async throws {
        _ = await subject("hello")
        XCTAssertNil(mockServer.spyRequest?.allHTTPHeaderFields)
    }

    func test_parsesResponseData() async throws {
        let data = try XCTUnwrap("greet".data(using: .utf8))
        mockServer.stubResult = .success((data, URLResponse()))
        let result = await subject("hello")
        XCTAssertEqual(try result.get(), "greet")
    }
}

// MARK: -

private extension GreetingServicesContext {
    static let test = GreetingServicesContext(baseURL: URL(string: "example.com")!)
}

