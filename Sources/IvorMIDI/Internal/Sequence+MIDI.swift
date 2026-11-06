// © 2026 John Gary Pusey (see LICENSE.md)

extension Sequence<UInt8> {

    // MARK: Internal Instance Properties

    internal var tuningChecksum: UInt8 {
        reduce(0, ^) & 0x7f
    }
}
