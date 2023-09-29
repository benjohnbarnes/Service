import Foundation

/// Implementation of `ServiceContext` to let modules be used with stubbed services. These
/// might read from a folder of local files that simulate some specific testing scenario.
/// 
public final class StubbingServiceContext: ServiceContext {

    public var baseURL: URL
    var stubResults: [URL: URLResult]

    /// A more useful implementation could take a folder in which to look for response stubs.
    public init(baseURL: URL, stubResults: [URL : URLResult]) {
        self.baseURL = baseURL
        self.stubResults = stubResults
    }

    public func perform(_ request: URLRequest) async -> URLResult {
        guard let url = request.url else {
            return .failure(RequestHasNoURL(request: request))
        }

        guard let result = stubResults[url] else {
            return .failure(RequestHasNoStub(request: request))
        }

        return result
    }

    public struct RequestHasNoURL: Error { let request: URLRequest }
    public struct RequestHasNoStub: Error { let request: URLRequest }
}
