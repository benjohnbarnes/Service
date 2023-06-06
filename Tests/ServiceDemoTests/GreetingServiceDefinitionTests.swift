
import XCTest
import Service
import ServiceDemo

final class GreetingServiceDefinitionTests: XCTestCase {

    let mockServer = MockURLRequestServer()

    func test_requestHasCorrectURL() async throws {
        let service = GreetingServiceDefinition.createService(inContext: Void(), usingServer: mockServer)
        _ = await service("hello")
        XCTAssertEqual(mockServer.spyRequest?.url, URL(string: "hello"))
    }
}

