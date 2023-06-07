import Foundation

/// ``MockURLRequestServer`` implements ``URLServer`` as a test double.
///
/// Use ``MockURLRequestServer`` to test service definitions conforming to ``URLRequestServiceDefinition``.
///
public final class MockURLRequestServer: URLRequestServer {

    public var spyRequest: URLRequest?
    public var stubResult: URLResult

    public init(stubResult: MockURLRequestServer.URLResult = .failure(NoResultDefined())) {
        self.stubResult = stubResult
    }

    public func performRequest(_ request: URLRequest) async -> URLResult {
        spyRequest = request
        return stubResult
    }

    public struct NoResultDefined: Error, Equatable {
        public init() {}
    }
}
