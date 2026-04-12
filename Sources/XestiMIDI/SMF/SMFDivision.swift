// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// The time division of an SMF sequence, specifying how event times are
/// measured.
public enum SMFDivision {

    /// Metrical (tick-based) time division, measured in ticks per quarter
    /// note.
    case metrical(SMFTickRate)

    /// SMPTE time code-based time division.
    case timeCode(SMPTETimeCode)
}

// MARK: - BytesValueConvertible

extension SMFDivision: BytesValueConvertible {

    // MARK: Public Initializers

    /// Creates an `SMFDivision` instance from the provided array of bytes,
    /// or `nil` if the bytes do not represent a valid time division.
    ///
    /// - Parameter bytesValue: The array of bytes. Must contain exactly two
    ///                         bytes.
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2
        else { return nil }

        if (bytesValue[0] & 0x80) == 0 {
            guard let tickRate = SMFTickRate(bytesValue: bytesValue)
            else { return nil }

            self = .metrical(tickRate)
        } else {
            guard let timeCode = SMPTETimeCode(bytesValue: bytesValue)
            else { return nil }

            self = .timeCode(timeCode)
        }
    }

    // MARK: Public Instance Properties

    /// The array of two bytes representing this time division, or `nil` if
    /// the division cannot be encoded.
    public var bytesValue: [UInt8]? {
        switch self {
        case let .metrical(tickRate):
            tickRate.bytesValue

        case let .timeCode(timeCode):
            timeCode.bytesValue
        }
    }
}

// MARK: - Sendable

extension SMFDivision: Sendable {
}
