import Foundation

/// ``MockAsyncService`` provides a test double for testing units depending on an ``AsyncService``.
///
/// `Definition` need only be a `ServiceDefinition`, so `MockAsyncService` can be created to test
/// units before the `Definition` has an implementation approach.
///
public final class MockService<Definition: ServiceDefinition> {

    /// Capture the input the unit was called with.
    ///
    public var spyInput: Definition.Input?

    /// Called after after each service invocation, but before service completion. Use this
    /// to assert unit state during their service calls. Eg – that a unit is in the loading
    /// state during a service call.
    ///
    public var validationHook: (() async -> Void)?

    /// The result the service will provide.
    ///
    public var stubOutput: Definition.Output

    public init(stubOutput: Definition.Output) {
        self.stubOutput = stubOutput
    }

    public var service: Service<Definition> {
        Service { input in
            self.spyInput = input
            await self.validationHook?()
            return self.stubOutput
        }
    }
}
