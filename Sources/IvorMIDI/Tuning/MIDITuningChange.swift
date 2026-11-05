// © 2026 John Gary Pusey (see LICENSE.md)

/// A retuning of one MIDI key.
///
/// This is one `[kk xx yy zz]` entry of a single note tuning change in the
/// *MIDI Tuning Messages* specification. Use
/// ``MIDISystemMessage/singleNoteTuningChange(_:program:deviceID:)`` or
/// ``MIDISystemMessage/singleNoteTuningChange(_:bank:program:realTime:deviceID:)``
/// to build the message.
public struct MIDITuningChange {

    // MARK: Public Initializers

    /// Creates a `MIDITuningChange` instance with the provided key and
    /// frequency.
    ///
    /// - Parameter key:        The MIDI key number.
    /// - Parameter frequency:  The frequency to tune the key to.
    public init(key: MIDIData1Value,
                frequency: MIDITuningFrequency) {
        self.frequency = frequency
        self.key = key
    }

    // MARK: Public Instance Properties

    /// The frequency to tune the key to.
    public let frequency: MIDITuningFrequency

    /// The MIDI key number.
    public let key: MIDIData1Value
}

// MARK: - Codable

extension MIDITuningChange: Codable {
}

// MARK: - Hashable

extension MIDITuningChange: Hashable {
}

// MARK: - Sendable

extension MIDITuningChange: Sendable {
}
