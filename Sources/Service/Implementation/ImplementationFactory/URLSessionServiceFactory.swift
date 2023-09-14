import Foundation

/// Give your module a `URLSessionServiceFactory` to build real production services.
///
/// `URLSessionServiceFactory` implements `URLServiceFactory`, building service instances that
/// perform calls using a `Foundation.URLSession`.
///
/// The factory holds a `Context` instance. This is shared state available to `URLServiceDefinition`
/// when an `AsyncService` service is built for them. `URLSessionServiceFactory` can build services
/// for any `URLServiceDefinition` which matches its `Context`.
///
public struct URLSessionServiceFactory<Context> {

    private let context: Context
    private let session: URLSession

    public init(context: Context, session: URLSession) {
        self.context = context
        self.session = session
    }
}

// MARK: -

extension URLSessionServiceFactory: URLServiceFactory {

    /// Build an implementation for `Definition`.
    public func makeService<Definition: URLServiceDefinition>() -> any AsyncService<Definition> where Definition.Context == Context {
        let server = Server(session: session)
        let implementation = Definition.implementation(in: context, using: server)
        return Service(implementation: implementation)
    }

    private struct Service<Definition: URLServiceDefinition>: AsyncService {
        let implementation: (Definition.Input) async -> Definition.Output

        public func callAsFunction(_ input: Definition.Input) async -> Definition.Output {
            await implementation(input)
        }
    }

    private struct Server: URLRequesting {
        public let session: URLSession

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
}
