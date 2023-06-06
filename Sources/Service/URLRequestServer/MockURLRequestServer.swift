// MARK: - Testing example URL service with `MockURLRequestServer`

/// ``MockURLRequestServer`` implements ``URLServer`` as a test double. It provides for testing of
/// ``URLRequestServiceDefinition`` services.
///
public final class MockURLRequestServer: URLRequestServer {

    var spyRequest: URLRequest?
    var stubResult: URLResult = .failure(NoResultDefined())

    public func callAsFunction(_ request: URLRequest) async -> URLResult {
        stubResult
    }

    struct NoResultDefined: Error {}
}

final class GreetingServiceDefinitionTests: XCTestCase {

    let mockServer = MockURLRequestServer()

    func test_requestHasCorrectURL() async throws {
        let service = GreetingServiceDefinition.createService(inContext: Void(), usingServer: mockServer)
        _ = await service("hello")
        XCTAssertEqual(mockServer.spyRequest?.url, URL(string: "hello"))
    }
}

