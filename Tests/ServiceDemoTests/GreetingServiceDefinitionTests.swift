import Foundation
import XCTest
import Service
import ServiceDemo

final class GreetingServiceDefinitionTests: XCTestCase {

    let mockBuilder = MockURLServiceProvider<GreetingServicesContext>(context: .test)
    lazy var subject: GreetingService = .service(using: mockBuilder)

    func test_requestHasCorrectURL() async throws {
        _ = await subject("hello")
        XCTAssertEqual(mockBuilder.spyRequest?.url, URL(string: "example.com/greeting/hello"))
    }

    func test_requestHasCorrectMethod() async throws {
        _ = await subject("hello")
        XCTAssertEqual(mockBuilder.spyRequest?.httpMethod, "GET")
    }

    func test_requestHasCorrectHeaders() async throws {
        _ = await subject("hello")
        XCTAssertNil(mockBuilder.spyRequest?.allHTTPHeaderFields)
    }

    func test_parsesResponseData() async throws {
        let data = try XCTUnwrap("greet".data(using: .utf8))
        mockBuilder.stubResult = .success((data, URLResponse()))
        let result = await subject("hello")
        XCTAssertEqual(try result.get(), "greet")
    }
}

// MARK: -

private extension GreetingServicesContext {
    static let test = GreetingServicesContext(baseURL: URL(string: "example.com")!)
}

