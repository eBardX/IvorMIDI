// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A decoded MIDI Tuning message.
///
/// This is any universal system exclusive message of the *MIDI Tuning
/// Messages* specification (sub-ID#1 `08`), including its CA-020, CA-021, and
/// RP-020 extensions. Use ``init(_:)`` to read a message from a device, such
/// as its reply to a bulk tuning dump request, and ``systemMessage`` to encode
/// one again.
public struct MIDITuningMessage {

    // MARK: Public Initializers

    /// Creates a `MIDITuningMessage` instance by decoding a system message,
    /// or `nil` if it is not a valid MIDI Tuning message.
    ///
    /// A message is invalid if its length doesn’t match its contents, if the
    /// specification doesn’t define its combination of header and sub-ID, or
    /// if the checksum of a key-based or scale/octave tuning dump is wrong.
    /// The checksum of a bulk tuning dump (sub-ID#2 `01`) is not checked,
    /// because the specification lets receivers ignore it. The bits of the
    /// channel field that the specification reserves are ignored.
    ///
    /// - Parameter message:    The system message to decode.
    public init?(_ message: MIDISystemMessage) {
        guard case let .systemExclusive(bytes) = message,
              bytes.count >= 5,
              bytes.last == 0xf7,
              bytes.dropLast().allSatisfy(\.isMIDIDataByte),
              bytes[2] == 0x08
        else { return nil }

        let content: Content? = switch bytes[0] {
        case 0x7e:
            Self._decodeNonRealTime(bytes)

        case 0x7f:
            Self._decodeRealTime(bytes)

        default:
            nil
        }

        guard let content
        else { return nil }

        self.content = content
        self.deviceID = MIDIData1Value(clamping: bytes[1])
    }

    /// Creates a `MIDITuningMessage` instance with the provided content and
    /// device ID.
    ///
    /// - Parameter content:    The content of the message.
    /// - Parameter deviceID:   The ID of the target or responding device.
    ///                         Defaults to all devices (127).
    public init(content: Content,
                deviceID: MIDIData1Value = 0x7f) {
        self.content = content
        self.deviceID = deviceID
    }

    // MARK: Public Instance Properties

    /// The content of this message.
    public let content: Content

    /// The ID of the target or responding device, where 127 means all
    /// devices.
    public let deviceID: MIDIData1Value
}

// MARK: -

extension MIDITuningMessage {

    // MARK: Public Instance Properties

    /// The system message that encodes this message, or `nil` if it can’t be
    /// encoded.
    ///
    /// A message can’t be encoded if it has the wrong number of elements, if
    /// its tuning name is not ASCII or is longer than 16 characters, or if it
    /// is a single note change with no bank that is not real-time.
    ///
    /// Encoding a decoded message preserves its meaning but not necessarily
    /// its bytes: reserved channel bits are cleared, and the checksum of a
    /// bulk tuning dump is the one this package calculates.
    public var systemMessage: MIDISystemMessage? {
        switch content {
        case let .dumpRequest(location):
            _dumpRequest(location)

        case let .keyBasedDump(location, name, frequencies):
            _keyBasedDump(location, name, frequencies)

        case let .scaleOctaveDump(bank, program, name, offsets):
            .scaleOctaveTuningDump(bank: bank,
                                   program: program,
                                   name: name,
                                   offsets: offsets,
                                   deviceID: deviceID)

        case let .scaleOctaveTuning(channels, offsets, realTime):
            .scaleOctaveTuning(channels: channels,
                               offsets: offsets,
                               realTime: realTime,
                               deviceID: deviceID)

        case let .singleNoteChange(location, changes, realTime):
            _singleNoteChange(location, changes, realTime)
        }
    }

    // MARK: Private Type Methods

    private static func _channels(_ bytes: ArraySlice<UInt8>) -> [MIDIChannel] {
        let channelBytes = Array(bytes)       // ff (15–16), gg (8–14), hh (1–7)

        return (0..<16).compactMap { index in
            channelBytes[2 - index / 7] & (1 << (index % 7)) == 0 ? nil : MIDIChannel(clamping: index + 1)
        }
    }

    private static func _decodeDumpRequest(_ payload: [UInt8],
                                           hasBank: Bool) -> Content? {
        guard payload.count == (hasBank ? 2 : 1)
        else { return nil }

        return .dumpRequest(_location(payload, hasBank))
    }

    private static func _decodeKeyBasedDump(_ payload: [UInt8],
                                            hasBank: Bool) -> Content? {
        let nameStart = hasBank ? 2 : 1
        let dataStart = nameStart + 16

        guard payload.count == dataStart + 384 + 1
        else { return nil }

        let frequencies = stride(from: dataStart, to: dataStart + 384, by: 3).compactMap {
            MIDITuningFrequency(bytesValue: Array(payload[$0..<($0 + 3)]))
        }

        return .keyBasedDump(_location(payload, hasBank),
                             name: _name(payload[nameStart..<dataStart]),
                             frequencies: frequencies)
    }

    private static func _decodeNonRealTime(_ bytes: [UInt8]) -> Content? {
        let payload = Array(bytes[4..<(bytes.count - 1)])

        switch bytes[3] {
        case 0x00:
            return _decodeDumpRequest(payload, hasBank: false)

        case 0x01:
            return _decodeKeyBasedDump(payload, hasBank: false)

        case 0x03:
            return _decodeDumpRequest(payload, hasBank: true)

        case 0x04:
            return _hasValidChecksum(bytes) ? _decodeKeyBasedDump(payload, hasBank: true) : nil

        case 0x05:
            return _hasValidChecksum(bytes) ? _decodeScaleOctaveDump(payload, offsetByteCount: 12) : nil

        case 0x06:
            return _hasValidChecksum(bytes) ? _decodeScaleOctaveDump(payload, offsetByteCount: 24) : nil

        case 0x07:
            return _decodeSingleNoteChange(payload, hasBank: true, realTime: false)

        case 0x08:
            return _decodeScaleOctaveTuning(payload, offsetByteCount: 12, realTime: false)

        case 0x09:
            return _decodeScaleOctaveTuning(payload, offsetByteCount: 24, realTime: false)

        default:
            return nil
        }
    }

    private static func _decodeRealTime(_ bytes: [UInt8]) -> Content? {
        let payload = Array(bytes[4..<(bytes.count - 1)])

        switch bytes[3] {
        case 0x02:
            return _decodeSingleNoteChange(payload, hasBank: false, realTime: true)

        case 0x07:
            return _decodeSingleNoteChange(payload, hasBank: true, realTime: true)

        case 0x08:
            return _decodeScaleOctaveTuning(payload, offsetByteCount: 12, realTime: true)

        case 0x09:
            return _decodeScaleOctaveTuning(payload, offsetByteCount: 24, realTime: true)

        default:
            return nil
        }
    }

    private static func _decodeScaleOctaveDump(_ payload: [UInt8],
                                               offsetByteCount: Int) -> Content? {
        guard payload.count == 18 + offsetByteCount + 1,
              let offsets = MIDITuningOffsets(bytesValue: Array(payload[18..<(18 + offsetByteCount)]))
        else { return nil }

        return .scaleOctaveDump(bank: MIDIData1Value(clamping: payload[0]),
                                program: MIDIData1Value(clamping: payload[1]),
                                name: _name(payload[2..<18]),
                                offsets: offsets)
    }

    private static func _decodeScaleOctaveTuning(_ payload: [UInt8],
                                                 offsetByteCount: Int,
                                                 realTime: Bool) -> Content? {
        guard payload.count == 3 + offsetByteCount,
              let offsets = MIDITuningOffsets(bytesValue: Array(payload[3...]))
        else { return nil }

        return .scaleOctaveTuning(channels: _channels(payload[0..<3]),
                                  offsets: offsets,
                                  realTime: realTime)
    }

    private static func _decodeSingleNoteChange(_ payload: [UInt8],
                                                hasBank: Bool,
                                                realTime: Bool) -> Content? {
        let countIndex = hasBank ? 2 : 1

        guard payload.count > countIndex
        else { return nil }

        let changeCount = Int(payload[countIndex])
        let start = countIndex + 1

        guard changeCount > 0,
              payload.count == start + changeCount * 4
        else { return nil }

        let changes = stride(from: start, to: payload.count, by: 4).compactMap { index in
            MIDITuningFrequency(bytesValue: Array(payload[(index + 1)..<(index + 4)])).map {
                MIDITuningChange(key: MIDIData1Value(clamping: payload[index]), frequency: $0)
            }
        }

        return .singleNoteChange(_location(payload, hasBank),
                                 changes: changes,
                                 realTime: realTime)
    }

    private static func _hasValidChecksum(_ bytes: [UInt8]) -> Bool {
        bytes.count >= 6 && bytes[bytes.count - 2] == MIDISystemMessage.tuningChecksum(bytes.dropLast(2))
    }

    private static func _location(_ payload: [UInt8],
                                  _ hasBank: Bool) -> MIDITuningLocation {
        hasBank
            ? MIDITuningLocation(program: MIDIData1Value(clamping: payload[1]),
                                 bank: MIDIData1Value(clamping: payload[0]))
            : MIDITuningLocation(program: MIDIData1Value(clamping: payload[0]))
    }

    private static func _name(_ bytes: ArraySlice<UInt8>) -> String {
        var name = bytes

        while name.last == 0x20 {
            name.removeLast()
        }

        return String(name.map { Character(Unicode.Scalar($0)) })
    }

    // MARK: Private Instance Methods

    private func _dumpRequest(_ location: MIDITuningLocation) -> MIDISystemMessage {
        if let bank = location.bank {
            .bulkTuningDumpRequest(bank: bank,
                                   program: location.program,
                                   deviceID: deviceID)
        } else {
            .bulkTuningDumpRequest(program: location.program,
                                   deviceID: deviceID)
        }
    }

    private func _keyBasedDump(_ location: MIDITuningLocation,
                               _ name: String,
                               _ frequencies: [MIDITuningFrequency]) -> MIDISystemMessage? {
        if let bank = location.bank {
            .keyBasedTuningDump(bank: bank,
                                program: location.program,
                                name: name,
                                frequencies: frequencies,
                                deviceID: deviceID)
        } else {
            .bulkTuningDump(program: location.program,
                            name: name,
                            frequencies: frequencies,
                            deviceID: deviceID)
        }
    }

    private func _singleNoteChange(_ location: MIDITuningLocation,
                                   _ changes: [MIDITuningChange],
                                   _ realTime: Bool) -> MIDISystemMessage? {
        if let bank = location.bank {
            return .singleNoteTuningChange(changes,
                                           bank: bank,
                                           program: location.program,
                                           realTime: realTime,
                                           deviceID: deviceID)
        }

        guard realTime
        else { return nil }

        return .singleNoteTuningChange(changes,
                                       program: location.program,
                                       deviceID: deviceID)
    }
}

// MARK: - Hashable

extension MIDITuningMessage: Hashable {
}

// MARK: - Sendable

extension MIDITuningMessage: Sendable {
}
