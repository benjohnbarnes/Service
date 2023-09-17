
public protocol Servicing<Input, Output> {
    associatedtype Input
    associatedtype Output
    func fetch(input: Input) async -> Output
}

// MARK: -

public extension Servicing {
    /// Nicer call semantics so that `Servicing` types can be used like functions.
    func callAsFunction(_ input: Input) async -> Output {
        await fetch(input: input)
    }

    /// Invoke the Service in completion style.
    ///
    /// - Parameter input: Input value to pass to the service.
    /// - Parameter completion: callback block to be invoked with the service result.
    ///
    func invoke(on input: Input, completion: @escaping(Output) -> Void) {
        Task {
            let result = await self(input)
            completion(result)
        }
    }
}

