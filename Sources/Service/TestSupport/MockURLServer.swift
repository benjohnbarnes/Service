import Foundation

/// `MockURLServer` implements `URLServer` as a test double.
///
/// Use `MockURLServer` to test `URLServiceDefinition` implementations.
///
public final class MockURLServer: URLServer {

    public var spyRequest: URLRequest?
    public var stubResult: URLResult

    public init(stubResult: MockURLServer.URLResult = .failure(NoResultDefined())) {
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
