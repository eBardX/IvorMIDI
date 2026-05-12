// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension UInt8 {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this byte is a valid MIDI data
    /// byte (0x00–0x7f).
    public var isMIDIDataByte: Bool {
        (0...0x7f).contains(self)
    }

    /// A Boolean value indicating whether this byte is a valid MIDI status
    /// byte (0x80–0xff).
    public var isMIDIStatusByte: Bool {
        (0x80...0xff).contains(self)
    }
}
