//
//  GreetingUnitTests.swift
//  
//
//  Created by Benjohn on 06/06/2023.
//

import XCTest
import Service
import ServiceDemo

/// A test of ``GreetingUnit``
///
/// In unit tests we want to directly inject mocked instances of individual service in to the unit.
///
/// Please note: so far, how services here will be implemented is not relevant. But nonetheless, we can
/// specify the service, build a unit to consume it, and write tests for the unit itself. All without any
/// knowledge at all of how the service be implemented.
///
final class GreetingUnitTests: XCTestCase {

    let mockService = MockAsyncService<GreetingServiceDefinition>(stubOutput: .success("Hey there!"))
    lazy var subject = GreetingUnit(greetingService: mockService)

    func test_getGreeting_callsServiceWithPerson() async throws {
        _ = try await subject.getGreeting(person: "test-person")
        XCTAssertEqual(mockService.spyInput, "test-person")
    }

    func test_getGreeting_returnsServiceResponse() async throws {
        let result = try await subject.getGreeting(person: "test-person")
        XCTAssertEqual(result, "Hey there!")
    }

    func test_getGreeting_isLoadingDuringCall() async throws {
        XCTAssertFalse(subject.isLoading)

        mockService.validationHook = { XCTAssertTrue(self.subject.isLoading)}
        _ = try await subject.getGreeting(person: "test-person")

        XCTAssertFalse(subject.isLoading)
    }
}

// MARK: - Extend example service with URL implementation

/// Now `GreetingService`` can be extended to implement ``URLServerServiceDefinition``.
///
extension GreetingServiceDefinition: URLServerServiceDefinition {

    public typealias Context = Void

    public static func createService(inContext context: Context, usingServer urlServer: URLRequestServer) -> Service {
        /// Need to flesh this out showing how ``Context`` is useful and show that it is testable.
        var request = URLRequest(url: URL(string: "Hello")!)
        request.url = URL(string: "Hey")!
        fatalError()
    }
}

