/// `URLServiceFactory` is to be provided to a feature module to let it build service instances
/// for its units.
///
/// `URLServiceFactory` constructs service instances that conform to the `AsyncService` interface.
/// It does this for any `URLServiceDefinition` that matches its `Context`.
///
/// `URLServiceFactory` is an abstract interface. A module can be injected with a production
/// instance which will dispatch service calls to a `URLSessions`. However, a module can also
/// be injected with a factory that will build stubbed services which enables integration testing
/// of the module under various service response scenarios.
///
public protocol URLServiceFactory<Context> {
    associatedtype Context
    func makeService<Definition: URLServiceDefinition>() -> any AsyncService<Definition> where Definition.Context == Context
}
