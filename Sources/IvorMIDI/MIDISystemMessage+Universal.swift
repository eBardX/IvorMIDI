// © 2026 John Gary Pusey (see LICENSE.md)

// Universal system exclusive messages for device control and tuning. Every
// message is addressed to all devices (device ID 7F).
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
        .systemExclusive([0x7f, 0x7f, 0x04, 0x04, 0x00, _byte(tuning), 0xf7])
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
        .systemExclusive([0x7f, 0x7f, 0x04, 0x03, _byte(tuning.lsb), _byte(tuning.msb), 0xf7])
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
        .systemExclusive([0x7f, 0x7f, 0x04, 0x01, _byte(volume.lsb), _byte(volume.msb), 0xf7])
    }

    /// Returns the universal system exclusive message that retunes each of
    /// the 12 notes of the octave on the provided channels of all devices
    /// (`F0 7E 7F 08 08 ff gg hh ss … F7`, or `F0 7F …` in real time), or
    /// `nil` if there are not exactly 12 offsets.
    ///
    /// This is the one-byte form of scale/octave tuning, which General MIDI
    /// 2 requires in non-real time and recommends in real time. Each message
    /// offsets the tuning from equal temperament, not from earlier messages.
    /// Rhythm channels should ignore it. Send the non-real-time form at the
    /// start of a song or during a break in the sound.
    ///
    /// - Parameter channels:   The channels to retune.
    /// - Parameter offsets:    The offset of each note, from C to B, from
    ///                         −64 cents (0) through equal temperament (64)
    ///                         to +63 cents (127).
    /// - Parameter realTime:   Whether to send the real-time form, which also
    ///                         retunes notes that are already sounding.
    ///                         Defaults to `false`.
    ///
    /// - Returns:  The scale/octave tuning message, or `nil`.
    public static func scaleOctaveTuning(channels: [MIDIChannel],
                                         offsets: [MIDIData1Value],
                                         realTime: Bool = false) -> Self? {
        guard offsets.count == 12
        else { return nil }

        var channelBytes: [UInt8] = [0x00, 0x00, 0x00]    // ff (15–16), gg (8–14), hh (1–7)

        for channel in channels {
            let index = Int(channel.uintValue) - 1

            channelBytes[2 - index / 7] |= 1 << (index % 7)
        }

        return .systemExclusive([realTime ? 0x7f : 0x7e, 0x7f, 0x08, 0x08]
                                + channelBytes
                                + offsets.map { _byte($0) }
                                + [0xf7])
    }

    // MARK: Private Type Methods

    private static func _byte(_ value: MIDIData1Value) -> UInt8 {
        UInt8(truncatingIfNeeded: value.uintValue)
    }
}
