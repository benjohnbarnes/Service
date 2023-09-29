import Foundation

/// Implementation of `ServiceContext` for production use. Actually sends `URLRequest`s to
/// a `URLSession`
///
public struct URLSessionServiceContext: ServiceContext {

    let session: URLSession
    public let baseURL: URL

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func perform(_ request: URLRequest) async -> URLResult {
        do {
            let (data, response) = try await session.data(for: request)
            return .success((data: data, urlResponse: response))
        }
        catch {
            return .failure(error)
        }
    }
}

