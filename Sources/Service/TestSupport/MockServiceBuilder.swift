import Foundation

public final class MockServiceBuilder<Context>: ServiceBuilder {

    var context: Context

    /// A stub result to provide to the calling subject.
    public var stubResult: URLRequesting.URLResult

    /// Any most recent request made by the test subject.
    public var spyRequest: URLRequest?

    public convenience init(context: Context) {
        self.init(context: context, stubResult: .failure(UndefinedResponse()))
    }

    public init(context: Context, stubResult: URLRequesting.URLResult) {
        self.context = context
        self.stubResult = stubResult
    }

    public func buildService<Definition>(_ serviceFunction: (Context, URLRequesting) -> Definition.Implementation) -> Service<Definition> where Definition : ServiceDefinition {
        Service(implementation: serviceFunction(context, self))
    }

    public struct UndefinedResponse: Error {}
}

// MARK: -

extension MockServiceBuilder: URLRequesting {
    public func performRequest(_ request: URLRequest) async -> URLRequesting.URLResult {
        spyRequest = request
        return stubResult
    }
}
