// © 2026 John Gary Pusey (see LICENSE.md)

// Universal system exclusive messages for device control, including master
// tuning. Every message is addressed to all devices (device ID 7F). The MIDI
// Tuning Standard messages are in MIDISystemMessage+Tuning.swift.
extension MIDISystemMessage {

    // MARK: Public Type Methods

    /// Returns the universal real-time system exclusive message that sets the
    /// coarse tuning of all devices (`F0 7F 7F 04 04 00 msb F7`).
    ///
    /// Master coarse tuning adds to each channel’s coarse tuning. A General
    /// MIDI 2 device supports at least ±12 semitones and should not retune
    /// rhythm channels.
    ///
    /// - Parameter tuning: The tuning, from −64 semitones (0) through A440
    ///                     (64, the default) to +63 semitones (127).
    ///
    /// - Returns:  The master coarse tuning message.
    public static func masterCoarseTuning(_ tuning: MIDIData1Value) -> Self {
        .systemExclusive([0x7f, 0x7f, 0x04, 0x04, 0x00, byte(tuning), 0xf7])
    }

    /// Returns the universal real-time system exclusive message that sets the
    /// fine tuning of all devices (`F0 7F 7F 04 03 lsb msb F7`).
    ///
    /// Master fine tuning adds to each channel’s fine tuning. A General MIDI
    /// 2 device should not retune rhythm channels.
    ///
    /// - Parameter tuning: The tuning, from −100 cents (0) through A440
    ///                     (8192, the default) to +100 × 8191/8192 cents
    ///                     (16383).
    ///
    /// - Returns:  The master fine tuning message.
    public static func masterFineTuning(_ tuning: MIDIData2Value) -> Self {
        .systemExclusive([0x7f, 0x7f, 0x04, 0x03, byte(tuning.lsb), byte(tuning.msb), 0xf7])
    }

    /// Returns the universal real-time system exclusive message that sets the
    /// overall volume of all devices (`F0 7F 7F 04 01 lsb msb F7`).
    ///
    /// As with channel volume, the square of the value is proportional to the
    /// volume.
    ///
    /// - Parameter volume: The volume, from off (0) to full (16383, the
    ///                     default).
    ///
    /// - Returns:  The master volume message.
    public static func masterVolume(_ volume: MIDIData2Value) -> Self {
        .systemExclusive([0x7f, 0x7f, 0x04, 0x01, byte(volume.lsb), byte(volume.msb), 0xf7])
    }

    // MARK: Internal Type Methods

    internal static func byte(_ value: MIDIData1Value) -> UInt8 {
        UInt8(truncatingIfNeeded: value.uintValue)
    }
}
