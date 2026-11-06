// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

/// The identity of a universal system exclusive message: its header type and
/// its sub-ID#1.
///
/// These two values are held together because the meaning of a sub-ID depends
/// on the header. For example, sub-ID 0x04 is MIDI Time Code under a
/// non-real-time header (0x7E), but Device Control under a real-time header
/// (0x7F).
///
/// A sub-ID#2 is not part of this value, because not every universal message
/// has one. It is the first byte of the payload of a message that does.
public struct MIDISysExUniversalID {

    // MARK: Public Initializers

    /// Creates a `MIDISysExUniversalID` instance with the provided header type
    /// and sub-ID#1.
    ///
    /// - Parameter realTime:   `true` for a real-time message (0x7F); `false`
    ///                         for a non-real-time message (0x7E).
    /// - Parameter subID:      The sub-ID#1.
    public init(realTime: Bool,
                subID: MIDIData1Value) {
        self.realTime = realTime
        self.subID = subID
    }

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this is a real-time message (0x7F)
    /// rather than a non-real-time message (0x7E).
    public let realTime: Bool

    /// The sub-ID#1.
    public let subID: MIDIData1Value
}

// MARK: -

extension MIDISysExUniversalID {

    // MARK: Public Type Properties

    /// The ID of the real-time Device Control messages (0x7F 0x04).
    public static let deviceControl = Self(realTime: true,
                                           subID: 0x04)

    /// The ID of the non-real-time General Information messages (0x7E 0x06),
    /// which include Identity Request and Identity Reply.
    public static let generalInformation = Self(realTime: false,
                                                subID: 0x06)

    /// The ID of the non-real-time General MIDI messages (0x7E 0x09).
    public static let generalMIDI = Self(realTime: false,
                                         subID: 0x09)

    /// The ID of the real-time MIDI Tuning messages (0x7F 0x08).
    public static let realTimeTuning = Self(realTime: true,
                                            subID: 0x08)

    /// The ID of the non-real-time MIDI Tuning messages (0x7E 0x08).
    public static let tuning = Self(realTime: false,
                                    subID: 0x08)
}

// MARK: - Codable

extension MIDISysExUniversalID: Codable {
}

// MARK: - Hashable

extension MIDISysExUniversalID: Hashable {
}

// MARK: - Sendable

extension MIDISysExUniversalID: Sendable {
}
