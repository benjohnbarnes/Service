import Foundation

/// ``StubURLRequestServer`` implements ``URLServer`` using a source of stub responses.
///
/// Use ``StubURLRequestServer`` to test feature module behaviour either in an XCTest, or in an app
/// running against predefined scenarios.
///
/// TODO – think this needs a bunch of expansion by providing a standard mechanism for how a set of stubs
/// would be defined. This might be flexible so that a cross platform common scenario folder
/// can be used, although ``URLRequestServer`` is such a simple interface that customisation can easily
/// be achieved by just implementing one.
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

