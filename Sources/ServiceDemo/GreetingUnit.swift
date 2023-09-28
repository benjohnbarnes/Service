import Foundation
import Service

/// An example unit making use of ``GreetingService``.
///
public final class GreetingUnit: ObservableObject {

    let greetingService: GreetingService
    @Published public var isLoading: Bool = false

    /// Create unit by passing in a service instance – this can of course me a mock for testing.
    ///
    public init(greetingService: GreetingService) {
        self.greetingService = greetingService
    }

    public func getGreeting(person: String) async throws -> String {
        isLoading = true
        defer { isLoading = false }

        return try await greetingService(person).get()
    }
}

