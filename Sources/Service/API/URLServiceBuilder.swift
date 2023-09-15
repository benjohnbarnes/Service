import Foundation

/// Types that build `Service` implementations.
///
/// All services built by a `URLServiceBuilder` are given a shared generic `Context` value.
/// `Context` can be used to provide the services with details such as:
///
/// * Mapping from service paths to URLs.
/// * Authorisation token mechanisms.
/// * Telemetry for response parsing errors.
///
/// Its anticipated that all services in a module, a collections of modules, or an entire
/// applications, might use the same `Context`.
///
public protocol URLServiceBuilder<Context> {

    /// A type given to all service implementations to pass them common shared details
    /// needed by their implementations.
    ///
    associatedtype Context

    /// Create a service implementing a `ServiceDefinition`'s interface.
    ///
    /// - Parameter serviceFunction: Function to construct a service implementation.
    /// It will be invoked with the shared `Context` holding common details and a
    /// `URLRequestor` able to perform a `URLRequest`.
    ///
    func buildService<Definition: ServiceDefinition>(
        _ serviceFunction: (Context, @escaping PerformURLRequest) -> Definition.Implementation
    ) -> Service<Definition>
}

// MARK: -

/// Function able to invoke a `URLRequest` and provide a `URLResult`
///
public typealias PerformURLRequest = (URLRequest) async -> URLResult

/// Response value provided by `PerformURLRequest`. A `Result` with the
/// `URLSession`'s successful response or an error that it threw.
/// 
public typealias URLResult = Result<(data: Data, urlResponse: URLResponse), Error>
