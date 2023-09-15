import XCTest
@testable import Service

final class MockURLServiceBuilderTests: XCTestCase {

    let subject = MockURLServiceBuilder(context: UUID.test)

    func test_spyRequest_givenServiceNotInvoked_thenIsNil() async throws {
        XCTAssertNil(subject.spyRequest)
    }

    func test_spyRequest_whenRequestInvoked_thenHoldsRequest() async throws {
        _ = await subject.perform(request: .test)
        XCTAssertEqual(subject.spyRequest?.url, .test)
    }

    func test_stubResult_givenInitialState_whenServiceInvoked_thenServiceResultIsError() async throws {
        let result = await subject.perform(request: .test)

        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertNotNil(error as? UndefinedURLResponse)
        }
    }

    func test_stubResult_whenModifiedToSuccessAndServiceInvoked_thenServiceResultIsModified() async throws {
        subject.stubResult = .success((data: .test, urlResponse: .test))

        let success = try await subject.perform(request: .test).get()

        XCTAssertEqual(success.data, .test)
        XCTAssertEqual(success.urlResponse.url, .test)
        XCTAssertEqual(success.urlResponse.expectedContentLength, 321)
    }
}

// MARK: -

private extension URLRequest {
    static let test = Self(url: .test)
}

private extension URL {
    static let test = Self(string: "hello.com/test-service")!
}

private extension Data {
    static let test = "test-data".data(using: .utf8)!
}

private extension URLResponse {
    static let test = URLResponse(url: .test, mimeType: nil, expectedContentLength: 321, textEncodingName: nil)
}

private extension UUID {
    static let test = UUID()
}

private enum DummyService: ServiceDefinition {
    typealias Input = URLRequest
    typealias Output = URLResult
}
