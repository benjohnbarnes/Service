Thanks for taking a look. Just so you know, Service is currently work in progress. The code seems pretty much there but the documentation is still being worked on.

# What even is this?

Service is an teeny, tiny, hardly worth it library with a generic type `Service<Intput, Output>` that is little more than a wrapper around an `async` function.

Why am I wasting your time with it? 

The quick gist is **Service provides a pattern to help you organise very valuable chunks of your code in a highly reusable and testable way.** That's the sales pitch. I try to justify that in more depth [separately](/README2.md).


# How do I use Service?

There's a `ServiceDemo` folder in the project that uses Service and the patterns you're suggested to follow. I'll give an overview here.

### Define a `Service`

In your module that provides one or more services, define services like this:

```swift
public typealias VehicleTaxService = Service<VehicleNumberPlate, Result<VehicleTaxDetails, Error>>
```

You should model the `Input` and `Output` domains with strong types appropriate to the service. Much of the value of a service is how it can use types to **defines the language clients use to interact with it**.

In this case the service `Output` is a Swift `Result` with a generic `Error`. A service is free to have any `Output` type. If using a `Result` you might want to provide a specific `Error` type better informing call sites about the potential faulure cases they must handle.

### Use a `Service`

Even before `VehicleTaxService` has an implementation, we can **build and test** units that consume it:

```
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

Using `MockService` we can write unit tests of `VehicleTaxModel`. These tests use the domain types `VehicleNumberPlate` and `VehicleTaxDetails`. This keeps them completely decoupled from network details such as response encoding or request headers. The tests are compact, clear, and less likely to need rework if the network details change. The tests can be written without even working out the details of requests and responses.

### Implement a `Service` following the Service creation pattern

The "VehicleTax" team have finished working out the network API and request / response encoding, headers, return codes, and all that stuff. So we can provide an implementation of `VehicleTaxService` now.

A service implementation is provided like this. **You are strongly encouraged to follow this pattern**. Add a `static func` as an `extension` of your `Service` type that builds a service implementation from a passed in `ServiceContext`. 

NB: The details of your `ServiceContext` and how the function works may be completely different. 

```swift
public extension VehicleTaxService {
    static func vehicleService(in context: some ServiceContext) -> Self {
        Service { vehiclePlate in
            let url = context.baseURL
                .appending(path: "taxService")
                .appending(path: vehiclePlate.registration)

            let request = URLRequest(url: url)
            let result = await context.perform(request: request)

            return Result {
                let (data, _) = try result.get()
                let dto = try JSONDecoder().decode(VehicleTaxDetailsDTO.self, from: data)
                return try VehicleTaxDetails(dto)
            }
        }
    }
}
``` 

### What is this `ServiceContext`?

`ServiceContext` is a protocol you will define. It encapsulates the common details your service creation function need. It will be determined by the way your modules perform requests. 

A `ServiceContext` would frequently provide:

* A mechanism to build a full service `URL` from a service path.
* A mechanism to perform a `URLRequest`.

A `ServiceContext` could also include:

* An system to obtain an authentication token for requests.
* A way to report parsing errors in responses from the backend.

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

