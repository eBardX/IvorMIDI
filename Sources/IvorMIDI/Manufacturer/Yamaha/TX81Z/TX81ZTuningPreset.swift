// © 2026 John Gary Pusey (see LICENSE.md)

/// A preset tuning of a TX81Z.
///
/// The raw values are the numbers on p.31 of the owner’s manual.
public enum TX81ZTuningPreset: UInt8 {

    /// The 1/8 Tone preset (11).
    case eighthTone = 11

    /// The Equal preset (1).
    case equal = 1

    /// The Kirnberger preset (7).
    case kirnberger = 7

    /// The Mean tone preset (4).
    case meanTone = 4

    /// The Pure (major) preset (2).
    case pureMajor = 2

    /// The Pure (minor) preset (3).
    case pureMinor = 3

    /// The Pythagorean preset (5).
    case pythagorean = 5

    /// The 1/4 Shift eql preset (9).
    case quarterShift = 9

    /// The 1/4 Tone preset (10).
    case quarterTone = 10

    /// The Vallotti & Young preset (8).
    case vallottiYoung = 8

    /// The Werckmeister preset (6).
    case werckmeister = 6
}

// MARK: -

extension TX81ZTuningPreset {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this preset uses the Micro Tune Key
    /// parameter, which applies to presets 2–5 only.
    public var usesKey: Bool {
        (2...5).contains(rawValue)
    }
}

// MARK: - CaseIterable

extension TX81ZTuningPreset: CaseIterable {
}

// MARK: - Codable

extension TX81ZTuningPreset: Codable {
}

// MARK: - Hashable

extension TX81ZTuningPreset: Hashable {
}

// MARK: - Sendable

extension TX81ZTuningPreset: Sendable {
}
