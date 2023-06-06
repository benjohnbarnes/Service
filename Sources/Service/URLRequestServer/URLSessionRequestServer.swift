import Foundation

/// ``URLSessionRequestServer`` implements ``URLRequestService`` implementation using ``URLSession``.
/// You might want to use a custom implementation letting you hook in to request before they are performed,
/// or after they are completed.
///
public struct URLSessionRequestServer: URLRequestServer {
    let session: URLSession

    public func performRequest(_ request: URLRequest) async -> URLResult {
        let task = Task { try await session.data(for: request) }
        return await task.result.map { ($0, $1) }
    }
}

