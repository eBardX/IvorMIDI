// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDIData1Value {

    // MARK: Internal Instance Properties

    internal var byteValue: UInt8 {
        UInt8(truncatingIfNeeded: uintValue)
    }
}
