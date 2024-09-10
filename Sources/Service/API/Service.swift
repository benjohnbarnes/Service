
/// `Service` is basically a "Nominal Type" wrapper for an async function. This is useful
/// because Swift lets a nominal type have an `extension` which can contain a `static` factory
/// function. These have great autocompletion ergonomics and discoverability.
///
/// A `Service` takes a strong domain `Input` and returns a strong domain `Output`. By "Domain",
/// I mean a type that is relevant to a user of a service. The `Input` is what they pass to the
/// service, and the `Output` is what they receive in response.
///
/// `Service` supports a number of calling styles (async function, completion block), and more
/// can be added either in Service, or by clients as necessary (such as a combine publisher or
/// Promise).
///
/// To specify a concrete service type, use a `typealias`:
///
/// ```
/// typealias GetawayService = Service<Set<LootBag>, Result<[ChaseEvents], FilmingError>>
/// ```
///
/// To implement a concrete service, provide a static function to build it from a
/// `ServiceContext`:
///
/// ```
/// public extension GetawayService {
///     static func GetawayService(in context: ServiceContext) -> Self { … }
/// ```
///
/// To depend on a concrete service, add a property for it in a unit and set up `init`
/// injection:
///
/// ```
/// struct HeistModel {
///     let getawayService: GetawayService
///     let shootOutService: ShootOutService
///
///     init(
///         getawayService: GetawayService,
///         shootOutService: ShootOutService
///     ) {
///         self.getawayService = getawayService
///         self.shootOutService = shootOutService
///     }
/// }
/// ```
///
/// To provide a unit a concrete service, get yourself injected with the the `ServiceContext`
/// and build the unit's service from that:
///
/// ```
/// struct CaperMovieModule {
///     let serviceContext: ServiceContext
///
///     func heistScene() -> some Scene {
///         let heistModel = HeistModel(
///             getawayService: .getawayService(in: serviceContext),
///             shootOutService: .shootOutService(in: serviceContext)
///         )
///
///         return HeistScene(model: heistModel)
///     }
/// }
/// ```
///
public struct Service<Input, Output> {

    let implementation: (Input) async -> Output

    /// Retrieve a response from the service.
    ///
    /// - Parameter input: The input to send the service.
    public func fetch(input: Input) async -> Output {
        await implementation(input)
    }

    /// For services that return a `Result` type, call throwing instead.
    public func tryFetch<Success, Failure>(input: Input) async throws -> Success where Output == Result<Success, Failure> {
        try await fetch(input: input).get()
    }
}

// MARK: -

extension Service {

    /// Build a service by providing an `async` implementation.
    ///
    /// - Parameter implementation: The function implementing the service.
    ///
    public init(_ implementation: @escaping (Input) async -> Output) {
        self.implementation = implementation
    }
}

// MARK: -

public extension Service {

    /// Call the service as an async function
    ///
    /// - Parameter input: Input value to pass to the service.
    ///
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
