// © 2026 John Gary Pusey (see LICENSE.md)

// A TX81Z tuning message.
//
// These formats come from the owner’s manual, in Specifications/. Two misprints
// there are easy to “correct” this code to match, and both are wrong: p.67
// prints the PCED hh as 11 (3), but it is 00, giving group 10, and p.69 prints
// the full keyboard size as 00 22, but it is 02 0A.
internal struct TX81ZTuningMessage {

    // MARK: Internal Initializers

    internal init(content: Content,
                  channel: MIDIChannel) {
        self.channel = channel
        self.content = content
    }

    // MARK: Internal Instance Properties

    internal let channel: MIDIChannel
    internal let content: Content
}

// MARK: -

extension TX81ZTuningMessage {

    // MARK: Private Type Properties

    private static let bulkFormat: UInt8 = 0x7e
    private static let keyParameter: UInt8 = 99
    private static let parameterGroup: UInt8 = 0x10
    private static let tableParameter: UInt8 = 96
    private static let tagLength = 10

    // MARK: Private Type Methods

    private static func _decodeDump(_ payload: [UInt8]) -> Content? {
        guard payload[1] == bulkFormat,
              let data = YamahaSysEx.bulkDumpData(payload),
              let table = TX81ZTuningTable(tagBytes: data.prefix(tagLength)),
              data.count == tagLength + 2 * table.entryCount
        else { return nil }

        let pitchBytes = Array(data.dropFirst(tagLength))
        let pitches = stride(from: 0, to: pitchBytes.count, by: 2).compactMap {
            TX81ZPitch(bytesValue: Array(pitchBytes[$0..<($0 + 2)]))
        }

        guard pitches.count == table.entryCount
        else { return nil }

        return .dump(table, pitches: pitches)
    }

    private static func _decodeDumpRequest(_ payload: [UInt8]) -> Content? {
        guard payload.count == 2 + tagLength,
              payload[1] == bulkFormat,
              let table = TX81ZTuningTable(tagBytes: payload.dropFirst(2))
        else { return nil }

        return .dumpRequest(table)
    }

    private static func _decodeParameter(_ payload: [UInt8]) -> Content? {
        guard payload.count == 4,
              payload[1] == parameterGroup
        else { return nil }

        let parameter = payload[2]
        let data = payload[3]

        switch parameter {
        case keyParameter:
            return data <= 11 ? .microTuneKey(MIDIData1Value(clamping: data)) : nil

        case tableParameter:
            return TX81ZTuningSelection(dataByte: data).map { .microTuneTable($0) }

        default:
            guard parameter >= 11,
                  parameter <= 95,
                  (parameter - 11).isMultiple(of: 12),
                  data <= 1
            else { return nil }

            return .microTuneEnable(instrument: MIDIData1Value(clamping: (parameter - 11) / 12 + 1),
                                    isEnabled: data == 1)
        }
    }

    // MARK: Private Instance Methods

    private func _dumpPayload(_ table: TX81ZTuningTable,
                              _ pitches: [TX81ZPitch]) -> [UInt8]? {
        guard pitches.count == table.entryCount
        else { return nil }

        return YamahaSysEx.bulkDumpPayload(channel: channel,
                                           format: Self.bulkFormat,
                                           data: table.tagBytes + pitches.flatMap { $0.bytesValue ?? [] })
    }

    private func _parameterPayload(_ parameter: UInt8,
                                   _ data: UInt8) -> [UInt8] {
        [YamahaSysEx.statusByte(YamahaSysEx.parameterChangeKind, channel),
         Self.parameterGroup,
         parameter,
         data]
    }
}

// MARK: - Hashable

extension TX81ZTuningMessage: Hashable {
}

// MARK: - MIDISysExRepresentable

extension TX81ZTuningMessage: MIDISysExRepresentable {

    // MARK: Internal Initializers

    internal init?(_ envelope: MIDISysExEnvelope) {
        guard envelope.hasValidPayload,
              case let .manufacturer(.yamaha, payload) = envelope,
              payload.count >= 2
        else { return nil }

        let content: Content? = switch payload[0] & 0xf0 {
        case YamahaSysEx.bulkDumpKind:
            Self._decodeDump(payload)

        case YamahaSysEx.dumpRequestKind:
            Self._decodeDumpRequest(payload)

        case YamahaSysEx.parameterChangeKind:
            Self._decodeParameter(payload)

        default:
            nil
        }

        guard let content
        else { return nil }

        self.init(content: content,
                  channel: MIDIChannel(clamping: (payload[0] & 0x0f) + 1))
    }

    // MARK: Internal Instance Properties

    internal var envelope: MIDISysExEnvelope? {
        let payload: [UInt8]? = switch content {
        case let .dump(table, pitches):
            _dumpPayload(table, pitches)

        case let .dumpRequest(table):
            [YamahaSysEx.statusByte(YamahaSysEx.dumpRequestKind, channel), Self.bulkFormat] + table.tagBytes

        case let .microTuneEnable(instrument, isEnabled):
            (1...8).contains(instrument.uintValue)
                ? _parameterPayload(11 + 12 * (instrument.byteValue - 1), isEnabled ? 1 : 0)
                : nil

        case let .microTuneKey(key):
            key.uintValue <= 11 ? _parameterPayload(Self.keyParameter, key.byteValue) : nil

        case let .microTuneTable(selection):
            _parameterPayload(Self.tableParameter, selection.dataByte)
        }

        guard let payload
        else { return nil }

        return .manufacturer(.yamaha,
                             payload: payload)
    }
}

// MARK: - Sendable

extension TX81ZTuningMessage: Sendable {
}
