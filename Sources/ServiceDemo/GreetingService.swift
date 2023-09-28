import Foundation
import Service

/// A trivial example service definition being made publicly available for use by other modules, and for use
/// in this modules' units.
///
/// Note that this trivial example does not yet even hint at how it is implemented, and it is agnostic
/// to how a client consumes it.
///
public typealias GreetingService = Service<String, Result<String, Error>>

// MARK: - Extend example service with URL implementation

/// Now `GreetingService`` can be extended to implement ``URLRequestServiceDefinition``.
///
public extension GreetingService {

    /// Build a `GreetingService` from `some ServiceContext`.
    ///
    /// This can be used directly in a unit test, or it can be used in a module instance to build
    /// service to inject in to units. By providing an appropriate `ServiceContext` implementation
    /// the services built can be mocked, stubbed, or pointed to real production services. Adjusting
    /// the implementation's properties allows alternative server environments to be used, etc.
    /// 
    static func greetingService(in context: some ServiceContext) -> Self {
        Service { input in
            let url = context.baseURL
                .appending(path: "greeting")
                .appending(path: input)

            let request = URLRequest(url: url)
            let result = await context.perform(request)

            return Result {
                let (data, _) = try result.get()
                guard let string = String(data: data, encoding: .utf8) else { throw NotUTF8(data: data) }
                return string
            }
        }
    }

    struct NotUTF8: Error { let data: Data }
}
