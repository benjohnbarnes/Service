This section needs a lot of work, so I'll probably re-write it yet again – yay.

# Service – the Claimed Benefits [CBs!]

Service has types and suggests patterns which claims these benefits:

1. Support significant code reuse.
2. Increase benefits and reduce need for cross team collaborations / alignment.
3. Improve testability of service implementations.
4. Improve testability of service consumers.
5. Avoid costly inconsistencies between systems.
6. Allow easy reconfiguration of systems to use different backend environments or stubs.

I'll try to justify these tall claims as you read on…

# What does Service provide?

Service provides `Service<Input, Output>`, a "nominal type" wrapper for `async` functions. Modules can expose their services as `typealiases` of `Service`. 

* Service use and implementation has nice Swift ergonomics.
* Services are easy to reuse and share among modules.
* Service implementations can be tested comprehensively, clearly and concisely.
* Units consuming services can be tested comprehensively, clearly and concisely.
* The service interface exposes only things clients care about and hides everything they don't.
* Systems using services can replace them, at a single high level point, to target different backend environments, entirely stub them, or satisfy other scenarios.

The current minimal API provided by Service is the result of intensive design evolution. Rejected earlier and more complex designs can be uncovered in the `git log`.

# So what is a "service"?

This library considers a service to be an "opaque box" that takes a strongly typed `Input` argument, performs some impure activity with it (probably involving an external system over HTTPS), and finally returns some typed `Output` argument. Service gives clients some flexibility in how they call a service, but out of the box provides an async function and a callback interface. Combine support is simple to add.

**The fundamental idea is that this kind of box is a _"Really Good ™"_ abstraction and either directly provides or enables each of the CBs.**

There are three important view points of a `Service` box.

## Client view point of a `Service`

Clients view a `Service` as just a function they have been given. Call it with `Input` and it asynchronously returns `Output`. All clients care about are a service's two domain types: `Input` and `Output`. These are both as isolated from implementation details of the network API as is appropriate for the service in question. 

Because a `Service` is, externally, **just a function**, client behaviour can be unit tested merely by checking they call services  and pass the correct `Input` and then take appropriate action on receiving consequent `Output`. Both the implementation of a unit and its testing **are oblivious of all network level concerns**. 

## Implementation view point of a `Service`

Service implementations know about backend details such as whether HTTP and REST are being used. Assuming they are:

* The implementation knows how to **prepare a request**. It knows necessary headers, URL query parameters, HTTP verbs, authorisation mechanisms, and any data payload to send. The implementation knows how to prepare this request based on the `Input` type, along with any other shared `Context` that is necessary. 
* The implementation also knows how to **parse a response**. It knows about response headers to check, the meaning of the return code, how to parse a payload, how to report errors it encounters and perhaps recover from them.

The implementation is all about taking the `Service`'s `Input` domain, doing sensible stuff with a network, and then taking the network's response and turning that back in to some kind of `Output`.

`Service` implementations are on the shores of the network layer and act as a conduit from `Input` to `Output` via the network.

A service implementation can be fully tested by ensuring:
* Given an `Input` they ask the network the right question.
* Given a network response, they produce the appropriate `Output`.

## Integrator view point of a `Service`

An integrator wants to instantiate units that expect various `Service` types. It doesn't care what a `Service` does or how it works. It just needs a way to get services and to inject where they are required. An Integrator is happy if, given some sort of abstract `NetworkContext`, they can ergonomically obtain instances of services for their units. They'd like to be able to have high level control of the `NetworkContext` so that all services can be pointed at a different backend environment, or entirely replaced with stubbed out scenarios that read from files.


# Justifying CBs 1-5

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
	let serviceContext: any ServiceContext

	func catalogueView() -> some View {
		CatalogueView(model: CatalogueSearchModel(
			// The service is created and injected in to the unit here:
			catalogueSearch: .catalogueSearch(in: serviceContext)
		))
	}
}
```

## `ServiceContext`

A common service context is introduced by the client type `ServiceContext`. It is frequently the case that service implementations require additional environmental dependencies.

Examples of the kinds of facilities `ServiceContext` is needed for are:

* Mapping from URL service **paths** to an actual URLs that are requested with an HTTPS request. This lets services be targeted at multiple server environments without any involvement of the modules that use them.
* A transparent authentication mechanism providing tokens to include in service requests. 
* A telemetry interface that response parsing errors should be dispatched to.
* Optional additional headers that client can configure.

`ServiceContext` lets these to be cleanly injected in to service factory functions without looking for them in globals, or needing to explicitly pass these dependencies about.

## Multiple environments & global service stubbing

`CatalogueModule` lets any `ServiceContext` type be injected. 

The shared `ServiceContext` type should include a mechanism mapping from service paths to URLs. With this, an integrating module can redirect its resources to specific environments, such as staging and production. The environment in use is opaque to modules making use of services. By injecting a `ServiceContext` implementation in to the module it will build "real" endpoints that access the API over the network using a `URLSession`.  

The `ServiceContext` dependency of `CatalogueModule` also lets other conforming types be injected. This lets the integrating application inject a stubbing implementation. The services are built from this they will instead use potted data from local JSON files, use a local database, or even run ad-hoc code. The approach scales to a whole App letting it run entirely against local stubbed services under various usage scenarios.

Building services in modules from an injected `ServiceContext` provides CB 6.


# Anticipated Questions

### What about if I integrate services that expect more than one kind of `ServiceContext`?

In this case your top level composition root should have `ServiceContext` types for each kind of context in use. It is hoped individual groups of modules can agree a single `ServiceContext` type. However, if a module does use services built from different `ServiceContext` types, this can be readily accommodated.

### Are non HTTP(S) service supported?

Yes! There's no particular reason to only build services using `URLSession`. Other service implementations can be supported. They would use some other `ServiceContext` protocol. Service's `static` factory functions would then construct an instance from this new type.

