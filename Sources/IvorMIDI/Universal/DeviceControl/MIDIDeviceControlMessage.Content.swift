// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDIDeviceControlMessage {

    /// The content of a device control message.
    public enum Content {

        /// The coarse tuning of a device (`F0 7F id 04 04 00 msb F7`), from
        /// −64 semitones (0) through A440 (64, the default) to +63 semitones
        /// (127).
        ///
        /// Master coarse tuning adds to each channel’s coarse tuning. A General
        /// MIDI 2 device supports at least ±12 semitones and should not retune
        /// rhythm channels.
        case masterCoarseTuning(MIDIData1Value)

        /// The fine tuning of a device (`F0 7F id 04 03 lsb msb F7`), from
        /// −100 cents (0) through A440 (8,192, the default) to
        /// +100 × 8,191/8,192 cents (16,383).
        ///
        /// Master fine tuning adds to each channel’s fine tuning. A General
        /// MIDI 2 device should not retune rhythm channels.
        case masterFineTuning(MIDIData2Value)

        /// The overall volume of a device (`F0 7F id 04 01 lsb msb F7`), from
        /// off (0) to full (16,383, the default).
        ///
        /// As with channel volume, the square of the value is proportional to
        /// the volume.
        case masterVolume(MIDIData2Value)
    }
}

// MARK: - Hashable

extension MIDIDeviceControlMessage.Content: Hashable {
}

// MARK: - Sendable

extension MIDIDeviceControlMessage.Content: Sendable {
}
