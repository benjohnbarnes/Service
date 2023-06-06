/// ``MockAsyncService`` provides a test double for testing units depending on an ``AsyncService``.
///
public final class MockAsyncService<Definition: ServiceDefinition>: AsyncService {

    /// Capture the input the unit was called with.
    ///
    public var spyInput: Definition.Input?

    /// Called after service invocation but before service completion. Supports validation of unit
    /// state during service calls. Eg – that they have transitioned in to a loading state.
    ///
    public var validationHook: (() async -> Void)?

    /// The result the service will provide.
    ///
    public var stubOutput: Definition.Output

    public init(stubOutput: Definition.Output) {
        self.stubOutput = stubOutput
    }

    public func callAsFunction(_ input: Definition.Input) async -> Definition.Output {
        spyInput = input
        await validationHook?()
        return stubOutput
    }
}

