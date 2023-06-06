// MARK: - Testing example unit with `MockAsyncService`

/// ``MockAsyncService`` is a test double of ``AsyncService`` to test units depending on them.
///
public final class MockAsyncService<Definition: ServiceDefinition>: AsyncService {

    /// Capture the input the unit was called with.
    var spyInput: Definition.Input?

    /// Called after service invocation but before service completion. Supports validation of unit
    /// state during service calls. Eg – that they have transitioned in to a loading state.
    var validationHook: (() async -> Void)?

    /// The result the service will provide.
    var stubOutput: Definition.Output

    internal init(stubOutput: Definition.Output) {
        self.stubOutput = stubOutput
    }

    public func callAsFunction(_ input: Definition.Input) async -> Definition.Output {
        spyInput = input
        await validationHook?()
        return stubOutput
    }
}

