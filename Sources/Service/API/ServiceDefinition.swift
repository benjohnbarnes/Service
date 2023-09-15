/// Types that represent services by describing their `Input` and `Output` domain types.
///
public protocol ServiceDefinition {

    /// The domain type this service consumes.
    associatedtype Input

    /// The domain type this service produces.
    associatedtype Output

    /// A function implementing this service.
    typealias Implementation = (Input) async -> Output
}

