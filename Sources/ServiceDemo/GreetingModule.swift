import Service

/// A super trivial example feature module which will create its units from the service factory it is
/// given.
///
public struct GreetingModule {

    /// This module needs a `URLServiceFactory`. The implementation could be a real factory or
    /// can be a test double providing stubbed out services.
    ///
    let serviceBuilder: any ServiceBuilder<GreetingServicesContext>

    /// In general we'd be creating far more complex graphs of feature units in a module, but this is a
    /// super trivial example that I think shows this is viable.
    ///
    func greetingFeature() -> GreetingUnit {
        // Build the unit, providing it with a service instance built by the factory.
        GreetingUnit(greetingService: .service(using: serviceBuilder))
    }
}
