// MARK: - Building services for modules

/// While it's nice being able to feed units with specific mock services for tests, we'd like to be able to
/// encapsulate modules that create units for their features using a service factory. This lets us instantiate
/// a module either with a mock factory (to test the integrated module with stub services), or with a real
/// factory so it can be constructed to use real end points.
///
public struct URLRequestServiceFactory<Context> {

    let context: Context
    let urlServer: any URLRequestServer

    func makeService<Definition: URLRequestServiceDefinition>() -> Service<Definition> where Definition.Context == Context {
        Service<Definition>(implementation: Definition.createService(inContext: context, usingServer: urlServer))
    }

    struct Service<Definition: URLRequestServiceDefinition>: AsyncService {
        let implementation: Definition.Service

        func callAsFunction(_ input: Definition.Input) async -> Definition.Output {
            await implementation(input)
        }
    }
}

