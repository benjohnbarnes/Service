import Foundation

/// Implementation of `ServiceProvider` to allow service creation functions to be unit tested.
///
public final class MockServiceContext: ServiceContext {

    public var baseURL: URL

    /// Any most recent request made by the test subject.
    public var spyRequest: URLRequest?

    /// A stub result to provide to the calling subject.
    public var stubResult: URLResult

    public init(baseURL: URL, stubResult: URLResult = .failure(UndefinedURLResponse())) {
        self.baseURL = baseURL
        self.stubResult = stubResult
    }

    public func perform(_ request: URLRequest) async -> URLResult {
        spyRequest = request
        return stubResult
    }
}

public struct UndefinedURLResponse: Error {
    public init() {}
}

