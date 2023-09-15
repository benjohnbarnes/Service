import Foundation

/// Implementation of `URLServiceBuilder` intended for production use that
/// will build services calling a `URLSession` instance.
///
public struct URLSessionServiceBuilder<Context>: URLServiceBuilder {

    let context: Context
    let session: URLSession

    public init(context: Context, session: URLSession = .shared) {
        self.context = context
        self.session = session
    }

    public func buildService<D: ServiceDefinition>(
        _ serviceFunction: (Context, @escaping PerformURLRequest) -> D.Implementation
    ) -> Service<D> {
        return Service(implementation: serviceFunction(context, perform(request:)))
    }

    private func perform(request: URLRequest) async -> URLResult {
        do {
            let (data, response) = try await session.data(for: request)
            return .success((data: data, urlResponse: response))
        }
        catch {
            return .failure(error)
        }
    }
}

