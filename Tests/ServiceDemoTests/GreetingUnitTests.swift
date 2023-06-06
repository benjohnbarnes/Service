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

