/// An example unit making use of ``GreetingServiceDefinition``. It chooses to make use of it by having an
/// ``AsyncService`` dependency.
///
/// Because ``AsyncService`` can be created with stubs / mocks or real endpoints, it makes the unit
/// testable.
///
/// It's interesting that units only require service definitions conform to ``ServiceDefinition`` and
/// to begin prototyping a service an actual implementation approach such as HTTP is not necessary, let alone
/// the details of any implementation.
///
final class GreetingUnit: ObservableObject {

    let greetingService: any AsyncService<GreetingServiceDefinition>
    @Published var isLoading: Bool = false

    internal init(greetingService: any AsyncService<GreetingServiceDefinition>) {
        self.greetingService = greetingService
    }

    func getGreeting(person: String) async throws -> String {
        isLoading = true
        defer { isLoading = false }

        return try await greetingService(person).get()
    }
}

