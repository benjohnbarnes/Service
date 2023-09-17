public struct Service<Input, Output>: Servicing {
    let implementation: (Input) async -> Output

    public func fetch(input: Input) async -> Output {
        await implementation(input)
    }
}

// MARK: -

extension Service {
    public init(_ implementation: @escaping (Input) async -> Output) {
        self.implementation = implementation
    }

    public init(_ service: Service<Input, Output>) {
        implementation = service.implementation
    }

    public init<S: Servicing>(_ servicing: S) where S.Input == Input, S.Output == Output {
        implementation = servicing.fetch(input:)
    }
}
