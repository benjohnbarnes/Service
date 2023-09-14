# Service

Service is a Swift package providing abstractions helpful for using and implementing URL services.

# Intention

Service is intended to provides standard patterns for:

* Defining services.
* Using services in units.
* Providing services to modules for their units.
* Testing units that use services.
* Testing service implementations.
* Testing modules and applications that consume services with stubs, or providing them real services.

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

