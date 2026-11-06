// © 2026 John Gary Pusey (see LICENSE.md)

/// What a ``MIDITuningCodec`` produces to install a tuning.
public struct MIDITuningOutput {

    // MARK: Public Initializers

    /// Creates a `MIDITuningOutput` instance with the provided values.
    ///
    /// - Parameter messages:       The messages to send, in the order they must
    ///                             be sent.
    /// - Parameter adjustments:    How the installed tuning differs from the
    ///                             one requested. Defaults to none.
    /// - Parameter prerequisites:  The steps that the messages don’t cover.
    ///                             Defaults to none.
    public init(messages: [MIDISystemMessage],
                adjustments: [Adjustment] = [],
                prerequisites: [MIDITuningPrerequisite] = []) {
        self.adjustments = adjustments
        self.messages = messages
        self.prerequisites = prerequisites
    }

    // MARK: Public Instance Properties

    /// How the installed tuning differs from the one requested.
    public let adjustments: [Adjustment]

    /// The messages to send, in the order they must be sent.
    public let messages: [MIDISystemMessage]

    /// The steps that the messages don’t cover, such as a setting that only the
    /// user can change.
    public let prerequisites: [MIDITuningPrerequisite]
}

// MARK: - Sendable

extension MIDITuningOutput: Sendable {
}
