import Foundation
import XCTest
import Service
import ServiceDemo

/// DOCUMENT!
/// 
final class GreetingServiceDefinitionTests: XCTestCase {

    let mockProvider = MockServiceContext(baseURL: .testBaseURL)
    lazy var subject: GreetingService = .greetingService(in: mockProvider)

    func test_requestHasCorrectURL() async throws {
        _ = await subject("hello")
        XCTAssertEqual(mockProvider.spyRequest?.url, URL(string: "example.com/greeting/hello"))
    }

    func test_requestHasCorrectMethod() async throws {
        _ = await subject("hello")
        XCTAssertEqual(mockProvider.spyRequest?.httpMethod, "GET")
    }

    func test_requestHasCorrectHeaders() async throws {
        _ = await subject("hello")
        XCTAssertNil(mockProvider.spyRequest?.allHTTPHeaderFields)
    }

    func test_parsesResponseData() async throws {
        let data = try XCTUnwrap("greet".data(using: .utf8))
        mockProvider.stubResult = .success((data, URLResponse()))
        let result = await subject("hello")
        XCTAssertEqual(try result.get(), "greet")
    }
}

// MARK: -

private extension URL {
    static let testBaseURL = URL(string: "example.com")!
}

