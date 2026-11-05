// © 2026 John Gary Pusey (see LICENSE.md)

/// The location of a stored tuning: a tuning program and, optionally, the
/// tuning bank it is in.
///
/// The *MIDI Tuning Messages* specification defines the original messages
/// without a bank, and adds a form of each with a bank in its Bank/Dump
/// Extensions (CA-020). A `nil` bank selects the original form.
public struct MIDITuningLocation {

    // MARK: Public Initializers

    /// Creates a `MIDITuningLocation` instance with the provided program and
    /// bank.
    ///
    /// - Parameter program:    The tuning program number (0–127).
    /// - Parameter bank:       The tuning bank number (0–127), or `nil` if
    ///                         the location has no bank.
    public init(program: MIDIData1Value,
                bank: MIDIData1Value? = nil) {
        self.bank = bank
        self.program = program
    }

    // MARK: Public Instance Properties

    /// The tuning bank number (0–127), or `nil` if the location has no bank.
    public let bank: MIDIData1Value?

    /// The tuning program number (0–127).
    public let program: MIDIData1Value
}

// MARK: - Codable

extension MIDITuningLocation: Codable {
}

// MARK: - Hashable

extension MIDITuningLocation: Hashable {
}

// MARK: - Sendable

extension MIDITuningLocation: Sendable {
}
