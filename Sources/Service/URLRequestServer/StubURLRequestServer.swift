import Foundation

/// ``StubURLRequestServer`` implements ``URLServer`` using a dictionary of stub responses. This lets us
/// instantiate a module with a service factory reading from stub files.
///
public final class StubURLRequestServer: URLRequestServer {

    var stubs: [URL: URLResult]
    var missingStubError: Error

    internal init(stubs: [URL : URLResult], missingStubError: Error) {
        self.stubs = stubs
        self.missingStubError = missingStubError
    }

    public func performRequest(_ request: URLRequest) async -> URLResult {
        guard let url = request.url else { return missingStubResult }
        return stubs[url] ?? missingStubResult
    }

    private var missingStubResult: URLResult { .failure(missingStubError) }
}

