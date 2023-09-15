
/// Type wrapping a `ServiceDefinition`'s implementation
///
/// Units call a `ServiceDefinition` as if were a function: `await service(input)`.
///
public struct Service<Definition: ServiceDefinition> {

    /// The input type a service implementation accepts.
    public typealias Input = Definition.Input

    /// The output type a service implementation provides.
    public typealias Output = Definition.Output

    /// An async function type implementing this service.
    public typealias Implementation = Definition.Implementation

    /// Async function implementing this service.
    let implementation: Implementation

    /// Call this service with an input parameter.
    ///
    /// - Parameter input: The input value to pass to the service.
    /// 
    public func callAsFunction(_ input: Input) async -> Output {
        await implementation(input)
    }
}

// MARK: -

extension Service {

    /// Invoke the Service in completion style.
    ///
    /// - Parameter input: Input value to pass to the service.
    /// - Parameter completion: callback block to be invoked with the service result.
    ///
    public func invoke(on input: Input, completion: @escaping(Output) -> Void) {
        Task {
            let result = await self(input)
            completion(result)
        }
    }
}
