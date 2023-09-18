
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
public struct Service<Input, Output>: Servicing {
    let implementation: (Input) async -> Output

    /// Retrieve a response from the service.
    ///
    /// - Parameter input: The input to send the service.
    public func fetch(input: Input) async -> Output {
        await implementation(input)
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

    /// Create a service from another service of the same type.
    ///
    public init(_ service: Service<Input, Output>) {
        implementation = service.implementation
    }

    /// Create a service wrapping any `Servicing` instance – this is largely to help
    /// support building mock services.
    /// 
    public init<S: Servicing>(_ servicing: S) where S.Input == Input, S.Output == Output {
        implementation = servicing.fetch(input:)
    }
}
