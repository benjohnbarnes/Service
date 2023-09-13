import Foundation

/// `URLServiceDefinition` extends `ServiceDefinition` to provide an implementation
/// utilising a `URLServer` instance.
///
/// It's expected that most services are likely to conform to `URLServiceDefinition`. However,
/// prior to an implementation being available a service definition may only conform to
/// `ServiceDefinition`.
///
/// `URLServiceDefinition` provides a `Context` mechanism letting a utilising App provide definitions
/// with additional state necessary for them to build an implementation. Possibilities include:
/// 
/// * A mechanism for mapping somewhat abstract service paths to specific URLs.
/// * Facilities for error capture and observability.
/// * Additional headers that should be added to requests.
/// * Facilities for token based authentication.
///
public protocol URLServiceDefinition: ServiceDefinition {

    /// Contextual details this service requires so as to construct a `URLRequest` or parse its response.
    /// It is expected all service definitions from a module (and related module families) would share a
    /// `Context` type, but that apps might consume service sets or integrated features which use differing
    /// `Context` types.
    ///
    /// A primary anticipated use of `Context` is to provide a facility to map a service's Path to an actual
    /// URL in some backend environment. Other uses could be authorisation facilities, and a mechanism for
    /// parsing error instrumentation.
    ///
    associatedtype Context

    /// Create an implementation of this service within some `Context` performing the request against a
    /// `URLServer`.
    ///
    static func implementation(in context: Context, using urlServer: URLServer) -> AsyncImplementation
}

// MARK: -

extension ServiceDefinition {
    /// An async func providing an implementation of this `ServiceDefinition`.
    ///
    /// Note that this type is provided on all `ServiceDefinition` allowing `MockAsyncService`
    /// to be built for any `ServiceDefinition`, even before it provides some mechanism to obtain
    /// an async implementation.
    ///
    /// It is intentional that the implementation does not throw and error information wanted by
    /// calling clients must be provided in the `Output` type. Clients requiring a throwing interface
    /// can add an extension for this if desired.
    ///
    public typealias AsyncImplementation = (Input) async -> Output
}

// MARK: -

/// `URLServer` provides a `URLResult` for a `URLRequest`.
///
///
public protocol URLServer {
    func performRequest(_ request: URLRequest) async -> URLResult
    typealias URLResult = Result<(data: Data, urlResponse: URLResponse), Error>
}
