import Service

/// A super trivial example feature module which will create its units from the `ServiceProviding` it is
/// given.
///
public struct GreetingModule {

    private let serviceProvider: any ServiceContext

    /// This module needs a `ServiceProviding` to build services from. The implementation could be real,
    /// or something providing services with stub data to return.
    ///
    public init(serviceProvider: ServiceContext) {
        self.serviceProvider = serviceProvider
    }

    /// Build the module's main feature.
    ///
    /// In general we'd be creating far more complex graphs of feature units in a module, but this is a
    /// super trivial example that I think shows this is viable.
    ///
    func greetingFeature() -> GreetingUnit {
        // Build the unit, providing it with a service instance built by the factory.
        GreetingUnit(
            // Build service for the greeting unit from `serviceProvider`. The ergonomics of this are
            // very nice because Xcode can find any methods able to build the service instance.
            greetingService: .greetingService(in: serviceProvider)
        )
    }
}
