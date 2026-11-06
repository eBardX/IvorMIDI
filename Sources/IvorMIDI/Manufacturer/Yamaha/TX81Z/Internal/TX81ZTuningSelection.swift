// © 2026 John Gary Pusey (see LICENSE.md)

// A value of Performance parameter 96, Micro Tune Table: 0 for the octave table,
// 1 for the full keyboard table, then 2–12 for presets 1–11.
internal enum TX81ZTuningSelection {
    case preset(TX81ZTuningPreset)
    case table(TX81ZTuningTable)

    // MARK: Internal Initializers

    internal init?(dataByte: UInt8) {
        switch dataByte {
        case 0:
            self = .table(.octave)

        case 1:
            self = .table(.fullKeyboard)

        default:
            guard let preset = TX81ZTuningPreset(rawValue: dataByte &- 1)
            else { return nil }

            self = .preset(preset)
        }
    }
}

// MARK: -

extension TX81ZTuningSelection {

    // MARK: Internal Instance Properties

    internal var dataByte: UInt8 {
        switch self {
        case let .preset(preset):
            preset.rawValue + 1

        case .table(.fullKeyboard):
            1

        case .table(.octave):
            0
        }
    }
}

// MARK: - Codable

extension TX81ZTuningSelection: Codable {
}

// MARK: - Hashable

extension TX81ZTuningSelection: Hashable {
}

// MARK: - Sendable

extension TX81ZTuningSelection: Sendable {
}
