# Service – 🛗 pitch

Service helps unlock an extensive code reuse opportunity existing in your projects; maximises the effectiveness of cross team collaboration; simplifies your code base; and improves testability. 

I'll try to justify these tall claims as you read on!

# What does Service provide?

Service is a Swift package providing abstractions and implementations that let URL services be defined in a uniform way to make them easy to reuse, test, and stub.

# So what is a "service"?

This library considers services as being a "opaque box" that takes a strongly typed `Input` argument, performs some impure activity with it, probably involving an external system via HTTPS, and finally returns some typed `Output` argument.

## A motivating example

Here's an example of a search service exposed by a "Catalogue" module for use by its clients.

```
public enum CatalogueServiceDefinition: ServiceDefinition {
	public typealias Input = [ItemQuery]
	public typealias Output = Result<[ItemResult], CatalogueError>
}
```

A unit using Catalogue modules catalogue search might look like this:

```
import Service
import Catalogue

final class CatalogueSearchModel: ObservableObject {
	let catalogueSearch: AsyncService<CatalogueServiceDefinition>
	@Published var state: ModelState = .initial
	
	func search(items: CatalogueItems) async {
		// While the service runs, be in the `.loading` state.
		modelState = .loading
		
		// `catalogueSearch` service is invoked here. Note it is 
		// called with a domain object and we utilise its domain 
		// object response. The interface looks like any other
		// async function. When it completes, transition to the
		// `.loaded` state with the successful or failed `Result`.
		modelState = .loaded(await catalogueService(items))
	}
	
	var isLoading: Bool { state == .loading }
} 
```

The example shows how the external interface of a service is simple and helpfully constrains the design of consuming units by providing the designed domain types for input and output.

In tests of `CatalogueSearchModel` Service provides easily and consistent stubs for the service. We can starts testing `CatalogueSearchModel` as soon as the service's `Input` and `Output` types are defined, even before an implementation is available.

A test might look like this:

```
import Service
import Catalogue

final class CatalogueSearchModelTest: XCTestCase {
	let mockSearchService = MockAsyncService<CatalogueServiceDefinition>(
		stubOutput: .success([])
	)
	
	lazy var subject = CatalogueSearchModel(catalogueSearch: mockSearchService)
	
	func test_serachItems_stateIsLoadingDuringSearch() async {
        mockSearchService.validationHook = { [subject]
        	XCTAssertTrue(subject.isLoading)
        }

        try await subject.search(items: [.testItem])
	}
}
```

Service provides a consistent way to define both the external interfaces of these opaque boxes and also their internal implementation details. This helps you to test units that require services; test service implementation details; and reuse services between modules.

# Rational

Having seen an example service, how does this approach unlock the wild claims made in the elevator pitch?

## Encapsulated Design

A service has `Input` and `Output` domain types. These are the result of client engineers encapsulating their understanding of the service's API in to Swift's type system. 

If the API is a co-designed collaboration between the Swift engineers and API engineers, the service's types and implementation capture this significant alignment and co-design effort. As such, the service definition is a reusable embodiment of this embedded effort. It packages up all that work and effort for rapid integration in other teams with little or no need for new teams to align and fully understand the design process. 

## Encapsulated implementation, tests & validation

A service will generally be implemented by building a `URLRequest` from the `Input` type and dispatching this to an API. It will then parse the API's response (and possible errors) in to the service `Output` type. While these two phases are often not complex, they frequently are many small and subtle facts that must be correctly handled for the API to behave correctly. A `ServiceDefinition` encapsulates this effort and makes it reusable.

The service implementation should be tested, including any subtleties of creating a request or parsing, and good coverage of failure cases should be included. This is an investment that should be shared and reused among modules. Service definitions support this reuse and discourage ad-hoc reimplementations with divergent edge case handling.

All of this is an well exploitable opportunity for code reuse.

## Provision of domain language

The domain types at the edge of a service should be a good model of the service domain. The availability of these types forms the basis of a language for modules consuming the service to communicate. The service definitions begin to establish a domain language for their client modules.

This encourages better collaboration and alignment between teams that use common services.

# Injecting Services

To continue the catalogue example earlier, the "CatalogueUI" module with `CatalogueSearchModel` should include a module instance that can build a view for us. The module could look like this:

```
import Catalogue
import Common
import Service

public struct CatalogueUI {
	let serviceFactory: any URLServiceFactory<CommonServiceContext>

	func catalogueView() -> some View {
		CatalogueView(model: CatalogueSearchModel(
			// Service is injected in to view model here.
			catalogueSearch: serviceFactory.makeService()
		))
	}
}
```

## Shared `Context`

A common service context is introduced by the type `CommonServiceContext`. It is frequently the case that service implementations have additional environmental dependencies they must be given. `CommonServiceContext` is a facility to supply these concerns. Services generically supports any kind of shared `Context` rather than defining a specific type.

Examples of the kinds of facilities `Context` is needed for are:

* Mapping from URL service **paths** to an actual URLs that are requested with an HTTPS request. This lets services be targeted at multiple server environments without any involvement of the modules that use them.
* A transparent authentication mechanism providing tokens to include in service requests. 
* A telemetry interface that response parsing errors should be dispatched to.
* Optional additional headers that client can configure.

The `Context` allow these to be cleanly injected to service definitions without pulling them out of globals, or needing to explicitly these details about.

## Managing multiple environments

The `Context` of the `URLServiceFactory` should provide a mechanism for mapping from service paths to URLs. This is an effective mechanism to redirect a module to alternative environments such as staging and production. Switching between environments is opaque to modules making use of services.

## Stubbing Services

The `URLServiceFactory` dependency of `CatalogueUI` lets any conforming type be injected. As well as a production factory `URLSessionServiceFactory` that uses a `URLService` instance, it is also possible to inject a stub implementation of the factory. 

Giving the module a stub lets all its services be replaced with local stubs. These could read from JSON files, use a local database, or even run ad-hoc code. The approach scales to a whole App so that it can be run entirely against local stubbed services.

It is simple to also vary the stubs used and inject multiple scenarios for app testing.

Any stubbing is opaque to a module making use of services; they are oblivious of whether their services are real or stubbed.