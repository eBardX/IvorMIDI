// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDITuningMessage {

    /// The content of a MIDI Tuning message.
    ///
    /// Each case covers the variants of a message in the *MIDI Tuning
    /// Messages* specification, which differ only in having a bank, in their
    /// offset format, or in being real-time.
    public enum Content {

        /// A request for a tuning program: “Bulk Tuning Dump Request”
        /// (`F0 7E id 08 00 tt F7`), or “Bulk Tuning Dump Request (Bank)”
        /// (`F0 7E id 08 03 bb tt F7`) if the location has a bank.
        ///
        /// A device replies with a tuning dump of whichever kind of table it
        /// supports: ``keyBasedDump(_:name:frequencies:)`` or
        /// ``scaleOctaveDump(bank:program:name:offsets:)``.
        case dumpRequest(MIDITuningLocation)

        /// A tuning program for all 128 keys: “Bulk Tuning Dump”
        /// (`F0 7E id 08 01 tt <name> [xx yy zz] … cs F7`), or “Key-Based
        /// Tuning Dump” (`F0 7E id 08 04 bb tt <name> [xx yy zz] … cs F7`) if
        /// the location has a bank.
        ///
        /// A tuning name must be ASCII and at most 16 characters. It is padded
        /// with spaces when encoded, and has no trailing spaces when decoded.
        /// There must be exactly 128 frequencies, one for each key from 0 to
        /// 127. Use ``MIDITuningFrequency/noChange`` for keys an instrument
        /// can’t play.
        ///
        /// The checksum of a key-based tuning dump is the XOR of every byte
        /// after `F0` and before the checksum, ANDed with `7F`. The checksum of
        /// a bulk tuning dump is the XOR of `7E`, the device ID, `01`, the
        /// tuning program number, and the name and frequency bytes.
        /// Manufacturers have calculated it differently, so the specification
        /// lets receivers ignore it.
        case keyBasedDump(MIDITuningLocation,
                          name: String,
                          frequencies: [MIDITuningFrequency])

        /// A scale/octave tuning in a tuning program: “Scale/Octave Tuning
        /// Dump, 1 Byte Format” (`F0 7E id 08 05 bb tt <name> [xx] … cs F7`)
        /// or “Scale/Octave Tuning Dump, 2 Byte Format”
        /// (`F0 7E id 08 06 bb tt <name> [xx yy] … cs F7`).
        ///
        /// A tuning name must be ASCII and at most 16 characters. It is padded
        /// with spaces when encoded, and has no trailing spaces when decoded.
        /// There must be exactly 12 offsets, one for each note from C to B.
        /// Unlike the other dumps, this message has no form without a bank.
        ///
        /// The checksum is the XOR of every byte after `F0` and before the
        /// checksum, ANDed with `7F`.
        case scaleOctaveDump(bank: MIDIData1Value,
                             program: MIDIData1Value,
                             name: String,
                             offsets: MIDITuningOffsets)

        /// A retuning of each of the 12 notes of the octave on the provided
        /// channels: “Scale/Octave Tuning 1-Byte Form”
        /// (`F0 7E id 08 08 ff gg hh ss … F7`) or “Scale/Octave Tuning 2-Byte
        /// Form” (`F0 7E id 08 09 ff gg hh ss tt … F7`), or `F0 7F …` in real
        /// time, which also retunes notes that are already sounding.
        ///
        /// There must be exactly 12 offsets, one for each note from C to B.
        /// General MIDI 2 requires the 1-byte form in non-real time and
        /// recommends it in real time. Each message offsets the tuning from the
        /// selected preset, or from equal temperament if there is none, and not
        /// from earlier messages. Rhythm channels should ignore it. Send the
        /// non-real-time form at the start of a song or during a break in the
        /// sound.
        case scaleOctaveTuning(channels: [MIDIChannel],
                               offsets: MIDITuningOffsets,
                               realTime: Bool)

        /// A retuning of individual keys of a tuning program: “Single Note
        /// Tuning Change (Real-Time)” (`F0 7F id 08 02 tt ll [kk xx yy zz] …
        /// F7`), or “Single Note Tuning Change (Bank)”
        /// (`F0 7F id 08 07 bb tt ll [kk xx yy zz] … F7`, or `F0 7E …` in
        /// non-real time) if the location has a bank.
        ///
        /// There must be 1–127 changes. The form without a bank is only defined
        /// in real time. A real-time message takes effect immediately,
        /// including on notes that are already sounding, without audible
        /// artifacts, and it can also change a tuning that is not the active
        /// one. The non-real-time form is a setup message that does not update
        /// sounding notes, although a Recommended Practice may define a
        /// different response.
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
