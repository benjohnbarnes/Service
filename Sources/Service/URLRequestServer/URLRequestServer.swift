import Foundation

/// We now want to provide implementations of the so far abstract services. The focus here will be services
/// that use ``URLSession``.
///
/// ``URLRequestServer`` is a thing able to provide a response to a ``URLRequest``
///
public protocol URLRequestServer {
    func callAsFunction(_ request: URLRequest) async -> URLResult
    typealias URLResult = Result<(data: Data, urlResponse: URLResponse), Error>
}

