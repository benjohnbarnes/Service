import Foundation

/// An example `Context` for a ``URLRequestServiceDefinition`` as used for ``GreetingService``. Merely holds
/// a base URL for the services in this module. This allows for environments to be easily replaced.
/// 
public struct GreetingServicesContext {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
