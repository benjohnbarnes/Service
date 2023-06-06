import Foundation
import Service

/// A trivial example service definition being made publicly available for use by other modules, and for use
/// in this modules' units.
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

    public typealias Context = GreetingServicesContext

    public static func createService(inContext context: GreetingServicesContext, usingServer urlServer: URLRequestServer) -> ServiceImplementation {
        { input in
            /// Need to flesh this out showing how ``Context`` is useful and show that it is testable.
            let url = context.baseURL
                .appending(path: "greeting")
                .appending(path: input)

            let request = URLRequest(url: url)
            let result = await urlServer(request)

            return Result {
                let (data, _) = try result.get()
                guard let string = String(data: data, encoding: .utf8) else { throw NotUTF8(data: data) }
                return string
            }
        }
    }

    struct NotUTF8: Error { let data: Data }
}
