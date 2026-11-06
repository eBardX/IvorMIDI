// © 2026 John Gary Pusey (see LICENSE.md)

/// An error from a ``MIDITuningCodec``.
public enum MIDITuningError {

    /// A tuning that doesn’t repeat at the octave, for a slot that holds one
    /// octave.
    case nonRepeatingTuning

    /// An address of a kind that can’t reach the device.
    case unsupportedAddress(MIDIDeviceAddress)

    /// A slot of a kind that the device doesn’t have.
    case unsupportedSlot(MIDITuningSlot)
}

// MARK: - Error

extension MIDITuningError: Error {
}

// MARK: - Hashable

extension MIDITuningError: Hashable {
}

// MARK: - Sendable

extension MIDITuningError: Sendable {
}
