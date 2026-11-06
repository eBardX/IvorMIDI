// © 2026 John Gary Pusey (see LICENSE.md)

/// A typed system exclusive message that converts to and from a
/// ``MIDISysExEnvelope``.
///
/// A conforming type implements only the two envelope requirements, and gains
/// the ``MIDISystemMessage`` conversions from a protocol extension. A type in
/// another package can conform in the same way.
public protocol MIDISysExRepresentable {

    // MARK: Public Initializers

    /// Creates an instance from an envelope, or `nil` if the envelope does not
    /// hold a valid message of this type.
    ///
    /// - Parameter envelope:   The envelope.
    init?(_ envelope: MIDISysExEnvelope)

    // MARK: Public Instance Properties

    /// The envelope that holds this message, or `nil` if it cannot be encoded.
    var envelope: MIDISysExEnvelope? { get }
}

// MARK: -

extension MIDISysExRepresentable {

    // MARK: Public Initializers

    /// Creates an instance from a system message, or `nil` if it is not a valid
    /// system exclusive message of this type.
    ///
    /// - Parameter message:    The system message.
    public init?(_ message: MIDISystemMessage) {
        guard let envelope = MIDISysExEnvelope(message)
        else { return nil }

        self.init(envelope)
    }

    // MARK: Public Instance Properties

    /// The system message that holds this message, or `nil` if it cannot be
    /// encoded.
    public var systemMessage: MIDISystemMessage? {
        envelope?.systemMessage
    }
}
