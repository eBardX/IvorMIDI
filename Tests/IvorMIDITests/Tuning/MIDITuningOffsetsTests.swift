// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDITuningOffsetsTests {
    private let coarse = MIDITuningOffsets.coarse((0..<12).map { MIDIData1Value(clamping: 58 + $0) })
    private let fine = MIDITuningOffsets.fine((0..<12).map { MIDIData2Value(clamping: 8_000 + $0 * 37) })
}

// MARK: -

extension MIDITuningOffsetsTests {
    @Test
    func bytesValue_coarse() {
        #expect(coarse.bytesValue == [0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45])
    }

    @Test
    func bytesValue_fine_msbFirst() {
        let offsets = [MIDIData2Value](repeating: 8_192, count: 11) + [1]
        let expected = [[UInt8]](repeating: [0x40, 0x00], count: 11).flatMap(\.self) + [0x00, 0x01]

        #expect(MIDITuningOffsets.fine(offsets).bytesValue == expected)
    }

    @Test
    func bytesValue_wrongCount() {
        #expect(MIDITuningOffsets.coarse([]).bytesValue == nil)
        #expect(MIDITuningOffsets.coarse([0x40]).bytesValue == nil)
        #expect(MIDITuningOffsets.coarse([MIDIData1Value](repeating: 0x40, count: 13)).bytesValue == nil)
        #expect(MIDITuningOffsets.fine([]).bytesValue == nil)
        #expect(MIDITuningOffsets.fine([8_192]).bytesValue == nil)
        #expect(MIDITuningOffsets.fine([MIDIData2Value](repeating: 8_192, count: 13)).bytesValue == nil)
    }

    @Test
    func codable() throws {
        for original in [coarse, fine] {
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(MIDITuningOffsets.self,
                                                   from: data)

            #expect(decoded == original)
        }
    }

    @Test
    func hashable() {
        #expect(Set([coarse, coarse, fine]).count == 2)
    }

    @Test
    func inequality_formatsDiffer() {
        #expect(MIDITuningOffsets.coarse([0x40]) != MIDITuningOffsets.fine([0x40]))
    }

    @Test
    func init_bytesValue_coarse() {
        #expect(MIDITuningOffsets(bytesValue: coarse.bytesValue ?? []) == coarse)
    }

    @Test
    func init_bytesValue_fine() {
        #expect(MIDITuningOffsets(bytesValue: fine.bytesValue ?? []) == fine)
    }

    @Test
    func init_bytesValue_fine_msbFirst() {
        let bytes = [[UInt8]](repeating: [0x40, 0x00], count: 11).flatMap(\.self) + [0x00, 0x01]
        let offsets = [MIDIData2Value](repeating: 8_192, count: 11) + [1]

        #expect(MIDITuningOffsets(bytesValue: bytes) == .fine(offsets))
    }

    @Test(arguments: [0, 11, 13, 23, 25])
    func init_bytesValue_invalidCount(count: Int) {
        #expect(MIDITuningOffsets(bytesValue: [UInt8](repeating: 0x40, count: count)) == nil)
    }

    @Test
    func init_bytesValue_notDataBytes() {
        #expect(MIDITuningOffsets(bytesValue: [UInt8](repeating: 0x80, count: 12)) == nil)
        #expect(MIDITuningOffsets(bytesValue: [UInt8](repeating: 0x40, count: 23) + [0x80]) == nil)
    }

    @Test
    func isFine() {
        #expect(!coarse.isFine)
        #expect(fine.isFine)
    }
}
