import Service

/// A super trivial example feature module which will create its units from the `ServiceContext` it is
/// given.
///
public struct GreetingModule {

    private let serviceContext: any ServiceContext

    /// This module needs a `ServiceContext` to build services from. The implementation could be real,
    /// or something providing services with stub data to return.
    ///
    public init(serviceContext: ServiceContext) {
        self.serviceContext = serviceContext
    }

    /// Build the module's main feature.
    ///
    /// In general we'd be creating far more complex graphs of feature units in a module, but this is a
    /// super trivial example that I think shows this is viable.
    ///
    func greetingFeature() -> GreetingUnit {
        // Build the unit, providing it with a service instance built by the factory.
        GreetingUnit(
            // Build service for the greeting unit from `serviceContext`. The ergonomics of this are
            // nice because Xcode will suggest autocomplete factory methods in the required service's
            // nominal type.
            //
            greetingService: .greetingService(in: serviceContext)
        )
    }
}
