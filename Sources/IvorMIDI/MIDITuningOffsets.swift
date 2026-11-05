// © 2026 John Gary Pusey (see LICENSE.md)

/// The tuning offsets of the 12 notes of the octave, from C to B.
///
/// These are the two scale/octave formats of the *MIDI Tuning Messages*
/// specification (“MIDI Tuning Scale/Octave Extensions”, CA-021). Each offset
/// is measured from the selected preset, or from equal temperament if there is
/// none. A message only accepts offsets with exactly 12 elements.
public enum MIDITuningOffsets {

    /// Offsets in the 1-byte format, from −64 cents (0) through equal
    /// temperament (64) to +63 cents (127).
    case coarse([MIDIData1Value])

    /// Offsets in the 2-byte format, in steps of about 0.012 cents, from −100
    /// cents (0) through equal temperament (8192) to +100 × 8191/8192 cents
    /// (16383).
    case fine([MIDIData2Value])
}

// MARK: -

extension MIDITuningOffsets {

    // MARK: Internal Instance Properties

    internal var isFine: Bool {
        switch self {
        case .coarse:
            false

        case .fine:
            true
        }
    }
}

// MARK: - Codable

extension MIDITuningOffsets: Codable {
}

// MARK: - Hashable

extension MIDITuningOffsets: Hashable {
}

// MARK: - MIDIBytesConvertible

extension MIDITuningOffsets: MIDIBytesConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDITuningOffsets` instance from its MIDI wire encoding, or
    /// `nil` if the bytes do not encode valid offsets.
    ///
    /// - Parameter bytesValue: 12 7-bit data bytes for the 1-byte format, or
    ///                         24 for the 2-byte format, with the most
    ///                         significant 7 bits of each offset first.
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.allSatisfy(\.isMIDIDataByte)
        else { return nil }

        switch bytesValue.count {
        case 12:
            self = .coarse(bytesValue.map { MIDIData1Value(clamping: $0) })

        case 24:
            self = .fine(stride(from: 0, to: 24, by: 2).map {
                MIDIData2Value(msb: MIDIData1Value(clamping: bytesValue[$0]),
                               lsb: MIDIData1Value(clamping: bytesValue[$0 + 1]))
            })

        default:
            return nil
        }
    }

    // MARK: Public Instance Properties

    /// The MIDI wire encoding of these offsets: 12 7-bit data bytes for the
    /// 1-byte format, or 24 for the 2-byte format, with the most significant
    /// 7 bits of each offset first. This is `nil` if there are not exactly 12
    /// offsets.
    public var bytesValue: [UInt8]? {
        switch self {
        case let .coarse(offsets):
            guard offsets.count == 12
            else { return nil }

            return offsets.map { MIDISystemMessage.byte($0) }

        case let .fine(offsets):
            guard offsets.count == 12
            else { return nil }

            return offsets.flatMap { [MIDISystemMessage.byte($0.msb), MIDISystemMessage.byte($0.lsb)] }
        }
    }
}

// MARK: - Sendable

extension MIDITuningOffsets: Sendable {
}
