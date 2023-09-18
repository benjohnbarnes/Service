# Service – Promised Benefits

Service helps you introduce a pattern which claims these benefits: 

1. Support significant code reuse.
2. Increase benefits from cross team collaborations / alignment.
3. Improve testability of services (of services and units using services).
4. Reduces costly inconsistencies between systems.
5. Allows easy reconfiguration of systems to use different backend environments or stubs.

I'll try to justify these tall claims as you read on…

# What does Service provide?

Service provides very little! It is a Swift package providing abstractions and implementations to let URL services be defined in a uniform manner such that:

* They are very easy to reuse and share among modules.
* Service implementations can be tested comprehensively, clearly and concisely.
* Units consuming services can be tested comprehensively, clearly and concisely.
* Systems using services can replace them, at a single high level point, to target different backend environments, entirely stub them, or satisfy other scenarios.
* Service use and implementation has nice Swift ergonomics.

Nothing Service provides is clever or involved. However, Service's design has gone through many iterations to find an approach most likely to achieve the design goals of shared services with strong testability & good ergonomics.

# So what is a "service"?

This library considers a service to be an "opaque box" that takes a strongly typed `Input` argument, performs some impure activity with it that probably involves an external system using HTTPS, and finally returns some typed `Output` argument. Service gives clients flexibility in how they call a service, but provides out of the box an async function and a callback interface. Combine support is simple to add.

The claim is that this kind of box is a "Really Good ™" abstraction and it either directly provides, or enables each of the benefits.

## A motivating example

Here's an example of a search service exposed by a "Catalogue" module for use by its clients.

```
import Service
public typealias CatalogueSearchService = Service<[ItemQuery], Result<[ItemResult], CatalogueError>>
```

A unit using Catalogue module's search might look like this:

```
import Service
import Catalogue

final class CatalogueSearchModel: ObservableObject {
	let catalogueSearch: CatalogueSearchService
	@Published var state: ModelState = .initial
	
	func search(items: CatalogueItems) async {
		// While the service runs, be in the `.loading` state.
		modelState = .loading
		
		// `catalogueSearch` service is invoked here. Note it is 
		// called with a domain object and we utilise its domain 
		// object response. The interface looks like any other
		// async function. When it completes, transition to the
		// `.loaded` state with the successful or failed `Result`.
		modelState = .loaded(await catalogueSearch(items))
	}
	
	var isLoading: Bool { state == .loading }
 
    var viewData: ViewData {
        // Perform mapping from `state` property here.
    }
} 
```

The example shows how the external interface of a service is simple and guides consuming units by using the domain types for input and output.

In tests of `CatalogueSearchModel` Service provides easiy and consistent stubs of `CatalogueSearchService`. We can starts testing `CatalogueSearchModel` as soon as the service's `Input` and `Output` types are defined, before a `CatalogueSearchService` implementation is available.

A test might look like this:

```
import Service
import Catalogue

final class CatalogueSearchModelTest: XCTestCase {
	let mockSearchService = CatalogueSearchService.Mock(stubOutput: .success([]))	
	lazy var subject = CatalogueSearchModel(catalogueSearch: mockSearchService)
	
	func test_serachItems_stateIsLoadingDuringSearch() async {
        mockSearchService.validationHook = { [subject]
        	XCTAssertTrue(subject.isLoading)
        }

        try await subject.search(items: [.testItem])
	}
}
```

Service provides a consistent way to define both the external interfaces of these opaque "Service" boxes, as well as their internal implementation details. This helps test units that require services; test service implementation details; and reuse services between modules.

# Rational

Having seen an example service, how does this approach unlock the wild claimed benefits?

## Encapsulated design

A service type has `Input` and `Output` domain types. These are the result of client engineers encapsulating their understanding of the service's API in to Swift's type system. 

If the API is a co-designed collaboration between the Swift engineers and API engineers, the service's types and implementation capture this significant alignment and co-design effort. As such, the service definition is a reusable embodiment of this embedded effort. It packages up that work and effort for rapid integration in other teams, with little or no need for new teams to align with the service API, or fully understand the design process.

Encapsulation of design covers claimed benefits 1 & 2. 

## Encapsulated implementation

A service will generally be implemented by building a `URLRequest` from the `Input` type and dispatching this to an API. It will then parse the API's response and handle errors, to provide some service `Output` type. While these two phases are often not complex, they frequently have many small and subtle facts that must be correctly handled for the API to behave correctly and consistently. Once again, the exact details of all of this can require considerable discussion and alignment between client and API engineering teams. A `Service` encapsulates this effort and makes it correctly and consistently reusable.

Encapsulation of implementation also covers claimed benefits 1 & 2.

## Encapsulated tests & validation

Service implementations should be tested, including any subtleties of creating a request or parsing. Good coverage of failure cases should also be included. This is an investment that should be shared and reused among modules. The intent of Service is to support easy reuse and discourage ad-hoc reimplementations that leads to **divergent edge case handling and inconsistency**.

Implementations should also be validated to actually behave as expected in an integrated system. To a significant but lesser degree, validation can also be shared by using a Service implementation.

Encapsulated tests & validation covers claimed benefits 3 & 4.

## Free Mocks

The Service library automatically provides each `Service` with a consistent mock implementation for testing the correct behaviour of units. This can be used before Services are even implemented, a backend exists, or mock JSON is available. Units using services are tested in the domain the the service (its Input and Output), and not in the REST domain that includes details such as service JSON encoding. 

Modules that define services can also provide test data for stubbing so that integrating units can ensure they properly handle all cases a service can provide. Again – the test data is in the domain of the service and not at the REST level.

The availability of free mocks and support for standard test data covers claimed benefits 3. 


# Injecting Services

Justifying the final claim that Service makes it easy for an integrating system to reconfigure its services or use stubs needs the motivating example to be extended.

We're going to extend "CatalogueUI" module that includes the `CatalogueSearchModel` to include a `CatalogueModule` instance that can build a view for us:

```
import Common
import Catalogue
import Service

public struct CatalogueModule {
	let serviceProvider: any URLServiceProviding<CommonServiceContext>

	func catalogueView() -> some View {
		CatalogueView(model: CatalogueSearchModel(
			// Service is injected in to view model here.
			catalogueSearch: .catalogueSearch(using: serviceProvider)
		))
	}
}
```

## Shared `Context`

A common service context is introduced by the type `CommonServiceContext`. It is frequently the case that service implementations require additional environmental dependencies. `CommonServiceContext` is a facility to supply these. Services generically supports any kind of shared `Context` rather than defining a specific type.

Examples of the kinds of facilities `Context` is needed for are:

* Mapping from URL service **paths** to an actual URLs that are requested with an HTTPS request. This lets services be targeted at multiple server environments without any involvement of the modules that use them.
* A transparent authentication mechanism providing tokens to include in service requests. 
* A telemetry interface that response parsing errors should be dispatched to.
* Optional additional headers that client can configure.

The `Context` allow these to be cleanly injected to service definitions without pulling them out of globals, or needing to explicitly pass these dependencies about.

## Managing multiple environments

The `Context` of the `URLServiceProvider` should provide a mechanism for mapping from service paths to URLs. This is an effective mechanism to redirect a module to alternative environments such as staging and production. Switching between environments is opaque to modules making use of services.

This provides part of claimed benefit 5.

## Stubbing Services

The `URLServiceProviding` dependency of `CatalogueModule` lets any conforming type be injected. As well as a production factory `URLServiceProvider` that uses a `URLService` instance, it is possible to inject a stub. Giving the module a stub lets all its services be replaced with local stubs. These could read from JSON files, use a local database, or even run ad-hoc code. The approach scales to a whole App so that it can be run entirely against local stubbed services for various usage scenarios.

This provides the other claimed benefits of 5.
