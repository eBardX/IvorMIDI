// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A SMPTE timecode specification used as an SMF time division, combining a
/// frame rate and a tick resolution.
public struct SMPTETimeCode {

    // MARK: Public Initializers

    /// Creates a new `SMPTETimeCode` instance with the provided frame rate and
    /// tick rate, or `nil` if the tick rate is out of range.
    ///
    /// - Parameter frameRate:  The SMPTE frame rate.
    /// - Parameter tickRate:   The number of ticks per frame (0–255).
    public init?(frameRate: SMPTEFrameRate,
                 tickRate: UInt) {
        guard (0...255).contains(tickRate)
        else { return nil }

        self.frameRate = frameRate
        self.tickRate = tickRate
    }

    // MARK: Public Instance Properties

    /// The SMPTE frame rate.
    public let frameRate: SMPTEFrameRate

    /// The number of ticks per frame.
    public let tickRate: UInt
}

// MARK: - BytesValueConvertible

extension SMPTETimeCode: BytesValueConvertible {

    // MARK: Public Initializers

    /// Creates an `SMPTETimeCode` instance from the provided array of bytes, or
    /// `nil` if the bytes do not represent a valid SMPTE timecode
    /// specification.
    ///
    /// - Parameter bytesValue: The array of bytes. Must contain exactly two
    ///                         bytes: the encoded frame rate byte and the tick
    ///                         rate byte.
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2,
              let frameRate = Self._convertToFrameRate(bytesValue[0])
        else { return nil }

        self.init(frameRate: frameRate,
                  tickRate: UInt(bytesValue[1]))
    }

    // MARK: Public Instance Properties

    /// The array of two bytes representing this SMPTE timecode
    /// specification, or `nil` if the value cannot be encoded.
    public var bytesValue: [UInt8]? {
        guard let byte0Value = Self._convertToByteValue(frameRate),
              let byte1Value = UInt8(exactly: tickRate)
        else { return nil }

        return [byte0Value, byte1Value]
    }

    // MARK: Private Type Methods

    private static func _convertToByteValue(_ frameRate: SMPTEFrameRate) -> UInt8? {
        switch frameRate {
        case .fps24:
            0xe8

        case .fps25:
            0xe7

        case .fps2997:
            0xe3

        case .fps30:
            0xe2
        }
    }

    private static func _convertToFrameRate(_ byteValue: UInt8) -> SMPTEFrameRate? {
        switch byteValue {
        case 0xe8:
            .fps24

        case 0xe7:
            .fps25

        case 0xe3:
            .fps2997

        case 0xe2:
            .fps30

        default:
            nil
        }
    }
}

// MARK: - Equatable

extension SMPTETimeCode: Equatable {
}

// MARK: - Hashable

extension SMPTETimeCode: Hashable {
}

// MARK: - Sendable

extension SMPTETimeCode: Sendable {
}
