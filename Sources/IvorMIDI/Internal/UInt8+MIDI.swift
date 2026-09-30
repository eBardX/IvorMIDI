// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension UInt8 {

    // MARK: Internal Instance Properties

    internal var isMIDIDataByte: Bool {
        (0...0x7f).contains(self)
    }
}
