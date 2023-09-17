import XCTest
import Service

final class MockServiceTests: XCTestCase {

    private let subject = Service<String, Int>.Mock(stubOutput: 10)

    func test_spyInput_givenSubjectUncalled_thenIsNil() async {
        XCTAssertEqual(subject.spyInput, nil)
    }

    func test_spyInput_whenSubjectCalled_thenHoldsInput() async {
        _ = await subject.service("hello")
        XCTAssertEqual(subject.spyInput, "hello")
    }

    func test_stubOutput_givenInitialState_whenSubjectCalled_thenReturnsInitialState() async {
        let returns = await subject.service("hello")
        XCTAssertEqual(returns, 10)
    }

    func test_stubOutput_whenModifiedAndSubjectCalled_thenReturnsModifiedValue() async {
        subject.stubOutput = 1
        let returns = await subject.service("hello")
        XCTAssertEqual(returns, 1)
    }

    func test_validationHook_givenHookDefined_whenSubjectCalled_thenHookInvokedBeforeReturn() async {
        var subjectReturned = false

        let hookInvoked = expectation(description: "Hook Invoked")
        subject.validationHook = {
            XCTAssertFalse(subjectReturned)
            hookInvoked.fulfill()
        }

        _ = await subject.service("hello")
        subjectReturned = true

        await fulfillment(of: [hookInvoked], timeout: 1)
    }
}

