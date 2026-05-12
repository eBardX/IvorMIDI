// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct UInt8SMFTests {
}

// MARK: -

extension UInt8SMFTests {
    @Test
    func isMIDIEventStatusByte() {
        #expect(UInt8(0x80).isMIDIEventStatusByte)
        #expect(UInt8(0x90).isMIDIEventStatusByte)
        #expect(UInt8(0xa0).isMIDIEventStatusByte)
        #expect(UInt8(0xb0).isMIDIEventStatusByte)
        #expect(UInt8(0xc0).isMIDIEventStatusByte)
        #expect(UInt8(0xd0).isMIDIEventStatusByte)
        #expect(UInt8(0xe0).isMIDIEventStatusByte)
        #expect(!UInt8(0xf0).isMIDIEventStatusByte)
        #expect(!UInt8(0x70).isMIDIEventStatusByte)
        #expect(!UInt8(0xff).isMIDIEventStatusByte)

        #expect(UInt8(0x93).isMIDIEventStatusByte)
        #expect(UInt8(0xbf).isMIDIEventStatusByte)
    }

    @Test
    func isMetaEventStatusByte() {
        #expect(UInt8(0xff).isMetaEventStatusByte)
        #expect(!UInt8(0xfe).isMetaEventStatusByte)
        #expect(!UInt8(0x00).isMetaEventStatusByte)
        #expect(!UInt8(0xf0).isMetaEventStatusByte)
    }

    @Test
    func isSysExEventStatusByte() {
        #expect(UInt8(0xf0).isSysExEventStatusByte)
        #expect(UInt8(0xf7).isSysExEventStatusByte)
        #expect(!UInt8(0xf1).isSysExEventStatusByte)
        #expect(!UInt8(0xff).isSysExEventStatusByte)
        #expect(!UInt8(0x00).isSysExEventStatusByte)
    }
}
