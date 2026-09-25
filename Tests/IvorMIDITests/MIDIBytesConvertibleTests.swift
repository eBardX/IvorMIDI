// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIBytesConvertibleTests {
}

// MARK: -

extension MIDIBytesConvertibleTests {
    @Test
    func roundTrip() throws {
        let values: [any MIDIBytesConvertible] = [16 as MIDIChannel,
                                                  64 as MIDIController,
                                                  127 as MIDIData1Value,
                                                  16_383 as MIDIData2Value,
                                                  -8_192 as MIDIPitchBend]

        for value in values {
            let bytes = try #require(value.bytesValue)
            let decoded = try #require(type(of: value).init(bytesValue: bytes))

            #expect(decoded.bytesValue == bytes)
        }
    }
}
