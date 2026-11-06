// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI Tuning message.
///
/// This is any universal system exclusive message of the *MIDI Tuning
/// Messages* specification (sub-ID#1 `08`), as defined in
/// `Specifications/MIDI Tuning Messages.pdf`, which includes its CA-020,
/// CA-021, and RP-020 extensions. Tuning programs and banks are selected with
/// the RPNs in ``MIDIRegisteredParameter``.
///
/// ``MIDISysExRepresentable`` provides the conversions: create an instance from
/// a message received from a device, such as its reply to a dump request, and
/// use ``envelope`` or ``MIDISysExRepresentable/systemMessage`` to encode one.
public struct MIDITuningMessage {

    // MARK: Public Initializers

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

    // MARK: Private Type Methods

    private static func _bytes(_ frequency: MIDITuningFrequency) -> [UInt8] {
        [frequency.semitone.byteValue] + _bytes(frequency.fraction)
    }

    private static func _bytes(_ value: MIDIData2Value) -> [UInt8] {
        [value.msb.byteValue, value.lsb.byteValue]
    }

    private static func _changeBytes(_ changes: [MIDITuningChange]) -> [UInt8]? {
        guard let count = UInt8(exactly: changes.count),
              (1...127).contains(count)
        else { return nil }

        return [count] + changes.flatMap { [$0.key.byteValue] + _bytes($0.frequency) }
    }

    private static func _channelBytes(_ channels: [MIDIChannel]) -> [UInt8] {
        var channelBytes: [UInt8] = [0x00, 0x00, 0x00]    // ff (15–16), gg (8–14), hh (1–7)

        for channel in channels {
            let index = Int(channel.uintValue) - 1

            channelBytes[2 - index / 7] |= 1 << (index % 7)
        }

        return channelBytes
    }

    private static func _channels(_ bytes: ArraySlice<UInt8>) -> [MIDIChannel] {
        let channelBytes = Array(bytes)       // ff (15–16), gg (8–14), hh (1–7)

        return (0..<16).compactMap { index in
            channelBytes[2 - index / 7] & (1 << (index % 7)) == 0 ? nil : MIDIChannel(clamping: index + 1)
        }
    }

    // The checksum of the dumps with sub-ID#2 04, 05, and 06 covers every byte
    // after F0 and before the checksum, so the header has to be rebuilt.
    private static func _checksum(_ subID: UInt8,
                                  _ deviceID: MIDIData1Value,
                                  _ body: some Sequence<UInt8>) -> UInt8 {
        ([0x7e, deviceID.byteValue, 0x08, subID] + body).tuningChecksum
    }

    private static func _decodeDumpRequest(_ body: [UInt8],
                                           hasBank: Bool) -> Content? {
        guard body.count == (hasBank ? 2 : 1)
        else { return nil }

        return .dumpRequest(_location(body, hasBank))
    }

    private static func _decodeKeyBasedDump(_ body: [UInt8],
                                            hasBank: Bool) -> Content? {
        let nameStart = hasBank ? 2 : 1
        let dataStart = nameStart + 16

        guard body.count == dataStart + 384 + 1
        else { return nil }

        let frequencies = stride(from: dataStart, to: dataStart + 384, by: 3).compactMap {
            MIDITuningFrequency(bytesValue: Array(body[$0..<($0 + 3)]))
        }

        return .keyBasedDump(_location(body, hasBank),
                             name: _name(body[nameStart..<dataStart]),
                             frequencies: frequencies)
    }

    private static func _decodeNonRealTime(_ subID: UInt8,
                                           _ body: [UInt8],
                                           _ deviceID: MIDIData1Value) -> Content? {
        let hasValidChecksum = body.last == _checksum(subID, deviceID, body.dropLast())

        switch subID {
        case 0x00:
            return _decodeDumpRequest(body, hasBank: false)

        case 0x01:
            return _decodeKeyBasedDump(body, hasBank: false)

        case 0x03:
            return _decodeDumpRequest(body, hasBank: true)

        case 0x04:
            return hasValidChecksum ? _decodeKeyBasedDump(body, hasBank: true) : nil

        case 0x05:
            return hasValidChecksum ? _decodeScaleOctaveDump(body, offsetByteCount: 12) : nil

        case 0x06:
            return hasValidChecksum ? _decodeScaleOctaveDump(body, offsetByteCount: 24) : nil

        case 0x07:
            return _decodeSingleNoteChange(body, hasBank: true, realTime: false)

        case 0x08:
            return _decodeScaleOctaveTuning(body, offsetByteCount: 12, realTime: false)

        case 0x09:
            return _decodeScaleOctaveTuning(body, offsetByteCount: 24, realTime: false)

        default:
            return nil
        }
    }

    private static func _decodeRealTime(_ subID: UInt8,
                                        _ body: [UInt8]) -> Content? {
        switch subID {
        case 0x02:
            _decodeSingleNoteChange(body, hasBank: false, realTime: true)

        case 0x07:
            _decodeSingleNoteChange(body, hasBank: true, realTime: true)

        case 0x08:
            _decodeScaleOctaveTuning(body, offsetByteCount: 12, realTime: true)

        case 0x09:
            _decodeScaleOctaveTuning(body, offsetByteCount: 24, realTime: true)

        default:
            nil
        }
    }

    private static func _decodeScaleOctaveDump(_ body: [UInt8],
                                               offsetByteCount: Int) -> Content? {
        guard body.count == 18 + offsetByteCount + 1,
              let offsets = MIDITuningOffsets(bytesValue: Array(body[18..<(18 + offsetByteCount)]))
        else { return nil }

        return .scaleOctaveDump(bank: MIDIData1Value(clamping: body[0]),
                                program: MIDIData1Value(clamping: body[1]),
                                name: _name(body[2..<18]),
                                offsets: offsets)
    }

    private static func _decodeScaleOctaveTuning(_ body: [UInt8],
                                                 offsetByteCount: Int,
                                                 realTime: Bool) -> Content? {
        guard body.count == 3 + offsetByteCount,
              let offsets = MIDITuningOffsets(bytesValue: Array(body[3...]))
        else { return nil }

        return .scaleOctaveTuning(channels: _channels(body[0..<3]),
                                  offsets: offsets,
                                  realTime: realTime)
    }

    private static func _decodeSingleNoteChange(_ body: [UInt8],
                                                hasBank: Bool,
                                                realTime: Bool) -> Content? {
        let countIndex = hasBank ? 2 : 1

        guard body.count > countIndex
        else { return nil }

        let changeCount = Int(body[countIndex])
        let start = countIndex + 1

        guard changeCount > 0,
              body.count == start + changeCount * 4
        else { return nil }

        let changes = stride(from: start, to: body.count, by: 4).compactMap { index in
            MIDITuningFrequency(bytesValue: Array(body[(index + 1)..<(index + 4)])).map {
                MIDITuningChange(key: MIDIData1Value(clamping: body[index]), frequency: $0)
            }
        }

        return .singleNoteChange(_location(body, hasBank),
                                 changes: changes,
                                 realTime: realTime)
    }

    private static func _dumpBody(_ location: [UInt8],
                                  _ name: String,
                                  _ data: [UInt8]) -> [UInt8]? {
        guard let nameBytes = _nameBytes(name)
        else { return nil }

        return location + nameBytes + data
    }

    private static func _location(_ body: [UInt8],
                                  _ hasBank: Bool) -> MIDITuningLocation {
        hasBank
            ? MIDITuningLocation(program: MIDIData1Value(clamping: body[1]),
                                 bank: MIDIData1Value(clamping: body[0]))
            : MIDITuningLocation(program: MIDIData1Value(clamping: body[0]))
    }

    private static func _locationBytes(_ location: MIDITuningLocation) -> [UInt8] {
        if let bank = location.bank {
            [bank.byteValue, location.program.byteValue]
        } else {
            [location.program.byteValue]
        }
    }

    private static func _name(_ bytes: ArraySlice<UInt8>) -> String {
        var name = bytes

        while name.last == 0x20 {
            name.removeLast()
        }

        return String(name.map { Character(Unicode.Scalar($0)) })
    }

    private static func _nameBytes(_ name: String) -> [UInt8]? {
        let bytes = Array(name.utf8)

        guard bytes.count <= 16,
              bytes.allSatisfy(\.isMIDIDataByte)
        else { return nil }

        return bytes + [UInt8](repeating: 0x20, count: 16 - bytes.count)
    }

    private static func _scaleOctaveTuningPayload(_ channels: [MIDIChannel],
                                                  _ offsets: MIDITuningOffsets) -> [UInt8]? {
        guard let offsetBytes = offsets.bytesValue
        else { return nil }

        return [offsets.isFine ? 0x09 : 0x08] + _channelBytes(channels) + offsetBytes
    }

    private static func _singleNoteChangePayload(_ location: MIDITuningLocation,
                                                 _ changes: [MIDITuningChange],
                                                 _ realTime: Bool) -> [UInt8]? {
        guard location.bank != nil || realTime,
              let changeBytes = _changeBytes(changes)
        else { return nil }

        return [location.bank == nil ? 0x02 : 0x07] + _locationBytes(location) + changeBytes
    }

    // MARK: Private Instance Methods

    private func _dumpPayload(_ subID: UInt8,
                              _ body: [UInt8]?) -> [UInt8]? {
        guard let body
        else { return nil }

        return [subID] + body + [Self._checksum(subID, deviceID, body)]
    }

    private func _envelope(_ payload: [UInt8]?,
                           realTime: Bool = false) -> MIDISysExEnvelope? {
        guard let payload
        else { return nil }

        return .universal(realTime ? .realTimeTuning : .tuning,
                          deviceID: deviceID,
                          payload: payload)
    }

    // A bulk tuning dump (sub-ID#2 01) has its own checksum, which leaves out
    // sub-ID#1. Key-based tuning dumps (04) use the checksum of the other dumps.
    private func _keyBasedDumpPayload(_ location: MIDITuningLocation,
                                      _ name: String,
                                      _ frequencies: [MIDITuningFrequency]) -> [UInt8]? {
        guard frequencies.count == 128,
              let body = Self._dumpBody(Self._locationBytes(location), name, frequencies.flatMap(Self._bytes))
        else { return nil }

        guard location.bank == nil
        else { return _dumpPayload(0x04, body) }

        return [0x01] + body + [([0x7e, deviceID.byteValue, 0x01] + body).tuningChecksum]
    }

    private func _scaleOctaveDumpPayload(_ bank: MIDIData1Value,
                                         _ program: MIDIData1Value,
                                         _ name: String,
                                         _ offsets: MIDITuningOffsets) -> [UInt8]? {
        guard let offsetBytes = offsets.bytesValue
        else { return nil }

        return _dumpPayload(offsets.isFine ? 0x06 : 0x05,
                            Self._dumpBody([bank.byteValue, program.byteValue], name, offsetBytes))
    }
}

// MARK: - Hashable

extension MIDITuningMessage: Hashable {
}

// MARK: - MIDISysExRepresentable

extension MIDITuningMessage: MIDISysExRepresentable {

    // MARK: Public Initializers

    /// Creates a `MIDITuningMessage` instance by decoding an envelope, or `nil`
    /// if it does not hold a valid MIDI Tuning message.
    ///
    /// A message is invalid if its payload has a byte above 0x7F, if its
    /// length doesn’t match its contents, if the specification doesn’t define
    /// its combination of header and sub-ID, or if the checksum of a key-based
    /// or scale/octave tuning dump is wrong.
    /// The checksum of a bulk tuning dump (sub-ID#2 `01`) is not checked,
    /// because the specification lets receivers ignore it. The bits of the
    /// channel field that the specification reserves are ignored.
    ///
    /// - Parameter envelope:   The envelope to decode.
    public init?(_ envelope: MIDISysExEnvelope) {
        guard envelope.hasValidPayload,
              case let .universal(id, deviceID, payload) = envelope,
              let subID = payload.first
        else { return nil }

        let body = Array(payload.dropFirst())
        let content: Content? = switch id {
        case .realTimeTuning:
            Self._decodeRealTime(subID, body)

        case .tuning:
            Self._decodeNonRealTime(subID, body, deviceID)

        default:
            nil
        }

        guard let content
        else { return nil }

        self.init(content: content,
                  deviceID: deviceID)
    }

    // MARK: Public Instance Properties

    /// The envelope that encodes this message, or `nil` if it can’t be
    /// encoded.
    ///
    /// A message can’t be encoded if it has the wrong number of elements, if
    /// its tuning name is not ASCII or is longer than 16 characters, or if it
    /// is a single note change with no bank that is not real-time.
    ///
    /// Encoding a decoded message preserves its meaning but not necessarily
    /// its bytes: reserved channel bits are cleared, and the checksum of a
    /// bulk tuning dump is the one this package calculates.
    public var envelope: MIDISysExEnvelope? {
        switch content {
        case let .dumpRequest(location):
            _envelope([location.bank == nil ? 0x00 : 0x03] + Self._locationBytes(location))

        case let .keyBasedDump(location, name, frequencies):
            _envelope(_keyBasedDumpPayload(location, name, frequencies))

        case let .scaleOctaveDump(bank, program, name, offsets):
            _envelope(_scaleOctaveDumpPayload(bank, program, name, offsets))

        case let .scaleOctaveTuning(channels, offsets, realTime):
            _envelope(Self._scaleOctaveTuningPayload(channels, offsets),
                      realTime: realTime)

        case let .singleNoteChange(location, changes, realTime):
            _envelope(Self._singleNoteChangePayload(location, changes, realTime),
                      realTime: realTime)
        }
    }
}

// MARK: - Sendable

extension MIDITuningMessage: Sendable {
}
