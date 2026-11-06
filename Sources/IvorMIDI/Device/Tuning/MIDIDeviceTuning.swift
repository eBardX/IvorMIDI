// © 2026 John Gary Pusey (see LICENSE.md)

/// A complete tuning that isn’t tied to any device or storage location.
public struct MIDIDeviceTuning {

    // MARK: Public Initializers

    /// Creates a `MIDIDeviceTuning` instance with the provided frequencies and
    /// name, or `nil` if there are not exactly 128 frequencies.
    ///
    /// - Parameter frequencies:    The frequency of each key, from 0 to 127.
    ///                             Must have exactly 128 elements.
    /// - Parameter name:           The name of the tuning, or `nil` if it has
    ///                             none.
    public init?(frequencies: [MIDITuningFrequency],
                 name: String? = nil) {
        guard frequencies.count == 128
        else { return nil }

        self.frequencies = frequencies
        self.name = name
    }

    // MARK: Public Instance Properties

    /// The frequency of each key, from 0 to 127.
    public let frequencies: [MIDITuningFrequency]

    /// The name of the tuning, or `nil` if it has none.
    public let name: String?
}

// MARK: - Hashable

extension MIDIDeviceTuning: Hashable {
}

// MARK: - Sendable

extension MIDIDeviceTuning: Sendable {
}
