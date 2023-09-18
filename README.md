# Service – the Claimed Benefits [CBs!]

Service helps you introduce a pattern which claims these benefits: 

1. Support significant code reuse.
2. Increase benefits from cross team collaborations / alignment.
3. Improve testability of service implementations.
4. Improve testability of service consumers.
5. Avoid costly inconsistencies between systems.
6. Allow easy reconfiguration of systems to use different backend environments or stubs.

I'll try to justify these tall claims as you read on…

# What does Service provide?

Service provides very little! 

It is a Swift package providing abstractions and implementations to let URL services be defined in a uniform manner such that:

* They are very easy to reuse and share among modules.
* Service implementations can be tested comprehensively, clearly and concisely.
* Units consuming services can be tested comprehensively, clearly and concisely.
* Systems using services can replace them, at a single high level point, to target different backend environments, entirely stub them, or satisfy other scenarios.
* Service use and implementation has nice Swift ergonomics.

Nothing Service provides is clever or involved. However, Service's design has gone through quite a lot of iterations to find an approach most likely to achieve the design goals of shared services with strong testability & good ergonomics.

# So what is a "service"?

This library considers a service to be an "opaque box" that takes a strongly typed `Input` argument, performs some impure activity with it (probably involving an external system over HTTPS), and finally returns some typed `Output` argument. Service gives clients flexibility in how they call a service, but out of the box provides an async function and a callback interface. Combine support is simple to add.

**The fundamental claim is that this kind of box is a _"Really Good ™"_ abstraction and either directly provides or enables each of the CBs.**

There are three important view points of a `Service` box.

## Client POV of a `Service`

Clients view a `Service` as just a function they have been given. You give it some kind of `Input` and later, it gives you some kind of `Output`. All you care about are its two domain types: `Input` and `Output`. These are both as isolated from implementation details as is appropriate for the service in question. 

Because a `Service` is, externally, **just a function**, client behaviour can be unit tested merely by checking they call services with the correct `Input` and take appropriate action for any given `Output`. The implementation and the testing are oblivious of all network level concerns. 

## Implementation POV of a `Service`

Service implementations know about backend details such as whether HTTP and REST are even being used. Assuming they are:

* The implementation knows how to **prepare a request**. It knows necessary headers, URL query parameters, HTTP verbs, authorisation mechanisms, and any data payload to send. The implementation knows how to prepare this request based on the `Input` type, along with any other shared `Context` that is necessary. 
* The implementation also knows how to **parse a response**. It knows about response headers to check, the meaning of the return code, how to parse a payload, how to report errors it encounters and perhaps recover from them.

The implementation is all about taking the `Service`'s `Input` domain, doing sensible stuff with a network, then taking the network's response, and turning that back in to some kind of `Output`.

`Service` implementations live in the network layer and act as a conduit from their `Input` to their `Output` via the network.

We can fully test service implementations by ensuring:
* Given an `Input` they ask the network the right question.
* Given a network response, they produce the appropriate `Output`

## Integrator POV of a `Service`

An integrator wants to instantiate units that expect various `Service` types. It doesn't care what a `Service` does or how it works. It just needs a way to get services and to inject where they are required. An Integrator is happy if, given some sort of generic facility, they can ergonomically obtain instances of services for their units. They'd like to be able to have high level control of that facility so that all services can be pointed at a different backend environment, or entirely replaced with stubbed out scenarios that read from files.

## A motivating example

Here's an example of a search service exposed by a "Catalogue" module for use by its clients.

```swift
import Service
public typealias CatalogueSearchService = 
    Service<[ItemQuery], Result<[ItemResult], CatalogueError>>
```

> A quick tip – some services don't need any input parameters. You can define them as `Service<Void, InterestingOutput>` 

Note: no implementation is provided (yet) for this service. That's fine because clients don't and can't care about implementation details! Even with no implementation at all, or API to talk to, the service declaration lets us build and test client modules.

A unit using Catalogue module's search might look like this:

```swift
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

The example shows how the external interface of a service is simple and guides consuming units to use the domain `Input` and `Output` types.

In tests of `CatalogueSearchModel` Service provides easy to use and consistent stubs of `CatalogueSearchService`. We can start testing `CatalogueSearchModel` as soon as the service's `Input` and `Output` types are defined, before an implementation is available.

A test might look like this:

```swift
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

# Justifying CBs 1-5

Having seen an example service, how does this approach unlock the wild "claimed benefits" (CBs)?

## Declared type & encapsulated implementation

A service type is declared with `Input` and `Output` domain types. These types are the result of client engineers embedding their understanding of the service's API in to Swift's type system. Reaching this understanding may have needed substantial research and perhaps asking / aligning with the API team.

If an API is a co-designed collaboration between the Swift engineers and API engineers, the service's declaration captures this alignment and co-design effort. As such, **a service declaration is often a reusable embodiment of considerable embedded effort**. It literally packages up engineer time and effort in to a form which can be rapidly integrated by other teams, with much less need for new teams to understand the service's API or the design decisions informing it.

A service will generally be implemented by building a `URLRequest` from the `Input` type and dispatching this to an API. It will then parse the API's response and handle errors, and provide some service `Output` type. While these two phases are often not complex, they frequently have many small and subtle facts that must be properly handled for the API to behave correctly and consistently. Once again, the exact details of all of this can require considerable discussion and alignment between client and API engineering teams, and also substantial engineer time. **A service implementation encapsulates this effort and makes correctness reusable, providing consistency.**

The service type declaration and its implementation provides CBs 1, 2 & 5.

## Encapsulated tests & validation

Service implementations should be tested, including any subtleties of creating a request or parsing. Good coverage of failure cases should be included. Understanding edge cases is often a result of significant engineering work and might additionally require careful alignment between client and API teams. This is an investment that should be shared and reused among modules. Service inherently supports reuse of tests because when a `Service` is encapsulated, so are its tests.

Encapsulated tests provides CBs 3 & 5.

## Free Mocks

The Service library automatically provides each `Service` with a consistent mock implementation for testing the correct behaviour of units. The mock can be used before a `Service` has an implementation, a backend exists, or mock JSON is available. Units using a `Service` are tested in the domain the the `Service` (its `Input` and `Output`), and not in the REST domain that includes details such as service JSON encoding and HTTP niceties.

Modules that define services can also provide test domain data for stubbing so that integrating units can ensure they properly handle all cases a service can provide. Test data is in the domain of the service and not at the REST level.

The availability of free mocks supporting standard test data covers CBs 4 & 5.

## Avoidance of inconsistency

When service implementations are needed in several places and can't be reused, they are instead reimplemented.

Reimplementation leads to a very high likely-hood of **inconsistencies such as divergent edge case handling**.

Inconsistency has pernicious, ongoing and often enormously expensive consequences. It can impact everyone developing and using a system. Consider how many meetings are about trying to resolve differing live approaches and how difficult these can be to harmonise.

Making services easily reusable provides CB 5.


# Injecting Services

Justifying CB 6, that Service makes it easy for an integrating system to reconfigure services or use stubs, needs the motivating example to be extended.

We'll extend the "CatalogueUI" module which is the home of `CatalogueSearchModel` to include a `CatalogueModule` instance which can build a view for us:

```swift
import Common
import Catalogue
import Service

public struct CatalogueModule {
	let serviceProvider: any URLServiceProviding<CommonServiceContext>

	func catalogueView() -> some View {
		CatalogueView(model: CatalogueSearchModel(
			// The service is created and injected in to the unit here:
			catalogueSearch: .catalogueSearch(using: serviceProvider)
		))
	}
}
```

## Shared `Context`

A common service context is introduced by the client type `CommonServiceContext`. It is frequently the case that service implementations require additional environmental dependencies. `CommonServiceContext` holds these. Services supports a generic shared `Context` type, rather than defining a specific one.

Examples of the kinds of facilities `Context` is needed for are:

* Mapping from URL service **paths** to an actual URLs that are requested with an HTTPS request. This lets services be targeted at multiple server environments without any involvement of the modules that use them.
* A transparent authentication mechanism providing tokens to include in service requests. 
* A telemetry interface that response parsing errors should be dispatched to.
* Optional additional headers that client can configure.

The `Context` lets these to be cleanly injected in to service definitions without looking for thiem in globals, or needing to explicitly pass these dependencies about.

## Managing multiple environments

The `Context` of the `URLServiceProvider` should provide a mechanism for mapping from service paths to URLs. This is an effective mechanism to redirect a module to alternative environments such as staging and production. Switching between environments is opaque to modules making use of services.

This provides part of claimed benefit 6.

## Stubbing Services

The `URLServiceProviding` dependency of `CatalogueModule` lets any conforming type be injected. As well as a production factory `URLServiceProvider` that uses a `URLService` instance, it is possible to inject a stub. Giving the module a stub lets all its services be replaced with local stubs. These could read from JSON files, use a local database, or even run ad-hoc code. The approach scales to a whole App so that it can be run entirely against local stubbed services for various usage scenarios.

This provides the rest of CB 6.
