import Foundation

public extension Service {
    typealias Mock = MockService<Input, Output>
}

// MARK: -

/// ``MockAsyncService`` provides a test double for testing units depending on an ``AsyncService``.
///
/// `Definition` need only be a `ServiceDefinition`, so `MockAsyncService` can be created to test
/// units before the `Definition` has an implementation approach.
///
public final class MockService<Input, Output> {

    /// Capture the input the unit was called with.
    ///
    public var spyInput: Input?

    /// The result the service will provide.
    ///
    public var stubOutput: Output

    /// Called after each service invocation, but before service completion. Use this to
    /// assert subject state **during** their service calls. Eg – that a subject is in the
    /// loading state during a service call.
    ///
    public var validationHook: (() async -> Void)?

    public init(stubOutput: Output) {
        self.stubOutput = stubOutput
    }

    public func fetch(input: Input) async -> Output {
        self.spyInput = input
        await self.validationHook?()
        return self.stubOutput
    }

    public var service: Service<Input, Output> { Service(fetch(input:)) }
}
