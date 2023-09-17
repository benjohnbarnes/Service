import Foundation

/// Implementation of `URLServiceBuilder` intended for production use that
/// will build services calling a `URLSession` instance.
///
public struct URLServiceProvider<Context>: URLServiceProviding {

    let session: URLSession
    public let context: Context

    public init(context: Context, session: URLSession = .shared) {
        self.context = context
        self.session = session
    }

    public func perform(request: URLRequest) async -> URLResult {
        do {
            let (data, response) = try await session.data(for: request)
            return .success((data: data, urlResponse: response))
        }
        catch {
            return .failure(error)
        }
    }
}

