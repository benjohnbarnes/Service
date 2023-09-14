# Service

Service is a Swift package providing abstractions and implementations helpful for implementing and reusing
URL services in a uniform way.

# Rational

Why make URL services reusable?

1. Implementations of URL Services often represent a significant degree of design, alignment, 
implementation, testing and validation effort.
2. Services also provide an opportunity to encourage shared domain models increasing the chance
of interoperability among units that work with those models.

Finally, how feature units use their services is typically an excellent point for unit testing 
them, and it can be very helpful to run an integrated system against mocked services. 

# What is meant by a `Service` in this library?

Service abstracts individual services as _boxes that take a strongly typed `Input` domain model and
return a strongly typed `Output` domain model._ 

For this reason, an individual service can represent considerable design and development work:

* The input and output domain models of a service should be carefully designed to guide systems using
a service.
* A service's implementation must correctly map from its input domain model to a request against an
API. 
* A service implementation must correctly map from an API's response scheme, error codes, response 
headers, etc, to a domain response type (including describing any error in the output domain).
* The implementation of the mappings should be well tested.
* Designing the domain types and the API the service often requires alignment between different
engineers or teams, and the service captures this alignment effort.

To the outside world using a service, it probably just looks like an async function call that takes
a domain model and returns a domain model – a very simple interface that can be easily reused. But
a service's types and its implementation contain significant effort, which is beneficial to reuse. 

# Intention

Service is intended to provides standard patterns for:

* Defining services.
* Using services in units.
* Providing collections of services to modules (and applications) for use by their units.
* Making units that use services highly testable.
* Making service implementations highly testable.
* Making modules and applications that use services easily usable with stubs in place of
real services.

# Design Goals

Service follows these design goals to achieve the intents:

* Allow services to be defined which take a domain object as input and produce a domain object as output. The 
protocol `ServiceDefinition` specifies this pattern.
* Allow units which consume services to be tested entirely "in the domain" of service input and output models.
This is satisfied by the protocol `AsyncService` which units can have as a dependency.
* Allow units to be tested before services have an implementation. `MockAsyncService` facilities this.
* Hide implementation details of a service from units that consume them. The `AsyncService` interface
supports this implementation hiding.
* Provide a simple async function as the calling interface of services, and allow other calling interfaces
as wished. This is also provided by `AsyncService`.
* Allow service implementations to be thoroughly unit tested. The simple requirements of `URLServiceDefinition`
allows for such testing by using `MockURLRequesting`.
* Provide a `Context` mechanism so Apps hosting services can provide various additional state to service
implementations such as authorisation, logging, error recovery, end-point path mappings, etc. This is provided
in `URLServiceDefinition` and `URLServiceFactory`.
* Allow modules that use service implementations to be injected with a `URLServiceFactory` for building services
for their units. `URLSessionServiceFactory` will build real services, but a stubbed implementation can be
used to test modules or entire applications independent of the network.

