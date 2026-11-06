// © 2026 John Gary Pusey (see LICENSE.md)

/// The framing of a system exclusive message: its owner and its payload.
///
/// An envelope answers one question, which is whose message this is. It does
/// not interpret the payload, so it can label any well-formed message, even one
/// with no decoder.
///
/// A payload never includes the opening 0xF0, the header, or the closing 0xF7.
/// For a universal message, it starts with sub-ID#2 if the message has one.
///
/// ```swift
/// switch MIDISysExEnvelope(message) {
/// case .none:
///     "Malformed SysEx"
///
/// case let .manufacturer(.yamaha, payload):
///     "Yamaha, \(payload.count) bytes"
///
/// case let .manufacturer(id, payload):
///     "Manufacturer \(id.bytes), \(payload.count) bytes"
///
/// case .nonCommercial:
///     "Non-commercial"
///
/// case .universal(.generalInformation, _, _):
///     "General information"
///
/// case let .universal(id, deviceID, _):
///     "Universal \(id.subID.uintValue), device \(deviceID.uintValue)"
/// }
/// ```
public enum MIDISysExEnvelope {

    /// A manufacturer-specific message.
    case manufacturer(MIDIManufacturerID, payload: [UInt8])

    /// A non-commercial message (0x7D).
    case nonCommercial(payload: [UInt8])

    /// A universal message (0x7E or 0x7F).
    case universal(MIDISysExUniversalID,
                   deviceID: MIDIData1Value,
                   payload: [UInt8])

    // MARK: Public Initializers

    /// Creates a `MIDISysExEnvelope` instance from a system message, or `nil` if
    /// it is not a valid system exclusive message.
    ///
    /// A message is rejected if it is not `systemExclusive`, does not end with
    /// 0xF7, has any other byte above 0x7F, or is too short to hold its header.
    /// The original message still holds the bytes of a rejected message.
    ///
    /// - Parameter message:    The system message.
    public init?(_ message: MIDISystemMessage) {
        guard case let .systemExclusive(bytes) = message,
              bytes.last == 0xf7
        else { return nil }

        let dataBytes = Array(bytes.dropLast())

        guard dataBytes.allSatisfy(\.isMIDIDataByte),
              let firstByte = dataBytes.first
        else { return nil }

        switch firstByte {
        case 0x00:
            guard let id = MIDIManufacturerID(bytes: Array(dataBytes.prefix(3)))
            else { return nil }

            self = .manufacturer(id,
                                 payload: Array(dataBytes.dropFirst(3)))

        case 0x7d:
            self = .nonCommercial(payload: Array(dataBytes.dropFirst()))

        case 0x7e,
             0x7f:
            guard dataBytes.count >= 3
            else { return nil }

            self = .universal(MIDISysExUniversalID(realTime: firstByte == 0x7f,
                                                   subID: MIDIData1Value(clamping: dataBytes[2])),
                              deviceID: MIDIData1Value(clamping: dataBytes[1]),
                              payload: Array(dataBytes.dropFirst(3)))

        default:
            guard let id = MIDIManufacturerID(bytes: [firstByte])
            else { return nil }

            self = .manufacturer(id,
                                 payload: Array(dataBytes.dropFirst()))
        }
    }
}

// MARK: -

extension MIDISysExEnvelope {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether every byte of the payload is a data
    /// byte (0x00–0x7F).
    ///
    /// ``init(_:)`` only creates envelopes with valid payloads, but the cases of
    /// this enumeration can be used directly. A decoder should reject an
    /// envelope if this is `false`.
    public var hasValidPayload: Bool {
        payloadBytes.allSatisfy(\.isMIDIDataByte)
    }

    /// The system message that holds this envelope, or `nil` if its payload
    /// has a byte above 0x7F, which isn’t valid in a system exclusive message.
    public var systemMessage: MIDISystemMessage? {
        guard hasValidPayload
        else { return nil }

        var bytes = headerBytes

        bytes += payloadBytes
        bytes.append(0xf7)

        return .systemExclusive(bytes)
    }

    // MARK: Private Instance Properties

    private var headerBytes: [UInt8] {
        switch self {
        case let .manufacturer(id, _):
            id.bytes

        case .nonCommercial:
            [0x7d]

        case let .universal(id, deviceID, _):
            [id.realTime ? 0x7f : 0x7e,
             deviceID.byteValue,
             id.subID.byteValue]
        }
    }

    private var payloadBytes: [UInt8] {
        switch self {
        case let .manufacturer(_, payload),
             let .nonCommercial(payload),
             let .universal(_, _, payload):
            payload
        }
    }
}

// MARK: - Hashable

extension MIDISysExEnvelope: Hashable {
}

// MARK: - Sendable

extension MIDISysExEnvelope: Sendable {
}
