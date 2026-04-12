// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct UInt8MIDITests {
}

// MARK: -

extension UInt8MIDITests {
    @Test
    func test_isMIDIDataByte() {
        #expect(UInt8(0x00).isMIDIDataByte)
        #expect(UInt8(0x3C).isMIDIDataByte)
        #expect(UInt8(0x7F).isMIDIDataByte)
        #expect(!UInt8(0x80).isMIDIDataByte)
        #expect(!UInt8(0xFF).isMIDIDataByte)
    }

    @Test
    func test_isMIDIStatusByte() {
        #expect(!UInt8(0x00).isMIDIStatusByte)
        #expect(!UInt8(0x7F).isMIDIStatusByte)
        #expect(UInt8(0x80).isMIDIStatusByte)
        #expect(UInt8(0x90).isMIDIStatusByte)
        #expect(UInt8(0xFF).isMIDIStatusByte)
    }
}
