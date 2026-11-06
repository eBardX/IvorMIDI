// © 2026 John Gary Pusey (see LICENSE.md)

/// What a device can store in a tuning.
public struct MIDITuningLimits {

    // MARK: Public Initializers

    /// Creates a `MIDITuningLimits` instance with the provided values.
    ///
    /// - Parameter maximumNameLength:  The longest name the device stores, or
    ///                                 0 if it doesn’t store names.
    /// - Parameter resolutionInCents:  The smallest step in pitch, in cents.
    /// - Parameter soundingKeys:       The keys that the device can retune.
    /// - Parameter supportsNoChange:   Whether the device can leave a key’s
    ///                                 tuning as it is, using
    ///                                 ``MIDITuningFrequency/noChange``.
    public init(maximumNameLength: Int,
                resolutionInCents: Double,
                soundingKeys: ClosedRange<Int>,
                supportsNoChange: Bool) {
        self.maximumNameLength = maximumNameLength
        self.resolutionInCents = resolutionInCents
        self.soundingKeys = soundingKeys
        self.supportsNoChange = supportsNoChange
    }

    // MARK: Public Instance Properties

    /// The longest name the device stores, or 0 if it doesn’t store names.
    public let maximumNameLength: Int

    /// The smallest step in pitch, in cents.
    public let resolutionInCents: Double

    /// The keys that the device can retune.
    public let soundingKeys: ClosedRange<Int>

    /// A Boolean value indicating whether the device can leave a key’s tuning
    /// as it is, using ``MIDITuningFrequency/noChange``.
    public let supportsNoChange: Bool
}

// MARK: - Hashable

extension MIDITuningLimits: Hashable {
}

// MARK: - Sendable

extension MIDITuningLimits: Sendable {
}
