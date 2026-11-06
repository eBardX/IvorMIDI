// © 2026 John Gary Pusey (see LICENSE.md)

// The two editable tuning tables of a TX81Z.
internal enum TX81ZTuningTable {
    case fullKeyboard
    case octave

    // MARK: Internal Initializers

    internal init?(slot: MIDITuningSlot) {
        switch slot {
        case .tx81zFullKeyboard:
            self = .fullKeyboard

        case .tx81zOctave:
            self = .octave

        default:
            return nil
        }
    }

    internal init?(tagBytes: some Sequence<UInt8>) {
        let bytes = Array(tagBytes)

        guard let table = Self.allCases.first(where: { $0.tagBytes == bytes })
        else { return nil }

        self = table
    }
}

// MARK: -

extension TX81ZTuningTable {

    // MARK: Internal Instance Properties

    internal var entryCount: Int {
        switch self {
        case .fullKeyboard:
            128

        case .octave:
            12
        }
    }

    internal var slot: MIDITuningSlot {
        switch self {
        case .fullKeyboard:
            .tx81zFullKeyboard

        case .octave:
            .tx81zOctave
        }
    }

    internal var tagBytes: [UInt8] {
        switch self {
        case .fullKeyboard:
            Array("LM  MCRTE1".utf8)

        case .octave:
            Array("LM  MCRTE0".utf8)
        }
    }
}

// MARK: - CaseIterable

extension TX81ZTuningTable: CaseIterable {
}

// MARK: - Codable

extension TX81ZTuningTable: Codable {
}

// MARK: - Hashable

extension TX81ZTuningTable: Hashable {
}

// MARK: - Sendable

extension TX81ZTuningTable: Sendable {
}
