import Foundation

public struct URLSessionServiceBuilder<Context> {

    let context: Context
    let session: URLSession

    public init(context: Context, session: URLSession) {
        self.context = context
        self.session = session
    }

    public func buildService<Definition: ServiceDefinition>(
        _ serviceFunction: (Context, any URLRequesting) -> Definition.Implementation
    ) -> Service<Definition> {
        return Service(implementation: serviceFunction(context, self))
    }
}

// MARK: -

extension URLSessionServiceBuilder: URLRequesting {
    public func performRequest(_ request: URLRequest) async -> URLResult {
        do {
            let (data, response) = try await session.data(for: request)
            return .success((data: data, urlResponse: response))
        }
        catch {
            return .failure(error)
        }
    }
}
