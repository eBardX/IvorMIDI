// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDITuningOutput {

    /// A way in which an installed tuning differs from the one requested.
    public enum Adjustment {

        /// Keys whose frequencies were outside what the device can play, so they
        /// were clamped.
        case clamped(keys: [Int])

        /// A name that was dropped, because the device can’t store it.
        case droppedName

        /// Keys that were ``MIDITuningFrequency/noChange``, which the device has
        /// no equivalent for, so they were replaced.
        case replacedNoChange(keys: [Int])

        /// Frequencies that were rounded to the device’s resolution, by no more
        /// than this many cents.
        case rounded(maximumCents: Double)
    }
}

// MARK: - Hashable

extension MIDITuningOutput.Adjustment: Hashable {
}

// MARK: - Sendable

extension MIDITuningOutput.Adjustment: Sendable {
}
