import Foundation

/// ``MockURLRequestServer`` implements ``URLServer`` as a test double. It provides for testing of
/// ``URLRequestServiceDefinition`` services.
///
public final class MockURLRequestServer: URLRequestServer {

    public var spyRequest: URLRequest?
    public var stubResult: URLResult

    public init(stubResult: MockURLRequestServer.URLResult = .failure(NoResultDefined())) {
        self.stubResult = stubResult
    }

    public func callAsFunction(_ request: URLRequest) async -> URLResult {
        stubResult
    }

    public struct NoResultDefined: Error {
        public init() {}
    }
}

