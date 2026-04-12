// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct UInt8SMFTests {
}

// MARK: -

extension UInt8SMFTests {
    @Test
    func test_isMetaEventStatusByte() {
        #expect(UInt8(0xFF).isMetaEventStatusByte)
        #expect(!UInt8(0xFE).isMetaEventStatusByte)
        #expect(!UInt8(0x00).isMetaEventStatusByte)
        #expect(!UInt8(0xF0).isMetaEventStatusByte)
    }

    @Test
    func test_isMIDIEventStatusByte() {
        #expect(UInt8(0x80).isMIDIEventStatusByte)
        #expect(UInt8(0x90).isMIDIEventStatusByte)
        #expect(UInt8(0xA0).isMIDIEventStatusByte)
        #expect(UInt8(0xB0).isMIDIEventStatusByte)
        #expect(UInt8(0xC0).isMIDIEventStatusByte)
        #expect(UInt8(0xD0).isMIDIEventStatusByte)
        #expect(UInt8(0xE0).isMIDIEventStatusByte)
        #expect(!UInt8(0xF0).isMIDIEventStatusByte)
        #expect(!UInt8(0x70).isMIDIEventStatusByte)
        #expect(!UInt8(0xFF).isMIDIEventStatusByte)

        #expect(UInt8(0x93).isMIDIEventStatusByte)
        #expect(UInt8(0xBF).isMIDIEventStatusByte)
    }

    @Test
    func test_isSysExEventStatusByte() {
        #expect(UInt8(0xF0).isSysExEventStatusByte)
        #expect(UInt8(0xF7).isSysExEventStatusByte)
        #expect(!UInt8(0xF1).isSysExEventStatusByte)
        #expect(!UInt8(0xFF).isSysExEventStatusByte)
        #expect(!UInt8(0x00).isSysExEventStatusByte)
    }
}
