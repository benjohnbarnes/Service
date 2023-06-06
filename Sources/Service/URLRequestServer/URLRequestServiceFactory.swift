/// While it's nice being able to feed units with specific mock services for tests, we'd like to be able to
/// encapsulate modules that create units for their features using a service factory. This lets us instantiate
/// a module either with a mock factory (to test the integrated module with stub services), or with a real
/// factory so it can be constructed to use real end points.
///
public struct URLRequestServiceFactory<Context> {

    let context: Context
    let urlServer: any URLRequestServer

    public init(context: Context, urlServer: URLRequestServer) {
        self.context = context
        self.urlServer = urlServer
    }

    public func makeService<Definition: URLRequestServiceDefinition>() -> some AsyncService<Definition> where Definition.Context == Context {
        Service<Definition>(implementation: Definition.createService(inContext: context, usingServer: urlServer))
    }

    struct Service<Definition: URLRequestServiceDefinition>: AsyncService {
        let implementation: Definition.ServiceImplementation

        func callAsFunction(_ input: Definition.Input) async -> Definition.Output {
            await implementation(input)
        }
    }
}

