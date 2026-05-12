// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension UInt8 {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this byte is a valid SMF
    /// meta-event status byte (0xff).
    public var isMetaEventStatusByte: Bool {
        self == 0xff
    }

    /// A Boolean value indicating whether this byte is a valid SMF MIDI
    /// event status byte.
    public var isMIDIEventStatusByte: Bool {
        [0x80, 0x90, 0xa0, 0xb0, 0xc0, 0xd0, 0xe0].contains(self & 0xf0)
    }

    /// A Boolean value indicating whether this byte is a valid SMF system
    /// exclusive event status byte (0xf0 or 0xf7).
    public var isSysExEventStatusByte: Bool {
        [0xf0, 0xf7].contains(self)
    }
}
