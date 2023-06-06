/// ``AsyncService`` presents a service definition as a usable service modelled as an async function. A unit
/// wishing to consume `SomeService: ServiceDefinition` would declare a dependency as
/// `let service: AsyncService<SomeService>`.
///
/// ``AsyncService`` decouples consuming units from services' implementations and the service need not even
/// be HTTP based.
///
/// ``AsyncService`` is just one possible protocol for presenting a ``ServiceDefinition``. An alternative
/// approach would be expose an interface that returns a Combine `Future` or offers a callback interface.
///
public protocol AsyncService<Definition> {

    associatedtype Definition: ServiceDefinition
    func callAsFunction(_ input: Definition.Input) async -> Definition.Output
}

