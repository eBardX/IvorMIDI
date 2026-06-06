// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A musical key signature as stored in an SMF file.
public enum SMFKeySignature {

    /// The key of A-flat major.
    case aFlatMajor

    /// The key of A-flat minor.
    case aFlatMinor

    /// The key of A major.
    case aMajor

    /// The key of A minor.
    case aMinor

    /// The key of A-sharp minor.
    case aSharpMinor

    /// The key of B-flat major.
    case bFlatMajor

    /// The key of B-flat minor.
    case bFlatMinor

    /// The key of B major.
    case bMajor

    /// The key of B minor.
    case bMinor

    /// The key of C-flat major.
    case cFlatMajor

    /// The key of C major.
    case cMajor

    /// The key of C minor.
    case cMinor

    /// The key of C-sharp major.
    case cSharpMajor

    /// The key of C-sharp minor.
    case cSharpMinor

    /// The key of D-flat major.
    case dFlatMajor

    /// The key of D major.
    case dMajor

    /// The key of D minor.
    case dMinor

    /// The key of D-sharp minor.
    case dSharpMinor

    /// The key of E-flat major.
    case eFlatMajor

    /// The key of E-flat minor.
    case eFlatMinor

    /// The key of E major.
    case eMajor

    /// The key of E minor.
    case eMinor

    /// The key of F major.
    case fMajor

    /// The key of F minor.
    case fMinor

    /// The key of F-sharp major.
    case fSharpMajor

    /// The key of F-sharp minor.
    case fSharpMinor

    /// The key of G-flat major.
    case gFlatMajor

    /// The key of G major.
    case gMajor

    /// The key of G minor.
    case gMinor

    /// The key of G-sharp minor.
    case gSharpMinor
}

// MARK: - BytesValueConvertible

extension SMFKeySignature: BytesValueConvertible {

    // MARK: Public Initializers

    /// Creates an `SMFKeySignature` instance from the provided array of
    /// bytes, or `nil` if the bytes do not represent a recognized key
    /// signature.
    ///
    /// - Parameter bytesValue: The array of bytes. Must contain exactly two
    ///                         bytes: the key byte and the mode byte (0 for
    ///                         major, 1 for minor).
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2
        else { return nil }

        switch (bytesValue[0], bytesValue[1]) {
        case (0x00, 0x00):
            self = .cMajor

        case (0x00, 0x01):
            self = .aMinor

        case (0x01, 0x00):
            self = .gMajor

        case (0x01, 0x01):
            self = .eMinor

        case (0x02, 0x00):
            self = .dMajor

        case (0x02, 0x01):
            self = .bMinor

        case (0x03, 0x00):
            self = .aMajor

        case (0x03, 0x01):
            self = .fSharpMinor

        case (0x04, 0x00):
            self = .eMajor

        case (0x04, 0x01):
            self = .cSharpMinor

        case (0x05, 0x00):
            self = .bMajor

        case (0x05, 0x01):
            self = .gSharpMinor

        case (0x06, 0x00):
            self = .fSharpMajor

        case (0x06, 0x01):
            self = .dSharpMinor

        case (0x07, 0x00):
            self = .cSharpMajor

        case (0x07, 0x01):
            self = .aSharpMinor

        case (0xf9, 0x00):
            self = .cFlatMajor

        case (0xf9, 0x01):
            self = .aFlatMinor

        case (0xfa, 0x00):
            self = .gFlatMajor

        case (0xfa, 0x01):
            self = .eFlatMinor

        case (0xfb, 0x00):
            self = .dFlatMajor

        case (0xfb, 0x01):
            self = .bFlatMinor

        case (0xfc, 0x00):
            self = .aFlatMajor

        case (0xfc, 0x01):
            self = .fMinor

        case (0xfd, 0x00):
            self = .eFlatMajor

        case (0xfd, 0x01):
            self = .cMinor

        case (0xfe, 0x00):
            self = .bFlatMajor

        case (0xfe, 0x01):
            self = .gMinor

        case (0xff, 0x00):
            self = .fMajor

        case (0xff, 0x01):
            self = .dMinor

        default:
            return nil
        }
    }

    // MARK: Public Instance Properties

    /// The array of two bytes representing this key signature, or `nil` if
    /// the key signature cannot be encoded.
    public var bytesValue: [UInt8]? {
        switch self {
        case .aFlatMajor:
            [0xfc, 0x00]

        case .aFlatMinor:
            [0xf9, 0x01]

        case .aMajor:
            [0x03, 0x00]

        case .aMinor:
            [0x00, 0x01]

        case .aSharpMinor:
            [0x07, 0x01]

        case .bFlatMajor:
            [0xfe, 0x00]

        case .bFlatMinor:
            [0xfb, 0x01]

        case .bMajor:
            [0x05, 0x00]

        case .bMinor:
            [0x02, 0x01]

        case .cFlatMajor:
            [0xf9, 0x00]

        case .cMajor:
            [0x00, 0x00]

        case .cMinor:
            [0xfd, 0x01]

        case .cSharpMajor:
            [0x07, 0x00]

        case .cSharpMinor:
            [0x04, 0x01]

        case .dFlatMajor:
            [0xfb, 0x00]

        case .dMajor:
            [0x02, 0x00]

        case .dMinor:
            [0xff, 0x01]

        case .dSharpMinor:
            [0x06, 0x01]

        case .eFlatMajor:
            [0xfd, 0x00]

        case .eFlatMinor:
            [0xfa, 0x01]

        case .eMajor:
            [0x04, 0x00]

        case .eMinor:
            [0x01, 0x01]

        case .fMajor:
            [0xff, 0x00]

        case .fMinor:
            [0xfc, 0x01]

        case .fSharpMajor:
            [0x06, 0x00]

        case .fSharpMinor:
            [0x03, 0x01]

        case .gFlatMajor:
            [0xfa, 0x00]

        case .gMajor:
            [0x01, 0x00]

        case .gMinor:
            [0xfe, 0x01]

        case .gSharpMinor:
            [0x05, 0x01]
        }
    }
}

// MARK: - Equatable

extension SMFKeySignature: Equatable {
}

// MARK: - Hashable

extension SMFKeySignature: Hashable {
}

// MARK: - Sendable

extension SMFKeySignature: Sendable {
}
