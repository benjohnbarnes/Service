Thanks for taking a look. So you know, Service is currently work in progress. The code seems pretty much there but the documentation is being worked on.

# What even is this?

Service is an teeny, tiny, hardly worth it library with a generic type `Service<Intput, Output>` that is really just a "Named Type" wrapper around an `async` function.

Why am I wasting your time with it?! 

The quick gist is **Service provides a pattern to help you organise very valuable chunks of your code in a highly reusable and testable way.** That's the sales pitch. I try to justify that in more depth [separately](/README2.md).


# How do I use Service?

There's a `ServiceDemo` folder in the project that uses Service and the patterns you're suggested to follow. I'll give an overview here.

### Define a `Service`

In modules providing services, define them like this:

```swift
public typealias VehicleTaxService = Service<VehicleNumberPlate, Result<VehicleTaxDetails, Error>>
```

This provides your service with a "Nominal Type". Nominal, or "Named" types, brings beneficial Swift ergonomics such being as able to `extend` the named type with a `static` factory function that will autocomplete. Mmmmm. Nice!

You should model the `Input` and `Output` domains with strong types appropriate to the service. Much of the value of a service is how it can use types to **define the language clients use to interact with it**.

In this example, the service `Output` is a Swift `Result` with a generic `Error`. A service is free to have any `Output` type. For services returning a `Result` consider also having a service specific `Error` type that informs call sites about the precise failure scenarios they must handle.

### Use a `Service`

Even before `VehicleTaxService` has an implementation, we can **implement and test** units that consume it.

```swift
import VehicleTax

final class VehicleTaxModel: ObservableObject {
    let fetchVehicleDetails: VehicleTaxService
    @Observable var modelState: ModelState = .initial

    func load(vehicle: VehicleNumberPlate) async {
        modelState = .loading
        modelState = await .loaded(fetchVehicleDetails(vehicle))
    }
}
```

With `VehicleTaxService.Mock` we can write unit tests of `VehicleTaxModel`. These tests use the domain types `VehicleNumberPlate` and `VehicleTaxDetails`. This keeps them completely decoupled from network details such as response encoding or request headers. The tests are compact, clear, and unlikely to need rework if the network details evolve. The tests can be written before fully knowing the network API details for requests and responses.

### Implement a `Service` following the Service creation pattern

The "VehicleTax" team have finished working out the network API and request / response encoding, headers, return codes, and all that stuff. So we can provide an implementation of `VehicleTaxService` now.

A service implementation is provided like this. **You are strongly encouraged to follow this pattern**. Add a factory function as a `static func` as an `extension` of your `Service`'s named type. The factory function should build the implementation from a passed in `ServiceContext`. 

NB: The details of your `ServiceContext` and how your factory functions work can be very different. This is an example. 

```swift
public extension VehicleTaxService {
    static func vehicleService(in context: some ServiceContext) -> Self {
        Service { vehiclePlate in
            let url = context.baseURL
                .appending(path: "taxService")
                .appending(path: vehiclePlate.registration)

            let request = URLRequest(url: url)
            let result = await context.perform(request)

            return Result {
                let (data, _) = try result.get()
                let dto = try JSONDecoder().decode(VehicleTaxDetailsDTO.self, from: data)
                return try VehicleTaxDetails(dto)
            }
        }
    }
}
``` 


### What is `ServiceContext`?

`ServiceContext` is a protocol you will define. It encapsulates the common details your service creation functions need. Exactly what the protocol provides is determined by the way your modules perform requests.

`ServiceContext` might frequently provide:

* A mechanism to build a complete service `URL` from just a service path (see `context.baseURL.appending(path: "taxService")`).
* A mechanism to perform a `URLRequest` (see `context.perform(request)`).

`ServiceContext` could also provide:

* A system to obtain an authentication token for requests.
* A way to report parsing errors in the backend's responses.

But these possibilities are just suggestions. 

An existing project's services may already have an established shared context. This may already be usable if you want to adopt the Service creation pattern.

You should try to have one, or a small number of `ServiceContext` like interfaces (and their implementations). The intent is that groups of related modules will share this interface. However, there is no harm if some services follow a different approach and need their own `ServiceContext`.

It is important that `ServiceContext` is a protocol and not a fixed type. `.vehicleService` is oblivious to the specific `ServiceContext` implementation it is given. By providing appropriate implementations, we can exercise `vehicleService` (and all other service creation functions) in specific important ways:

* A mock `ServiceContext` lets us exhaustively test the `.vehicleService` implementation without the actual network API existing yet.
* A stubbing `ServiceContext` lets us point all services at potted local response data. This supports easy testing of the integrated system without hitting a real API (or the API existing yet). 
* Finally, once network API environments are available, we can pass in a "real" `ServiceContext` and build real network services pointing at the different environments.


### Integrate `Service`s

To get the greatest benefit from the `ServiceContext` creation pattern it is suggested that you use a "Module" pattern. For some module, define a `Module` type that is injected with the stuff it needs to plumb together the module's' units to provide features.

```swift
import Service
import VehicleTax

struct VehicleModule {
    // A module could have various other dependencies here.
    let serviceContext: ServiceContext

    public func vehicleView(_ vehicle: VehicleNumberPlate) -> VehicleView {
        let vehicleModel = VehicleTaxModel(
            fetchVehicleDetails: .vehicleService(in: serviceContext)
        )

        return VehicleView(model: vehicleModel)
    }
}
```

