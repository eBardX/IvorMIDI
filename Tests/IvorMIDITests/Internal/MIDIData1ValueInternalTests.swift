// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIData1ValueInternalTests {
}

// MARK: -

extension MIDIData1ValueInternalTests {
    @Test(arguments: [0, 1, 64, 127] as [UInt8])
    func byteValue(value: UInt8) {
        #expect(MIDIData1Value(clamping: value).byteValue == value)
    }
}
