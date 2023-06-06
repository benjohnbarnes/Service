/// ``URLServerServiceDefinition`` extends ``ServiceDefinition`` by requiring it provide an implementation
/// approach. A ``ServiceDefinition`` could use some other approach to providing an implementation, and
/// potentially, a ``ServiceDefinition`` could provide several implementation approaches. But here's one
/// that makes use of ``URLRequest``s.
///
public protocol URLServerServiceDefinition: ServiceDefinition {

    /// Contextual details this service requires so as to construct a ``URLRequest`` or parse its response.
    /// It is expected all service definitions from a module (and related module families) would share a
    /// `Context` type, but that apps might consume service sets or integrated features which use differing
    /// `Context`.
    ///
    /// A primary anticipated use of `Context` is to provide a facility to map a service's Path to an actual
    /// URL in some backend environment. Other uses could be authorisation facilities, and a mechanism for
    /// parsing error instrumentation.
    ///
    associatedtype Context

    /// Create an instance of this service.
    ///
    static func createService(inContext context: Context, usingServer urlServer: URLRequestServer) -> Service
    typealias Service = (Input) async -> Output
}

