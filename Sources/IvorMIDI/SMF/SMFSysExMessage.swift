// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An SMF system exclusive message.
public enum SMFSysExMessage {

    /// An escape sequence carrying arbitrary bytes.
    case escape([UInt8])

    /// A system exclusive message.
    case systemExclusive([UInt8])
}

// MARK: -

extension SMFSysExMessage {

    // MARK: Public Initializers

    /// Creates an `SMFSysExMessage` instance from the provided status byte
    /// and data bytes, or `nil` if the status byte does not identify a
    /// system exclusive message.
    ///
    /// - Parameter statusByte: The status byte. Must be 0xf0 or 0xf7.
    /// - Parameter dataBytes:  The data bytes.
    public init?(statusByte: UInt8,
                 dataBytes: [UInt8]) {
        switch statusByte {
        case 0xf0:
            self = .systemExclusive(dataBytes)

        case 0xf7:
            self = .escape(dataBytes)

        default:
            return nil
        }
    }

    // MARK: Public Instance Properties

    /// The data bytes of this message, or `nil` if the message cannot be
    /// encoded.
    public var dataBytes: [UInt8]? {
        switch self {
        case let .escape(dataBytes),
             let .systemExclusive(dataBytes):
            dataBytes
        }
    }

    /// The status byte of this message, or `nil` if the message cannot be
    /// encoded.
    public var statusByte: UInt8? {
        switch self {
        case .escape:
            0xf7

        case .systemExclusive:
            0xf0
        }
    }
}

// MARK: - Sendable

extension SMFSysExMessage: Sendable {
}
