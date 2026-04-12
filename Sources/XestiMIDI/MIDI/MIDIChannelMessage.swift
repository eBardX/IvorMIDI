// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A MIDI channel voice or mode message.
public enum MIDIChannelMessage {

    /// A channel pressure (aftertouch) message.
    case channelPressure(MIDIChannel, MIDIData1Value)

    /// A control change message.
    case controlChange(MIDIChannel, MIDIController, MIDIData1Value)

    /// A note off message.
    case noteOff(MIDIChannel, MIDIData1Value, MIDIData1Value)

    /// A note on message.
    case noteOn(MIDIChannel, MIDIData1Value, MIDIData1Value)

    /// A pitch bend change message.
    case pitchBendChange(MIDIChannel, MIDIPitchBend)

    /// A polyphonic key pressure (aftertouch) message.
    case polyphonicPressure(MIDIChannel, MIDIData1Value, MIDIData1Value)

    /// A program change message.
    case programChange(MIDIChannel, MIDIData1Value)
}

// MARK: -

extension MIDIChannelMessage {

    // MARK: Public Type Methods

    /// Returns the expected number of data bytes for a channel message
    /// with the provided status byte, or `nil` if the status byte does not
    /// identify a channel message.
    ///
    /// - Parameter statusByte: The status byte.
    ///
    /// - Returns:  The expected data byte count, or `nil`.
    public static func expectedDataByteCount(for statusByte: UInt8) -> Int? {
        switch statusByte & 0xf0 {
        case 0x80, 0x90, 0xa0, 0xb0, 0xe0:
            2

        case 0xc0, 0xd0:
            1

        default:
            nil
        }
    }

    /// Returns a Boolean value indicating whether the provided status and
    /// data bytes represent a channel mode message.
    ///
    /// - Parameter statusByte: The status byte.
    /// - Parameter dataBytes:  The data bytes.
    ///
    /// - Returns:  `true` if the bytes represent a channel mode message;
    ///             otherwise, `false`.
    public static func isModeMessage(_ statusByte: UInt8,
                                     _ dataBytes: [UInt8]) -> Bool {
        guard (statusByte & 0xf0) == 0xb0,
              let dataByte = dataBytes.first,
              (121...127).contains(dataByte)
        else { return false }

        return true
    }

    /// Returns a Boolean value indicating whether the provided status and
    /// data bytes represent a channel voice message.
    ///
    /// - Parameter statusByte: The status byte.
    /// - Parameter dataBytes:  The data bytes.
    ///
    /// - Returns:  `true` if the bytes represent a channel voice message;
    ///             otherwise, `false`.
    public static func isVoiceMessage(_ statusByte: UInt8,
                                      _ dataBytes: [UInt8]) -> Bool {
        guard (0x80..<0xf0).contains(statusByte & 0xf0),
              !isModeMessage(statusByte, dataBytes)
        else { return false }

        return true
    }

    // MARK: Public Initializers

    /// Creates a `MIDIChannelMessage` instance from the provided status
    /// byte and data bytes, or `nil` if the bytes do not represent a valid
    /// channel message.
    ///
    /// - Parameter statusByte: The status byte.
    /// - Parameter dataBytes:  The data bytes.
    public init?(statusByte: UInt8,
                 dataBytes: [UInt8]) {
        guard let edbCount = Self.expectedDataByteCount(for: statusByte),
              edbCount == dataBytes.count,
              dataBytes.allSatisfy({ $0.isMIDIDataByte }),
              let channel = MIDIChannel(bytesValue: [statusByte & 0x0f])
        else { return nil }

        switch statusByte & 0xf0 {
        case 0x80:
            guard let note = MIDIData1Value(bytesValue: [dataBytes[0]]),
                  let velocity = MIDIData1Value(bytesValue: [dataBytes[1]])
            else { return nil }

            self = .noteOff(channel, note, velocity)

        case 0x90:
            guard let note = MIDIData1Value(bytesValue: [dataBytes[0]]),
                  let velocity = MIDIData1Value(bytesValue: [dataBytes[1]])
            else { return nil }

            self = .noteOn(channel, note, velocity)

        case 0xa0:
            guard let note = MIDIData1Value(bytesValue: [dataBytes[0]]),
                  let pressure = MIDIData1Value(bytesValue: [dataBytes[1]])
            else { return nil }

            self = .polyphonicPressure(channel, note, pressure)

        case 0xb0:
            guard let controller = MIDIController(bytesValue: [dataBytes[0]]),
                  let controlValue = MIDIData1Value(bytesValue: [dataBytes[1]])
            else { return nil }

            self = .controlChange(channel, controller, controlValue)

        case 0xc0:
            guard let program = MIDIData1Value(bytesValue: [dataBytes[0]])
            else { return nil }

            self = .programChange(channel, program)

        case 0xd0:
            guard let pressure = MIDIData1Value(bytesValue: [dataBytes[0]])
            else { return nil }

            self = .channelPressure(channel, pressure)

        case 0xe0:
            guard let pitchBend = MIDIPitchBend(bytesValue: Array(dataBytes[0...1]))
            else { return nil }

            self = .pitchBendChange(channel, pitchBend)

        default:
            return nil
        }
    }

    // MARK: Public Instance Properties

    /// The MIDI channel of this message.
    public var channel: MIDIChannel {
        switch self {
        case let .channelPressure(channel, _),
            let .controlChange(channel, _, _),
            let .noteOff(channel, _, _),
            let .noteOn(channel, _, _),
            let .pitchBendChange(channel, _),
            let .polyphonicPressure(channel, _, _),
            let .programChange(channel, _):
            channel
        }
    }

    /// The data bytes of this message, or `nil` if the message cannot be
    /// encoded.
    public var dataBytes: [UInt8]? {
        switch self {
        case let .channelPressure(_, pressure):
            pressure.bytesValue

        case let .controlChange(_, controller, controlValue):
            _combine(controller, controlValue)

        case let .noteOff(_, note, velocity):
            _combine(note, velocity)

        case let .noteOn(_, note, velocity):
            _combine(note, velocity)

        case let .pitchBendChange(_, pitchBend):
            pitchBend.bytesValue

        case let .polyphonicPressure(_, note, pressure):
            _combine(note, pressure)

        case let .programChange(_, program):
            program.bytesValue
        }
    }

    /// The status byte of this message, or `nil` if the message cannot be
    /// encoded.
    public var statusByte: UInt8? {
        switch self {
        case let .channelPressure(channel, _):
            _combine(0xd0, channel)

        case let .controlChange(channel, _, _):
            _combine(0xb0, channel)

        case let .noteOff(channel, _, _):
            _combine(0x80, channel)

        case let .noteOn(channel, _, _):
            _combine(0x90, channel)

        case let .pitchBendChange(channel, _):
            _combine(0xe0, channel)

        case let .polyphonicPressure(channel, _, _):
            _combine(0xa0, channel)

        case let .programChange(channel, _):
            _combine(0xc0, channel)
        }
    }

    // MARK: Private Instance Methods

    private func _combine(_ statusByte: UInt8,
                          _ channel: MIDIChannel) -> UInt8? {
        guard let channelByte = channel.bytesValue?.first
        else { return nil }

        return statusByte | channelByte
    }

    private func _combine(_ value1: any BytesValueConvertible,
                          _ value2: any BytesValueConvertible) -> [UInt8]? {
        guard let bytesValue1 = value1.bytesValue,
              let bytesValue2 = value2.bytesValue
        else { return nil }

        return bytesValue1 + bytesValue2
    }
}

// MARK: - Sendable

extension MIDIChannelMessage: Sendable {
}
