
/// Type providing an implementation of a `ServiceDefinition`
public struct Service<Definition: ServiceDefinition> {

    public typealias Input = Definition.Input
    public typealias Output = Definition.Output
    public typealias Implementation = Definition.Implementation

    let implementation: Implementation

    public func callAsFunction(_ input: Input) async -> Output {
        await implementation(input)
    }

    public func invoke(on input: Input, completion: @escaping(Output) -> Void) {
        Task {
            let result = await self(input)
            completion(result)
        }
    }
}
