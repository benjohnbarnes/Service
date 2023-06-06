// MARK: - Example service & consuming unit

/// A trivial example service definition being made publicly available in a module for use by other
/// modules.
///
/// Note that this trivial example does not yet even hint at how it is implemented, and it is agnostic
/// to how a client consumes it.
///
public enum GreetingServiceDefinition: ServiceDefinition {
    public typealias Input = String
    public typealias Output = Result<String, Error>
}

