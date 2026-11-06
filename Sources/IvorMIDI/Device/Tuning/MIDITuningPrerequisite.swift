// © 2026 John Gary Pusey (see LICENSE.md)

/// A step that a codec’s messages don’t cover, so that a tuning can be installed
/// and heard.
///
/// A codec lists only the steps it can’t do itself. An app can localize and
/// present them.
public enum MIDITuningPrerequisite {

    /// System exclusive reception, which must be turned on in the device.
    case exclusiveEnabled

    /// Memory protection, which must be turned off in the device.
    case memoryProtectOff

    /// Micro tuning, which must be turned on for each instrument that should
    /// use it.
    case microTuningEnabled

    /// Performance mode, which the device must be in.
    case performanceMode
}

// MARK: - Hashable

extension MIDITuningPrerequisite: Hashable {
}

// MARK: - Sendable

extension MIDITuningPrerequisite: Sendable {
}
