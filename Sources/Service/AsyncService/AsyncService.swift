/// `AsyncService` presents a `ServiceDefinition` as a usable service modelled by an async function. A unit
/// wishing to consume `SomeService: ServiceDefinition` would declare a dependency as
/// `let service: AsyncService<SomeService>`.
///
/// `AsyncService` decouples consuming units from services' implementations and the service need not even
/// be HTTP based.
///
/// `AsyncService` is just one possible protocol for presenting a `ServiceDefinition`. An alternative
/// approach would be expose an interface that returns a Combine `Future` or offers a callback interface.
///
/// `AsyncService` is better expressed as a protocol and not a struct because a Mock implementation for
/// unit testing is extremely helpful.
///
public protocol AsyncService<Definition> {

    /// The service `Definition` provided by this instance.
    ///
    /// By design `Definition` is not constrained beyond a basic `ServiceDefinition`. This enables
    /// units consuming a service to be built and tested before the service's implementation is
    /// even considered.
    ///
    associatedtype Definition: ServiceDefinition

    /// Invoke the service with `Definition.Input` to asynchronously obtain `Definition.Output`.
    func callAsFunction(_ input: Definition.Input) async -> Definition.Output
}

// MARK: -

extension ServiceDefinition {

    /// An async func providing an implementation of this `ServiceDefinition`.
    ///
    /// Note that this type is provided on all `ServiceDefinition` allowing `MockAsyncService`
    /// to be built for any `ServiceDefinition`, even before it provides some mechanism to obtain
    /// an async implementation.
    public typealias AsyncImplementation = (Input) async -> Output
}
