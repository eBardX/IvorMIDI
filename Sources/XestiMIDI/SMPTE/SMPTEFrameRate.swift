// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A SMPTE frame rate.
public enum SMPTEFrameRate {

    /// 24 frames per second.
    case fps24

    /// 25 frames per second.
    case fps25

    /// 29.97 frames per second (drop-frame).
    case fps2997

    /// 30 frames per second.
    case fps30
}

// MARK: -

extension SMPTEFrameRate {

    // MARK: Public Instance Properties

    /// The nominal integer frame rate (24, 25, or 30).
    public var uintValue: UInt {
        switch self {
        case .fps24:
            24

        case .fps25:
            25

        case .fps2997, .fps30:
            30
        }
    }
}

// MARK: - Sendable

extension SMPTEFrameRate: Sendable {
}
