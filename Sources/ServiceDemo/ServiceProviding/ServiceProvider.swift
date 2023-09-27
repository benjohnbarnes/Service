import Foundation

/// Implementation of `ServiceProvider` for production use. Actually sends `URLRequest`s to
/// a `URLSession`
///
public struct ServiceProvider: ServiceProviding {

    let session: URLSession
    public let baseURL: URL

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
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

