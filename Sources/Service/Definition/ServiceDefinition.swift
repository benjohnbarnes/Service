/// `ServiceDefinition` is a common protocol for service definitions which constrains their input and out
/// types.
///
/// * `ServiceDefinition` does not constrain the mechanism by a service is implemented (it is likely
/// to be an HTTP mechanism, but we don't know that yet).
/// * `ServiceDefinition` does not constrain the mechanism by which a service is consumed by a client.
/// An obvious choice would be as an async function, but a callback or a Combine future, or some other
/// approach is possible.
///
/// # Error Handling.
///
/// To support errors, an Output type can: include an error case; track optional error information; be
/// a `Result` type; use some App standardised `Result` type with a typed `Error` case; always be
/// successful in some form and never return an error, etc. All of these approaches are potentially
/// useful and an app may well utilise services that take several of these approaches.
///
/// Other options considered were to allow an `Error` type to be defined (which could be assigned `Never`),
/// and to just allow service implementations to `throw`. However, none of these allow as much control,
/// and the simple approach here doesn't prevent an implementation from having a `throws` interface if
/// beneficial.
///
public protocol ServiceDefinition {
    /// The domain type this service consumes.
    associatedtype Input

    /// The domain type this service produces.
    associatedtype Output
}
