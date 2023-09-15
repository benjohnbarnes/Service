import Foundation

public protocol ServiceBuilder<Context> {

    associatedtype Context

    func buildService<Definition: ServiceDefinition>(
        _ serviceFunction: (Context, any URLRequesting) -> Definition.Implementation
    ) -> Service<Definition>
}

// MARK: -

public protocol URLRequesting {

    func performRequest(_ request: URLRequest) async -> URLResult

    typealias URLResult = Result<(data: Data, urlResponse: URLResponse), Error>
}
