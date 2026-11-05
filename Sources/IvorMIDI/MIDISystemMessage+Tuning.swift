// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

// The universal system exclusive messages of the MIDI Tuning Standard (sub-ID#1
// 08), as defined in Specifications/MIDI Tuning Messages.pdf, which includes
// the CA-020, CA-021, and RP-020 extensions. Tuning programs and banks are
// selected with the RPNs in MIDIRegisteredParameter. Every message is addressed
// to all devices (device ID 7F) unless the caller provides a device ID.
extension MIDISystemMessage {

    // MARK: Public Type Methods

    /// Returns the universal non-real-time system exclusive message that
    /// carries a tuning program for all 128 keys
    /// (`F0 7E id 08 01 tt <name> [xx yy zz] … cs F7`), or `nil` if the
    /// arguments are not usable.
    ///
    /// This is “Bulk Tuning Dump” in the *MIDI Tuning Messages* specification,
    /// which an instrument sends in reply to a
    /// ``bulkTuningDumpRequest(program:deviceID:)``. Use
    /// ``MIDITuningFrequency/noChange`` for keys an instrument can’t play. The
    /// checksum is the XOR of `7E`, the device ID, `01`, the tuning program
    /// number, and the name and frequency bytes. Manufacturers have calculated
    /// it differently, so the specification lets receivers ignore it.
    ///
    /// - Parameter program:        The tuning program number (0–127).
    /// - Parameter name:           The name of the tuning. Must be ASCII and
    ///                             at most 16 characters; a shorter name is
    ///                             padded with spaces.
    /// - Parameter frequencies:    The frequency of each key, from 0 to 127.
    ///                             Must have exactly 128 elements.
    /// - Parameter deviceID:       The ID of the responding device. Defaults
    ///                             to all devices (127).
    ///
    /// - Returns:  The bulk tuning dump message, or `nil`.
    public static func bulkTuningDump(program: MIDIData1Value,
                                      name: String,
                                      frequencies: [MIDITuningFrequency],
                                      deviceID: MIDIData1Value = 0x7f) -> Self? {
        guard frequencies.count == 128,
              let body = _dumpBody([program], name, frequencies.flatMap(_bytes))
        else { return nil }

        let checksum = tuningChecksum([0x7e, byte(deviceID), 0x01] + body)

        return .systemExclusive([0x7e, byte(deviceID), 0x08, 0x01] + body + [checksum, 0xf7])
    }

    /// Returns the universal non-real-time system exclusive message that asks
    /// a device for a tuning program in a bank (`F0 7E id 08 03 bb tt F7`).
    ///
    /// This is “Bulk Tuning Dump Request (Bank)” in the *MIDI Tuning Messages*
    /// specification. The device replies with a tuning dump of whichever kind
    /// of table it supports:
    /// ``keyBasedTuningDump(bank:program:name:frequencies:deviceID:)`` or
    /// ``scaleOctaveTuningDump(bank:program:name:offsets:deviceID:)``. Decode
    /// the reply with ``MIDITuningMessage``.
    ///
    /// - Parameter bank:       The tuning bank number (0–127).
    /// - Parameter program:    The tuning program number (0–127).
    /// - Parameter deviceID:   The ID of the target device. Defaults to all
    ///                         devices (127).
    ///
    /// - Returns:  The bulk tuning dump request message.
    public static func bulkTuningDumpRequest(bank: MIDIData1Value,
                                             program: MIDIData1Value,
                                             deviceID: MIDIData1Value = 0x7f) -> Self {
        .systemExclusive([0x7e, byte(deviceID), 0x08, 0x03, byte(bank), byte(program), 0xf7])
    }

    /// Returns the universal non-real-time system exclusive message that asks
    /// a device for a tuning program (`F0 7E id 08 00 tt F7`).
    ///
    /// This is “Bulk Tuning Dump Request” in the *MIDI Tuning Messages*
    /// specification. The device replies with a
    /// ``bulkTuningDump(program:name:frequencies:deviceID:)``, which you can
    /// decode with ``MIDITuningMessage``.
    ///
    /// - Parameter program:    The tuning program number (0–127).
    /// - Parameter deviceID:   The ID of the target device. Defaults to all
    ///                         devices (127).
    ///
    /// - Returns:  The bulk tuning dump request message.
    public static func bulkTuningDumpRequest(program: MIDIData1Value,
                                             deviceID: MIDIData1Value = 0x7f) -> Self {
        .systemExclusive([0x7e, byte(deviceID), 0x08, 0x00, byte(program), 0xf7])
    }

    /// Returns the universal non-real-time system exclusive message that
    /// carries a tuning program in a bank for all 128 keys
    /// (`F0 7E id 08 04 bb tt <name> [xx yy zz] … cs F7`), or `nil` if the
    /// arguments are not usable.
    ///
    /// This is “Key-Based Tuning Dump” in the *MIDI Tuning Messages*
    /// specification. It is ``bulkTuningDump(program:name:frequencies:deviceID:)``
    /// with a bank. The checksum is the XOR of every byte after `F0` and
    /// before the checksum, ANDed with `7F`.
    ///
    /// - Parameter bank:           The tuning bank number (0–127).
    /// - Parameter program:        The tuning program number (0–127).
    /// - Parameter name:           The name of the tuning. Must be ASCII and
    ///                             at most 16 characters; a shorter name is
    ///                             padded with spaces.
    /// - Parameter frequencies:    The frequency of each key, from 0 to 127.
    ///                             Must have exactly 128 elements.
    /// - Parameter deviceID:       The ID of the target device. Defaults to
    ///                             all devices (127).
    ///
    /// - Returns:  The key-based tuning dump message, or `nil`.
    public static func keyBasedTuningDump(bank: MIDIData1Value,
                                          program: MIDIData1Value,
                                          name: String,
                                          frequencies: [MIDITuningFrequency],
                                          deviceID: MIDIData1Value = 0x7f) -> Self? {
        guard frequencies.count == 128
        else { return nil }

        return _tuningDump(0x04, deviceID, _dumpBody([bank, program], name, frequencies.flatMap(_bytes)))
    }

    /// Returns the universal system exclusive message that retunes each of
    /// the 12 notes of the octave on the provided channels
    /// (`F0 7E id 08 08 ff gg hh ss … F7` with 1-byte offsets,
    /// `F0 7E id 08 09 ff gg hh ss tt … F7` with 2-byte offsets, or `F0 7F …`
    /// in real time), or `nil` if there are not exactly 12 offsets.
    ///
    /// This is “Scale/Octave Tuning 1-Byte Form” or “Scale/Octave Tuning
    /// 2-Byte Form” in the *MIDI Tuning Messages* specification. General MIDI
    /// 2 requires the 1-byte form in non-real time and recommends it in real
    /// time. Each message offsets the tuning from the selected preset, or
    /// from equal temperament if there is none, and not from earlier messages.
    /// Rhythm channels should ignore it. Send the non-real-time form at the
    /// start of a song or during a break in the sound.
    ///
    /// - Parameter channels:   The channels to retune.
    /// - Parameter offsets:    The offset of each note, from C to B. Must
    ///                         have exactly 12 elements.
    /// - Parameter realTime:   Whether to send the real-time form, which also
    ///                         retunes notes that are already sounding.
    ///                         Defaults to `false`.
    /// - Parameter deviceID:   The ID of the target device. Defaults to all
    ///                         devices (127).
    ///
    /// - Returns:  The scale/octave tuning message, or `nil`.
    public static func scaleOctaveTuning(channels: [MIDIChannel],
                                         offsets: MIDITuningOffsets,
                                         realTime: Bool = false,
                                         deviceID: MIDIData1Value = 0x7f) -> Self? {
        guard let offsetBytes = offsets.bytesValue
        else { return nil }

        return .systemExclusive([realTime ? 0x7f : 0x7e, byte(deviceID), 0x08, offsets.isFine ? 0x09 : 0x08]
                                + _channelBytes(channels)
                                + offsetBytes
                                + [0xf7])
    }

    /// Returns the universal non-real-time system exclusive message that
    /// carries a scale/octave tuning
    /// (`F0 7E id 08 05 bb tt <name> [xx] … cs F7` with 1-byte offsets, or
    /// `F0 7E id 08 06 bb tt <name> [xx yy] … cs F7` with 2-byte offsets), or
    /// `nil` if the arguments are not usable.
    ///
    /// This is “Scale/Octave Tuning Dump, 1 Byte Format” or “Scale/Octave
    /// Tuning Dump, 2 Byte Format” in the *MIDI Tuning Messages*
    /// specification. The checksum is the XOR of every byte after `F0` and
    /// before the checksum, ANDed with `7F`.
    ///
    /// - Parameter bank:       The tuning bank number (0–127).
    /// - Parameter program:    The tuning program number (0–127).
    /// - Parameter name:       The name of the tuning. Must be ASCII and at
    ///                         most 16 characters; a shorter name is padded
    ///                         with spaces.
    /// - Parameter offsets:    The offset of each note, from C to B. Must
    ///                         have exactly 12 elements.
    /// - Parameter deviceID:   The ID of the target device. Defaults to all
    ///                         devices (127).
    ///
    /// - Returns:  The scale/octave tuning dump message, or `nil`.
    public static func scaleOctaveTuningDump(bank: MIDIData1Value,
                                             program: MIDIData1Value,
                                             name: String,
                                             offsets: MIDITuningOffsets,
                                             deviceID: MIDIData1Value = 0x7f) -> Self? {
        guard let offsetBytes = offsets.bytesValue
        else { return nil }

        return _tuningDump(offsets.isFine ? 0x06 : 0x05, deviceID, _dumpBody([bank, program], name, offsetBytes))
    }

    /// Returns the universal system exclusive message that retunes individual
    /// keys of a tuning program in a bank
    /// (`F0 7F id 08 07 bb tt ll [kk xx yy zz] … F7`, or `F0 7E …` in
    /// non-real time), or `nil` if there are not 1–127 changes.
    ///
    /// This is “Single Note Tuning Change (Bank)” in the *MIDI Tuning
    /// Messages* specification. The real-time form retunes notes that are
    /// already sounding, without audible artifacts. The non-real-time form is
    /// a setup message that does not update them, although a Recommended
    /// Practice may define a different response.
    ///
    /// - Parameter changes:    The changes. Must have 1–127 elements.
    /// - Parameter bank:       The tuning bank number (0–127).
    /// - Parameter program:    The tuning program number (0–127).
    /// - Parameter realTime:   Whether to send the real-time form. Defaults
    ///                         to `true`.
    /// - Parameter deviceID:   The ID of the target device. Defaults to all
    ///                         devices (127).
    ///
    /// - Returns:  The single note tuning change message, or `nil`.
    public static func singleNoteTuningChange(_ changes: [MIDITuningChange],
                                              bank: MIDIData1Value,
                                              program: MIDIData1Value,
                                              realTime: Bool = true,
                                              deviceID: MIDIData1Value = 0x7f) -> Self? {
        guard let changeBytes = _changeBytes(changes)
        else { return nil }

        return .systemExclusive([realTime ? 0x7f : 0x7e, byte(deviceID), 0x08, 0x07, byte(bank), byte(program)]
                                + changeBytes
                                + [0xf7])
    }

    /// Returns the universal real-time system exclusive message that retunes
    /// individual keys of a tuning program
    /// (`F0 7F id 08 02 tt ll [kk xx yy zz] … F7`), or `nil` if there are not
    /// 1–127 changes.
    ///
    /// This is “Single Note Tuning Change (Real-Time)” in the *MIDI Tuning
    /// Messages* specification. It takes effect immediately, including on
    /// notes that are already sounding, without audible artifacts, and it can
    /// also change a tuning that is not the active one.
    ///
    /// - Parameter changes:    The changes. Must have 1–127 elements.
    /// - Parameter program:    The tuning program number (0–127).
    /// - Parameter deviceID:   The ID of the target device. Defaults to all
    ///                         devices (127).
    ///
    /// - Returns:  The single note tuning change message, or `nil`.
    public static func singleNoteTuningChange(_ changes: [MIDITuningChange],
                                              program: MIDIData1Value,
                                              deviceID: MIDIData1Value = 0x7f) -> Self? {
        guard let changeBytes = _changeBytes(changes)
        else { return nil }

        return .systemExclusive([0x7f, byte(deviceID), 0x08, 0x02, byte(program)]
                                + changeBytes
                                + [0xf7])
    }

    // MARK: Internal Type Methods

    internal static func tuningChecksum(_ bytes: some Sequence<UInt8>) -> UInt8 {
        bytes.reduce(0, ^) & 0x7f
    }

    // MARK: Private Type Methods

    private static func _bytes(_ frequency: MIDITuningFrequency) -> [UInt8] {
        [byte(frequency.semitone)] + _bytes(frequency.fraction)
    }

    private static func _bytes(_ value: MIDIData2Value) -> [UInt8] {
        [byte(value.msb), byte(value.lsb)]
    }

    private static func _changeBytes(_ changes: [MIDITuningChange]) -> [UInt8]? {
        guard let count = UInt8(exactly: changes.count),
              (1...127).contains(count)
        else { return nil }

        return [count] + changes.flatMap { [byte($0.key)] + _bytes($0.frequency) }
    }

    private static func _channelBytes(_ channels: [MIDIChannel]) -> [UInt8] {
        var channelBytes: [UInt8] = [0x00, 0x00, 0x00]    // ff (15–16), gg (8–14), hh (1–7)

        for channel in channels {
            let index = Int(channel.uintValue) - 1

            channelBytes[2 - index / 7] |= 1 << (index % 7)
        }

        return channelBytes
    }

    private static func _dumpBody(_ location: [MIDIData1Value],
                                  _ name: String,
                                  _ data: [UInt8]) -> [UInt8]? {
        guard let nameBytes = _nameBytes(name)
        else { return nil }

        return location.map { byte($0) } + nameBytes + data
    }

    private static func _nameBytes(_ name: String) -> [UInt8]? {
        let bytes = Array(name.utf8)

        guard bytes.count <= 16,
              bytes.allSatisfy(\.isMIDIDataByte)
        else { return nil }

        return bytes + [UInt8](repeating: 0x20, count: 16 - bytes.count)
    }

    private static func _tuningDump(_ subID: UInt8,
                                    _ deviceID: MIDIData1Value,
                                    _ body: [UInt8]?) -> Self? {
        guard let body
        else { return nil }

        let message = [0x7e, byte(deviceID), 0x08, subID] + body

        return .systemExclusive(message + [tuningChecksum(message), 0xf7])
    }
}
