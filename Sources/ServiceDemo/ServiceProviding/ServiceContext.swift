import Foundation

/// Interface for types with facilities from which service implementations (of this
/// module and related modules) are built.
///
/// NB: this is a strongly advised pattern to serve as an example. It is **not** a
/// specific protocol for use in your projects.
///
/// It would be expected that related modules will share a common interface similar
/// in intent (but not not necessarily detail) to this `ServiceContext` interface.
/// Instances of services in your modules would be built from this common interface.
///
/// An interface like `ServiceContext` provides a convenient point to store such
/// details as:
///
/// * A base URL at which services are mounted.
/// * Authentication mechanisms.
/// * A facility to actually perform a `URLRequest`, getting back a `URLResponse`
/// * Details such as additional headers to be attached on all requests.
/// * An instrumentation or logging interface to which services might report parse
/// errors.
///
/// Modules should be arranged to build their units from the injected `ServiceContext`
/// like interface. See `GreetingModule`. This provides a capability to:
///
/// * Inject a real instance in to modules so real production services are built.
/// * Easily reconfigure shared behaviour of real services (such as their base environment
/// url and their error reporting).
/// * Inject a stubbing instance in to modules so services it builds will all point to
/// stub files for specific scenarios.
///
/// Similarly, in a larger application, many modules might be injected with the same
/// `ServiceContext` like instance. This allows the entire app be run from stubbed
/// files if wished. It makes it easy to adjust global details shared between the Apps
/// services.
///
/// --
///
/// A mock implementation of your `ServiceContext` interface can be used to let
/// service creation functions be unit tests. See `GreetingServiceDefinitionTests`.
///
/// The example `ServiceContext` interface used in this module is simple, but hopefully
/// proves the point!
///
/// Keep in mind that the approach used here is just a guide and other options are
/// entirely possible. For example, `URLRequest` and `URLSession` need not be used,
/// or need not be exposed. Whatever suits building your services, testing them, and
/// letting them be replaces by stubs, is appropriate.
///
public protocol ServiceContext {

    /// Base URL at which services are located.
    var baseURL: URL { get }

    /// Perform a URLRequest and await the result.
    func perform(_ request: URLRequest) async -> URLResult

    // Other features could be provided here such as an authentication mechanism or parse error
    // reporting.
}

// MARK: -

/// Response value provided by `PerformURLRequest`. A `Result` with the
/// `URLSession`'s successful response or an error that it threw.
///
public typealias URLResult = Result<(data: Data, urlResponse: URLResponse), Error>
