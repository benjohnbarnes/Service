import Foundation

public extension URLServiceProviding {
    typealias Mock = MockURLServiceProvider<Context>
}

// MARK: -

public final class MockURLServiceProvider<Context>: URLServiceProviding {

    /// The `Context` shared by services created from this builder.
    public var context: Context

    /// Any most recent request made by the test subject.
    public var spyRequest: URLRequest?

    /// A stub result to provide to the calling subject.
    public var stubResult: URLResult

    public convenience init(context: Context) {
        self.init(context: context, stubResult: .failure(UndefinedURLResponse()))
    }

    public init(context: Context, stubResult: URLResult) {
        self.context = context
        self.stubResult = stubResult
    }

    public func perform(request: URLRequest) async -> URLResult {
        spyRequest = request
        return stubResult
    }
}

public struct UndefinedURLResponse: Error {}

