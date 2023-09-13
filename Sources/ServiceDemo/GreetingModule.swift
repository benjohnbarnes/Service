import Service

/// A super trivial example feature module which will create its units from the service factory it is
/// given.
///
public struct GreetingModule {

    let serviceFactory: any URLServiceFactory<GreetingServicesContext>

    /// In general we'd be creating far more complex graphs of feature units in a module, but this is a
    /// super trivial example that I think shows this is viable.
    func greetingFeature() -> GreetingUnit {
        GreetingUnit(
            greetingService: serviceFactory.makeService()
        )
    }
}
