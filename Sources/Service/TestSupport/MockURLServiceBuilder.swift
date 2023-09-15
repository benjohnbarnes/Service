import Foundation

public final class MockURLServiceBuilder<Context>: URLServiceBuilder {

    var context: Context

    /// A stub result to provide to the calling subject.
    public var stubResult: URLResult

    /// Any most recent request made by the test subject.
    public var spyRequest: URLRequest?

    public convenience init(context: Context) {
        self.init(context: context, stubResult: .failure(UndefinedURLResponse()))
    }

    public init(context: Context, stubResult: URLResult) {
        self.context = context
        self.stubResult = stubResult
    }

    public func buildService<D: ServiceDefinition>(
        _ serviceFunction: (Context, @escaping PerformURLRequest) -> D.Implementation
    ) -> Service<D>  {
        return Service(implementation: serviceFunction(context, perform(request:)))
    }

    func perform(request: URLRequest) async -> URLResult {
        spyRequest = request
        return stubResult
    }
}

public struct UndefinedURLResponse: Error {}

