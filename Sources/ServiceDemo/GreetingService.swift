import Foundation
import Service

/// A trivial example service definition being made publicly available in a module for use by other
/// modules.
///
/// Note that this trivial example does not yet even hint at how it is implemented, and it is agnostic
/// to how a client consumes it.
///
public enum GreetingServiceDefinition: ServiceDefinition {

    public typealias Input = String
    public typealias Output = Result<String, Error>
}

// MARK: - Extend example service with URL implementation

/// Now `GreetingService`` can be extended to implement ``URLRequestServiceDefinition``.
///
extension GreetingServiceDefinition: URLRequestServiceDefinition {

    public typealias Context = Void

    public static func createService(inContext context: Context, usingServer urlServer: URLRequestServer) -> ServiceImplementation {
        /// Need to flesh this out showing how ``Context`` is useful and show that it is testable.
        var request = URLRequest(url: URL(string: "Hello")!)
        request.url = URL(string: "Hey")!
        fatalError()
    }
}

