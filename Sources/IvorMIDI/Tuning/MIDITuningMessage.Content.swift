// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDITuningMessage {

    /// The content of a MIDI Tuning message.
    ///
    /// Each case covers the variants of a message in the *MIDI Tuning
    /// Messages* specification, which differ only in having a bank, in their
    /// offset format, or in being real-time.
    public enum Content {

        /// A bulk tuning dump request (sub-ID#2 `00`), or a bulk tuning dump
        /// request (bank) (`03`) if the location has a bank.
        case dumpRequest(MIDITuningLocation)

        /// A bulk tuning dump (sub-ID#2 `01`), or a key-based tuning dump
        /// (`04`) if the location has a bank.
        ///
        /// A tuning name has no trailing spaces. There are 128 frequencies,
        /// one for each key from 0 to 127.
        case keyBasedDump(MIDITuningLocation,
                          name: String,
                          frequencies: [MIDITuningFrequency])

        /// A scale/octave tuning dump, in the 1 byte format (sub-ID#2 `05`)
        /// or the 2 byte format (`06`).
        ///
        /// A tuning name has no trailing spaces. Unlike the other dumps, this
        /// message has no form without a bank.
        case scaleOctaveDump(bank: MIDIData1Value,
                             program: MIDIData1Value,
                             name: String,
                             offsets: MIDITuningOffsets)

        /// A scale/octave tuning message, in the 1-byte form (sub-ID#2 `08`)
        /// or the 2-byte form (`09`), real-time or not.
        case scaleOctaveTuning(channels: [MIDIChannel],
                               offsets: MIDITuningOffsets,
                               realTime: Bool)

        /// A single note tuning change (sub-ID#2 `02`), or a single note
        /// tuning change (bank) (`07`) if the location has a bank.
        ///
        /// The form without a bank is only defined in real time.
        case singleNoteChange(MIDITuningLocation,
                              changes: [MIDITuningChange],
                              realTime: Bool)
    }
}

// MARK: - Hashable

extension MIDITuningMessage.Content: Hashable {
}

// MARK: - Sendable

extension MIDITuningMessage.Content: Sendable {
}
