import Foundation

/// `MockURLRequesting` is a test double `URLRequesting`.
///
/// Use `MockURLRequesting` to test `URLServiceDefinition` implementations.
///
public final class MockURLRequesting: URLRequesting {

    /// Any most recent request made by the test subject.
    public var spyRequest: URLRequest?

    /// A stub result to provide to the calling subject.
    public var stubResult: URLResult

    /// - Parameter stubResult: Optional result to provide the subject.
    /// When none is given the error `NoResultDefined` is given.
    public init(stubResult: MockURLRequesting.URLResult = .failure(NoResultDefined())) {
        self.stubResult = stubResult
    }

    /// Implement `URLRequesting` interface.
    public func performRequest(_ request: URLRequest) async -> URLResult {
        spyRequest = request
        return stubResult
    }

    /// Default failure to respond to the test subject with.
    public struct NoResultDefined: Error, Equatable {
        public init() {}
    }
}
