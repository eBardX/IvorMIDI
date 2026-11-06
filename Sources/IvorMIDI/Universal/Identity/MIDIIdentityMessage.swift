// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A universal non-real-time Identity Request or Identity Reply message.
///
/// A reply doesn’t say which universal messages a device supports. A device
/// that ignores universal messages can’t answer a request at all.
public struct MIDIIdentityMessage {

    // MARK: Public Initializers

    /// Creates a `MIDIIdentityMessage` instance with the provided content and
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

extension MIDIIdentityMessage {

    // MARK: Private Type Methods

    private static func _decodeReply(_ body: [UInt8]) -> Content? {
        let idLength = body.first == 0x00 ? 3 : 1

        guard body.count == idLength + 8,
              let manufacturer = MIDIManufacturerID(bytes: Array(body.prefix(idLength))),
              let family = MIDIData2Value(bytesValue: Array(body[idLength..<(idLength + 2)])),
              let member = MIDIData2Value(bytesValue: Array(body[(idLength + 2)..<(idLength + 4)]))
        else { return nil }

        return .reply(MIDIDeviceIdentity(manufacturer: manufacturer,
                                         family: MIDIDeviceFamily(value: family),
                                         member: MIDIDeviceMember(value: member),
                                         softwareRevision: Array(body.suffix(4))))
    }

    private static func _replyPayload(_ identity: MIDIDeviceIdentity) -> [UInt8]? {
        guard identity.softwareRevision.count == 4,
              identity.softwareRevision.allSatisfy(\.isMIDIDataByte)
        else { return nil }

        let family = identity.family.value
        let member = identity.member.value

        return [0x02]
            + identity.manufacturer.bytes
            + [family.lsb.byteValue, family.msb.byteValue, member.lsb.byteValue, member.msb.byteValue]
            + identity.softwareRevision
    }
}

// MARK: - Hashable

extension MIDIIdentityMessage: Hashable {
}

// MARK: - MIDISysExRepresentable

extension MIDIIdentityMessage: MIDISysExRepresentable {

    // MARK: Public Initializers

    /// Creates a `MIDIIdentityMessage` instance by decoding an envelope, or
    /// `nil` if it does not hold a valid Identity Request or Identity Reply.
    ///
    /// A reply is invalid unless its length matches its manufacturer ID, which
    /// has 1 or 3 bytes.
    ///
    /// - Parameter envelope:   The envelope to decode.
    public init?(_ envelope: MIDISysExEnvelope) {
        guard envelope.hasValidPayload,
              case let .universal(.generalInformation, deviceID, payload) = envelope,
              let subID = payload.first
        else { return nil }

        let body = Array(payload.dropFirst())
        let content: Content? = switch subID {
        case 0x01:
            body.isEmpty ? .request : nil

        case 0x02:
            Self._decodeReply(body)

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
    /// A reply can’t be encoded unless its software revision is 4 data bytes.
    public var envelope: MIDISysExEnvelope? {
        let payload: [UInt8]? = switch content {
        case let .reply(identity):
            Self._replyPayload(identity)

        case .request:
            [0x01]
        }

        guard let payload
        else { return nil }

        return .universal(.generalInformation,
                          deviceID: deviceID,
                          payload: payload)
    }
}

// MARK: - Sendable

extension MIDIIdentityMessage: Sendable {
}
