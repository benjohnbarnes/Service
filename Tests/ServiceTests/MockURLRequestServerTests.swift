import XCTest
import Service

final class MockURLRequestServerTests: XCTestCase {

    let subject = MockURLRequestServer()

    func test_spyRequest_givenServiceNotInvoked_thenIsNil() async throws {
        XCTAssertNil(subject.spyRequest)
    }

    func test_spyRequest_whenServiceInvoked_thenHoldsRequest() async throws {
        _ = await subject.performRequest(.test)
        XCTAssertEqual(subject.spyRequest?.url, .test)
    }

    func test_stubResult_givenInitialState_whenServiceInvoked_thenServiceResultIsError() async throws {
        let result = await subject.performRequest(.test)
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertNotNil(error as? MockURLRequestServer.NoResultDefined)
        }
    }

    func test_stubResult_whenModifiedToSuccessAndServiceInvoked_thenServiceResultIsModified() async throws {
        subject.stubResult = .success((data: .test, urlResponse: .test))

        let success = try await subject.performRequest(.test).get()

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
