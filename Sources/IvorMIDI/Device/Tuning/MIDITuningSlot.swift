// © 2026 John Gary Pusey (see LICENSE.md)

/// Where a device stores a tuning.
///
/// A slot is a call parameter, not part of a tuning, so that a tuning stays
/// portable between devices.
public enum MIDITuningSlot {

    /// A tuning program, in a tuning bank if `bank` isn’t `nil`.
    case program(bank: MIDIData1Value?, MIDIData1Value)

    /// A numbered table. The meaning of the number depends on the device, so
    /// each device’s tables have named constants.
    case table(Int)
}

// MARK: - Hashable

extension MIDITuningSlot: Hashable {
}

// MARK: - Sendable

extension MIDITuningSlot: Sendable {
}
