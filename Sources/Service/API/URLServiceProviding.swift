import Foundation

/// Types for building `Service` implementations which operate via a `URLRequest` to a
/// `URLSession` returning a `URLResult`.
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
/// Service provides a production instance of `URLServiceBuilder` and a mock instance to
/// assist with testing services.
///
public protocol URLServiceProviding<Context> {

    /// A type given to all service implementations to pass them common shared details
    /// needed by their implementations.
    ///
    associatedtype Context

    /// Access to the associated context information.
    var context: Context { get }

    /// Perform a URLRequest and await the result.
    func perform(request: URLRequest) async -> URLResult
}

// MARK: -

/// Response value provided by `PerformURLRequest`. A `Result` with the
/// `URLSession`'s successful response or an error that it threw.
/// 
public typealias URLResult = Result<(data: Data, urlResponse: URLResponse), Error>
