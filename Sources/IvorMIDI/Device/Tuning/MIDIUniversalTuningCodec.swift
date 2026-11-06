// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

/// A tuning codec for devices that use the universal MIDI Tuning messages.
///
/// This codec accepts only a ``MIDIDeviceAddress/deviceID(_:)`` address and a
/// ``MIDITuningSlot/program(bank:_:)`` slot. Most tuning messages aren’t
/// acknowledged, so whether a device honors them has to come from a model in
/// the catalog or from the user.
public struct MIDIUniversalTuningCodec {

    // MARK: Public Initializers

    /// Creates a `MIDIUniversalTuningCodec` instance.
    public init() {
    }
}

// MARK: -

extension MIDIUniversalTuningCodec {

    // MARK: Private Type Methods

    private static func _deviceID(_ address: MIDIDeviceAddress) throws -> MIDIData1Value {
        guard case let .deviceID(deviceID) = address
        else { throw MIDITuningError.unsupportedAddress(address) }

        return deviceID
    }

    // Key k sounds at k plus the offset of k % 12. The result stops one below
    // MIDITuningFrequency.noChange, which is a reserved value, not a frequency.
    private static func _frequencies(_ offsets: MIDITuningOffsets) -> [MIDITuningFrequency] {
        let units: [Int] = switch offsets {
        case let .coarse(values):
            values.map { Int(((Double($0.uintValue) - 64) * 16_384 / 100).rounded()) }

        case let .fine(values):
            values.map { (Int($0.uintValue) - 8_192) * 2 }
        }

        return (0..<128).compactMap { key in
            MIDITuningFrequency(uintValue: UInt((key * 16_384 + units[key % 12]).clamped(to: 0...2_097_150)))
        }
    }

    private static func _location(_ slot: MIDITuningSlot) throws -> MIDITuningLocation {
        guard case let .program(bank, program) = slot
        else { throw MIDITuningError.unsupportedSlot(slot) }

        return MIDITuningLocation(program: program,
                                  bank: bank)
    }

    private static func _tuningName(_ name: String) -> String? {
        name.isEmpty ? nil : name
    }
}

// MARK: - Hashable

extension MIDIUniversalTuningCodec: Hashable {
}

// MARK: - MIDITuningCodec

extension MIDIUniversalTuningCodec: MIDITuningCodec {

    // MARK: Public Instance Properties

    /// The first tuning program, with no bank.
    public var defaultSlot: MIDITuningSlot {
        .program(bank: nil, 0)
    }

    /// The limits of the universal messages: a name of up to 16 characters, a
    /// resolution of 100/16,384 cents, all 128 keys, and support for
    /// ``MIDITuningFrequency/noChange``.
    public var limits: MIDITuningLimits {
        MIDITuningLimits(maximumNameLength: 16,
                         resolutionInCents: 100 / 16_384,
                         soundingKeys: 0...127,
                         supportsNoChange: true)
    }

    /// Device ID 127, which means all devices.
    public var probeAddresses: [MIDIDeviceAddress] {
        [.deviceID(127)]
    }

    // MARK: Public Instance Methods

    /// Returns the output that installs a tuning in a slot: one key-based dump,
    /// with no prerequisites.
    ///
    /// A name that isn’t ASCII or is too long is dropped, and reported as
    /// ``MIDITuningOutput/Adjustment/droppedName``.
    ///
    /// - Parameter tuning:     The tuning to install.
    /// - Parameter slot:       The slot to install it in.
    /// - Parameter address:    The address of the device.
    ///
    /// - Returns:  The dump to send.
    ///
    /// - Throws:   A ``MIDITuningError`` if the slot or the address is
    ///             unsupported.
    public func messages(for tuning: MIDIDeviceTuning,
                         slot: MIDITuningSlot,
                         address: MIDIDeviceAddress) throws -> MIDITuningOutput {
        let deviceID = try Self._deviceID(address)
        let location = try Self._location(slot)
        let dump = { (name: String) in
            MIDITuningMessage(content: .keyBasedDump(location,
                                                     name: name,
                                                     frequencies: tuning.frequencies),
                              deviceID: deviceID).systemMessage
        }

        if let message = dump(tuning.name ?? "") {
            return MIDITuningOutput(messages: [message])
        }

        return MIDITuningOutput(messages: [dump("")].compactMap(\.self),
                                adjustments: [.droppedName])
    }

    /// Returns the message that asks a device for the tuning in a slot: one
    /// dump request.
    ///
    /// - Parameter slot:       The slot to ask for.
    /// - Parameter address:    The address of the device.
    ///
    /// - Returns:  The dump request to send.
    ///
    /// - Throws:   A ``MIDITuningError`` if the slot or the address is
    ///             unsupported.
    public func requestMessages(slot: MIDITuningSlot,
                                address: MIDIDeviceAddress) throws -> [MIDISystemMessage] {
        let deviceID = try Self._deviceID(address)
        let location = try Self._location(slot)

        return [MIDITuningMessage(content: .dumpRequest(location),
                                  deviceID: deviceID)].compactMap(\.systemMessage)
    }

    /// Returns the registered parameter messages that select a tuning program
    /// on each channel: the tuning bank if the slot has one, then the tuning
    /// program.
    ///
    /// - Parameter slot:       The slot that holds the tuning.
    /// - Parameter channels:   The channels in use.
    ///
    /// - Returns:  The messages to send, in order.
    ///
    /// - Throws:   A ``MIDITuningError`` if the slot is unsupported.
    public func selectionMessages(slot: MIDITuningSlot,
                                  channels: [MIDIChannel]) throws -> [MIDIChannelMessage] {
        let location = try Self._location(slot)

        return channels.flatMap { channel in
            let bankMessages = location.bank.map {
                MIDIChannelMessage.registeredParameterChange(.tuningBankSelect, msb: $0, on: channel)
            }

            return (bankMessages ?? [])
                + MIDIChannelMessage.registeredParameterChange(.tuningProgramChange, msb: location.program, on: channel)
        }
    }

    /// Returns the tuning held in a key-based dump, or in a scale/octave dump
    /// expanded to 128 keys.
    ///
    /// - Parameter message:    The message to decode.
    ///
    /// - Returns:  The tuning, or `nil` if the message is anything else.
    public func tuning(from message: MIDISystemMessage) -> MIDIDeviceTuning? {
        switch MIDITuningMessage(message)?.content {
        case let .keyBasedDump(_, name, frequencies):
            MIDIDeviceTuning(frequencies: frequencies,
                             name: Self._tuningName(name))

        case let .scaleOctaveDump(_, _, name, offsets):
            MIDIDeviceTuning(frequencies: Self._frequencies(offsets),
                             name: Self._tuningName(name))

        default:
            nil
        }
    }
}

// MARK: - Sendable

extension MIDIUniversalTuningCodec: Sendable {
}
