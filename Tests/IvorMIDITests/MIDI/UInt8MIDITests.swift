// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct UInt8MIDITests {
}

// MARK: -

extension UInt8MIDITests {
    @Test
    func isMIDIDataByte() {
        #expect(UInt8(0x00).isMIDIDataByte)
        #expect(UInt8(0x3c).isMIDIDataByte)
        #expect(UInt8(0x7f).isMIDIDataByte)
        #expect(!UInt8(0x80).isMIDIDataByte)
        #expect(!UInt8(0xff).isMIDIDataByte)
    }

    @Test
    func isMIDIStatusByte() {
        #expect(!UInt8(0x00).isMIDIStatusByte)
        #expect(!UInt8(0x7f).isMIDIStatusByte)
        #expect(UInt8(0x80).isMIDIStatusByte)
        #expect(UInt8(0x90).isMIDIStatusByte)
        #expect(UInt8(0xff).isMIDIStatusByte)
    }
}
