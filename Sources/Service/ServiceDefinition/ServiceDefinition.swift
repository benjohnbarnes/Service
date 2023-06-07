/// ``ServiceDefinition`` is a common protocol for service definitions specifying constraining their input
/// and output types.
///
/// It does not constrain the mechanism by a service is implemented (it is likely to be an HTTP mechanism,
/// but we don't know that yet which is a useful property).
///
/// It does not constrain the mechanism by which a service is consumed by a client. An obvious choice would
/// be as an async function, but a callback or a Combine future, or some other approach is possible.
///
public protocol ServiceDefinition {
    /// The domain type this service consumes.
    associatedtype Input

    /// The domain type this service produces.
    associatedtype Output
}
