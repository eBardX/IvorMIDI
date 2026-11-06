// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A universal real-time Device Control message (`F0 7F id 04 …`) that sets
/// the master volume or tuning of a device.
///
/// ```swift
/// let message = MIDIDeviceControlMessage(content: .masterVolume(16_383))
/// ```
public struct MIDIDeviceControlMessage {

    // MARK: Public Initializers

    /// Creates a `MIDIDeviceControlMessage` instance with the provided content
    /// and device ID.
    ///
    /// - Parameter content:    The content of the message.
    /// - Parameter deviceID:   The ID of the target device. Defaults to all
    ///                         devices (127).
    public init(content: Content,
                deviceID: MIDIData1Value = 0x7f) {
        self.content = content
        self.deviceID = deviceID
    }

    // MARK: Public Instance Properties

    /// The content of this message.
    public let content: Content

    /// The ID of the target device, where 127 means all devices.
    public let deviceID: MIDIData1Value
}

// MARK: -

extension MIDIDeviceControlMessage {

    // MARK: Private Type Methods

    private static func _value(_ payload: [UInt8]) -> MIDIData2Value {
        MIDIData2Value(msb: MIDIData1Value(clamping: payload[2]),
                       lsb: MIDIData1Value(clamping: payload[1]))
    }
}

// MARK: - Hashable

extension MIDIDeviceControlMessage: Hashable {
}

// MARK: - MIDISysExRepresentable

extension MIDIDeviceControlMessage: MIDISysExRepresentable {

    // MARK: Public Initializers

    /// Creates a `MIDIDeviceControlMessage` instance by decoding an envelope,
    /// or `nil` if it does not hold a master volume or tuning message.
    ///
    /// The byte before the value of a master coarse tuning message is ignored.
    ///
    /// - Parameter envelope:   The envelope to decode.
    public init?(_ envelope: MIDISysExEnvelope) {
        guard envelope.hasValidPayload,
              case let .universal(.deviceControl, deviceID, payload) = envelope,
              payload.count == 3
        else { return nil }

        let content: Content? = switch payload[0] {
        case 0x01:
            .masterVolume(Self._value(payload))

        case 0x03:
            .masterFineTuning(Self._value(payload))

        case 0x04:
            .masterCoarseTuning(MIDIData1Value(clamping: payload[2]))

        default:
            nil
        }

        guard let content
        else { return nil }

        self.init(content: content,
                  deviceID: deviceID)
    }

    // MARK: Public Instance Properties

    /// The envelope that encodes this message.
    ///
    /// Every device control message can be encoded, so this is never `nil`.
    public var envelope: MIDISysExEnvelope? {
        let payload: [UInt8] = switch content {
        case let .masterCoarseTuning(tuning):
            [0x04, 0x00, tuning.byteValue]

        case let .masterFineTuning(tuning):
            [0x03, tuning.lsb.byteValue, tuning.msb.byteValue]

        case let .masterVolume(volume):
            [0x01, volume.lsb.byteValue, volume.msb.byteValue]
        }

        return .universal(.deviceControl,
                          deviceID: deviceID,
                          payload: payload)
    }
}

// MARK: - Sendable

extension MIDIDeviceControlMessage: Sendable {
}
