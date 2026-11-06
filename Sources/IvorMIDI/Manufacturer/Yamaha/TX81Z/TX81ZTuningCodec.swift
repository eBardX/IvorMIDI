// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

/// A tuning codec for the Yamaha TX81Z, which ignores universal system exclusive
/// messages.
///
/// The instrument has one editable table of each kind, ``MIDITuningSlot/tx81zFullKeyboard``
/// and ``MIDITuningSlot/tx81zOctave``, and stores no name. Its octave pitches are
/// absolute, with equal temperament at notes 60–71.
///
/// To hear a tuning, Exclusive must be on, Memory Protect must be off for dumps,
/// Micro Tune must be on for each instrument, and the tuning only applies in a
/// Performance.
///
/// Real dumps verify the full keyboard dump. Everything else was read from the
/// V1.6 firmware, and no message has been tested on an instrument by this
/// package. See <doc:TX81ZMicroTuning>.
public struct TX81ZTuningCodec {

    // MARK: Public Initializers

    /// Creates a `TX81ZTuningCodec` instance.
    public init() {
    }
}

// MARK: -

extension TX81ZTuningCodec {

    // MARK: Public Instance Methods

    /// Returns the Performance parameter message that turns Micro Tune on or off
    /// for an instrument, or `nil` if the instrument is not 1–8.
    ///
    /// This changes the Performance edit buffer. It was read from the V1.6
    /// firmware, and isn’t verified by real dumps.
    ///
    /// - Parameter instrument: The instrument (1–8).
    /// - Parameter isEnabled:  Whether to turn Micro Tune on.
    /// - Parameter channel:    The channel, which must match the instrument’s
    ///                         Basic Receive channel unless that is set to Omni.
    ///
    /// - Returns:  The parameter message, or `nil`.
    public func microTuneEnableMessage(instrument: MIDIData1Value,
                                       isEnabled: Bool,
                                       channel: MIDIChannel) -> MIDISystemMessage? {
        TX81ZTuningMessage(content: .microTuneEnable(instrument: instrument,
                                                     isEnabled: isEnabled),
                           channel: channel).systemMessage
    }

    /// Returns the Performance parameter message that sets the key of a preset,
    /// or `nil` if the key is above 11.
    ///
    /// The key applies to presets 2–5 only, the ones where
    /// ``TX81ZTuningPreset/usesKey`` is `true`. For
    /// ``TX81ZTuningPreset/pureMinor``, the key names the relative major, so 0
    /// selects A minor. This changes the Performance edit buffer. It was read
    /// from the V1.6 firmware, and isn’t verified by real dumps.
    ///
    /// - Parameter key:        The key, from C (0) to B (11).
    /// - Parameter channel:    The channel, which must match the instrument’s
    ///                         Basic Receive channel unless that is set to Omni.
    ///
    /// - Returns:  The parameter message, or `nil`.
    public func microTuneKeyMessage(_ key: MIDIData1Value,
                                    channel: MIDIChannel) -> MIDISystemMessage? {
        TX81ZTuningMessage(content: .microTuneKey(key),
                           channel: channel).systemMessage
    }

    /// Returns the Performance parameter message that selects a preset tuning.
    ///
    /// This changes the Performance edit buffer. It was read from the V1.6
    /// firmware, and isn’t verified by real dumps.
    ///
    /// - Parameter preset:     The preset.
    /// - Parameter channel:    The channel, which must match the instrument’s
    ///                         Basic Receive channel unless that is set to Omni.
    ///
    /// - Returns:  The parameter message.
    public func presetMessage(_ preset: TX81ZTuningPreset,
                              channel: MIDIChannel) -> MIDISystemMessage {
        guard let message = TX81ZTuningMessage(content: .microTuneTable(.preset(preset)),
                                               channel: channel).systemMessage
        else { preconditionFailure("A table selection always encodes") }

        return message
    }

    // MARK: Private Type Methods

    private static func _channel(_ address: MIDIDeviceAddress) throws -> MIDIChannel {
        guard case let .channel(channel) = address
        else { throw MIDITuningError.unsupportedAddress(address) }

        return channel
    }

    // Converts a key range of a tuning, reporting how the result differs. A key
    // is reported as clamped only if it moved by more than rounding.
    private static func _convert(_ frequencies: [MIDITuningFrequency],
                                 keys: ClosedRange<Int>) -> (pitches: [TX81ZPitch], adjustments: [MIDITuningOutput.Adjustment]) {
        var clampedKeys: [Int] = []
        var pitches: [TX81ZPitch] = []
        var replacedKeys: [Int] = []
        var maximumError = 0

        for key in keys {
            guard let pitch = TX81ZPitch(clamping: frequencies[key])
            else {
                replacedKeys.append(key)
                pitches.append(_equalTemperedPitch(key))
                continue
            }

            pitches.append(pitch)

            if TX81ZPitch(frequency: frequencies[key]) == nil {
                clampedKeys.append(key)
            } else {
                maximumError = max(maximumError, abs(Int(frequencies[key].uintValue) - Int(pitch.frequency.uintValue)))
            }
        }

        var adjustments: [MIDITuningOutput.Adjustment] = []

        if !replacedKeys.isEmpty {
            adjustments.append(.replacedNoChange(keys: replacedKeys))
        }

        if !clampedKeys.isEmpty {
            adjustments.append(.clamped(keys: clampedKeys))
        }

        if maximumError > 0 {
            adjustments.append(.rounded(maximumCents: Double(maximumError) * 100 / 16_384))
        }

        return (pitches, adjustments)
    }

    private static func _equalTemperedPitch(_ key: Int) -> TX81ZPitch {
        TX81ZPitch(clampingSemitones: Double(key)) ?? .lowest
    }

    // Key k takes entry k % 12, moved by (k / 12 − 5) octaves. The result stops
    // one below MIDITuningFrequency.noChange, which is not a frequency.
    private static func _expand(_ entries: [TX81ZPitch]) -> [MIDITuningFrequency] {
        (0..<128).compactMap { key in
            MIDITuningFrequency(uintValue: UInt(_octaveValue(key, entries).clamped(to: 0...2_097_150)))
        }
    }

    private static func _octaveValue(_ key: Int,
                                     _ entries: [TX81ZPitch]) -> Int {
        Int(entries[key % 12].frequency.uintValue) + (key / 12 - 5) * 12 * 16_384
    }

    // Checks each sounding key, except those with no change, against its entry
    // shifted by whole octaves, allowing 1/64 semitone.
    private static func _repeats(_ frequencies: [MIDITuningFrequency],
                                 _ entries: [TX81ZPitch],
                                 keys: ClosedRange<Int>) -> Bool {
        keys.allSatisfy { key in
            frequencies[key] == .noChange || abs(Int(frequencies[key].uintValue) - _octaveValue(key, entries)) <= 256
        }
    }

    private static func _table(_ slot: MIDITuningSlot) throws -> TX81ZTuningTable {
        guard let table = TX81ZTuningTable(slot: slot)
        else { throw MIDITuningError.unsupportedSlot(slot) }

        return table
    }
}

// MARK: - Hashable

extension TX81ZTuningCodec: Hashable {
}

// MARK: - MIDITuningCodec

extension TX81ZTuningCodec: MIDITuningCodec {

    // MARK: Public Instance Properties

    /// The full keyboard table.
    public var defaultSlot: MIDITuningSlot {
        .tx81zFullKeyboard
    }

    /// The limits of a TX81Z: no name, a resolution of 1.5625 cents, keys 13–108,
    /// and no equivalent of ``MIDITuningFrequency/noChange``.
    public var limits: MIDITuningLimits {
        MIDITuningLimits(maximumNameLength: 0,
                         resolutionInCents: 1.5625,
                         soundingKeys: 13...108,
                         supportsNoChange: false)
    }

    /// All 16 channels, because a request must match the instrument’s Basic
    /// Receive channel unless that is set to Omni.
    public var probeAddresses: [MIDIDeviceAddress] {
        (1...16).map { .channel(MIDIChannel(clamping: $0)) }
    }

    // MARK: Public Instance Methods

    /// Returns the output that installs a tuning in a table: the dump, then the
    /// Performance parameter message that selects that table.
    ///
    /// Each key of ``MIDITuningFrequency/noChange`` becomes its equal-tempered
    /// pitch, and pitches are clamped and rounded to what the instrument can
    /// store, as reported in the output’s adjustments. The instrument stores no
    /// name, so a name is dropped.
    ///
    /// The octave table uses keys 60–71, and the tuning must repeat at the
    /// octave across keys 13–108. Keys of ``MIDITuningFrequency/noChange`` aren’t
    /// checked.
    ///
    /// Real dumps verify the full keyboard dump. The octave dump and the table
    /// selection were read from the V1.6 firmware.
    ///
    /// - Parameter tuning:     The tuning to install.
    /// - Parameter slot:       The table to install it in.
    /// - Parameter address:    The channel, which must match the instrument’s
    ///                         Basic Receive channel unless that is set to Omni.
    ///
    /// - Returns:  The dump and the table selection, in that order.
    ///
    /// - Throws:   A ``MIDITuningError`` if the slot or the address is
    ///             unsupported, or if the tuning doesn’t repeat at the octave.
    public func messages(for tuning: MIDIDeviceTuning,
                         slot: MIDITuningSlot,
                         address: MIDIDeviceAddress) throws -> MIDITuningOutput {
        let channel = try Self._channel(address)
        let table = try Self._table(slot)
        let keys = table == .octave ? 60...71 : 0...127
        var (pitches, adjustments) = Self._convert(tuning.frequencies, keys: keys)

        if table == .octave {
            guard Self._repeats(tuning.frequencies, pitches, keys: limits.soundingKeys)
            else { throw MIDITuningError.nonRepeatingTuning }
        }

        if tuning.name?.isEmpty == false {
            adjustments.append(.droppedName)
        }

        let messages: [TX81ZTuningMessage] = [TX81ZTuningMessage(content: .dump(table, pitches: pitches),
                                                                 channel: channel),
                                              TX81ZTuningMessage(content: .microTuneTable(.table(table)),
                                                                 channel: channel)]

        return MIDITuningOutput(messages: messages.compactMap(\.systemMessage),
                                adjustments: adjustments,
                                prerequisites: [.exclusiveEnabled,
                                                .memoryProtectOff,
                                                .microTuningEnabled,
                                                .performanceMode])
    }

    /// Returns the message that asks an instrument for a table: one dump
    /// request.
    ///
    /// This was read from the V1.6 firmware, and isn’t verified by real dumps.
    /// A request doesn’t change the instrument’s memory, but it touches the
    /// display. The reply goes out on the instrument’s Transmit channel, which
    /// can differ from the request’s channel.
    ///
    /// - Parameter slot:       The table to ask for.
    /// - Parameter address:    The channel, which must match the instrument’s
    ///                         Basic Receive channel unless that is set to Omni.
    ///
    /// - Returns:  The dump request to send.
    ///
    /// - Throws:   A ``MIDITuningError`` if the slot or the address is
    ///             unsupported.
    public func requestMessages(slot: MIDITuningSlot,
                                address: MIDIDeviceAddress) throws -> [MIDISystemMessage] {
        let channel = try Self._channel(address)
        let table = try Self._table(slot)

        return [TX81ZTuningMessage(content: .dumpRequest(table),
                                   channel: channel)].compactMap(\.systemMessage)
    }

    /// Returns no messages, because ``messages(for:slot:address:)`` already
    /// selects the table.
    ///
    /// - Parameter slot:       The table that holds the tuning.
    /// - Parameter channels:   The channels in use, which this codec ignores.
    ///
    /// - Returns:  An empty array.
    ///
    /// - Throws:   A ``MIDITuningError`` if the slot is unsupported.
    public func selectionMessages(slot: MIDITuningSlot,
                                  channels: [MIDIChannel]) throws -> [MIDIChannelMessage] {
        _ = try Self._table(slot)

        return []
    }

    /// Returns the tuning held in a full keyboard or octave dump, with no name.
    ///
    /// An octave dump expands to 128 keys.
    ///
    /// - Parameter message:    The message to decode.
    ///
    /// - Returns:  The tuning, or `nil` if the message is anything else.
    public func tuning(from message: MIDISystemMessage) -> MIDIDeviceTuning? {
        guard case let .dump(table, pitches) = TX81ZTuningMessage(message)?.content
        else { return nil }

        return switch table {
        case .fullKeyboard:
            MIDIDeviceTuning(frequencies: pitches.map(\.frequency))

        case .octave:
            MIDIDeviceTuning(frequencies: Self._expand(pitches))
        }
    }
}

// MARK: - Sendable

extension TX81ZTuningCodec: Sendable {
}
