
/// An concrete interface to consume a service.
///
/// `Service` wraps an async function. It takes a strong domain type `Input` and returns a
/// strong domain type `Output`.
///
/// `Service` supports a number of calling styles (async function, completion block),
/// and more can be added either in the library, or by clients as necessary (such as a combine
/// publisher or Promise).
///
/// To specify a concrete service type, use a type alias:
///
/// ```
/// typealias GetAwayService = Service<Set<LootBag>, Result<[ChaseEvents], FilmingError>>
/// ```
///
/// To implement a concrete service, the convention is to provide a static function to build it
/// from `URLServiceProviding`:
///
/// ```
/// extension GetAwayService {
///     static func getAwayService(_ provider: URLServiceProviding<CommonURLContext>) -> Self { … }
/// ```
///
/// To depend on a concrete service add a property for it in a unit and let it be injected:
///
/// ```
/// struct HeistUnit {
///     let getAwayService: GetAwayService
///     let shootOutService: ShootOutService
///
///     init(getAwayService: GetawayService, shootOutService: ShootOutService) {
///         self.getAwayService = getAwayService
///         self.shootOutService = shootOutService
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

    /// Build a service by providing an async function that implements it.
    ///
    /// - Parameter implementation: The function implementing the service.
    ///
    /// See `URLServiceProvider<Context>` for the preferred way to create services.
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
