// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct TX81ZPitchTests {
}

// MARK: -

extension TX81ZPitchTests {
    @Test
    func bytesValue() {
        #expect(TX81ZPitch(note: 69, fraction: 63)?.bytesValue == [69, 63])
    }

    @Test
    func codable() throws {
        let original: TX81ZPitch = 3_000
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TX81ZPitch.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("6144".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TX81ZPitch.self,
                                     from: data)
        }
    }

    @Test
    func constants() {
        #expect(TX81ZPitch.lowest.bytesValue == [13, 0])
        #expect(TX81ZPitch.highest.bytesValue == [108, 63])
    }

    @Test
    func fraction_notSignExtended() throws {
        let pitch = try #require(TX81ZPitch(note: 69, fraction: 63))

        #expect(pitch.semitones == 69 + 63.0 / 64)
    }

    @Test
    func frequency() throws {
        let pitch = try #require(TX81ZPitch(note: 69, fraction: 1))

        #expect(pitch.frequency == MIDITuningFrequency(semitone: 69, fraction: 256))
    }

    @Test
    func frequency_roundTripIsLossless() throws {
        for value in UInt(0)...6_143 {
            let pitch = try #require(TX81ZPitch(uintValue: value))

            #expect(TX81ZPitch(frequency: pitch.frequency) == pitch)
        }
    }

    @Test
    func init_bytesValue() {
        #expect(TX81ZPitch(bytesValue: [13, 0]) == .lowest)
        #expect(TX81ZPitch(bytesValue: [108, 63]) == .highest)
    }

    @Test(arguments: [[], [69], [69, 0, 0], [12, 0], [109, 0], [69, 64], [0x80, 0]] as [[UInt8]])
    func init_bytesValue_invalid(bytes: [UInt8]) {
        #expect(TX81ZPitch(bytesValue: bytes) == nil)
    }

    @Test
    func init_clampingFrequency() {
        #expect(TX81ZPitch(clamping: MIDITuningFrequency(semitone: 0)) == .lowest)
        #expect(TX81ZPitch(clamping: MIDITuningFrequency(semitone: 127)) == .highest)
        #expect(TX81ZPitch(clamping: MIDITuningFrequency(semitone: 69))?.bytesValue == [69, 0])
    }

    @Test
    func init_clampingFrequency_noChange() {
        #expect(TX81ZPitch(clamping: MIDITuningFrequency.noChange) == nil)
    }

    @Test
    func init_clampingSemitones() {
        #expect(TX81ZPitch(clampingSemitones: 12) == .lowest)
        #expect(TX81ZPitch(clampingSemitones: 109) == .highest)
        #expect(TX81ZPitch(clampingSemitones: 208.5) == .highest)
        #expect(TX81ZPitch(clampingSemitones: 69)?.bytesValue == [69, 0])
    }

    @Test(arguments: [Double.infinity, -Double.infinity, 1e300, -1e300])
    func init_clampingSemitones_extremeValuesDoNotTrap(value: Double) {
        #expect(TX81ZPitch(clampingSemitones: value) == (value > 0 ? .highest : .lowest))
    }

    @Test
    func init_clampingSemitones_nan() {
        #expect(TX81ZPitch(clampingSemitones: .nan) == nil)
    }

    @Test
    func init_frequency() {
        #expect(TX81ZPitch(frequency: MIDITuningFrequency(semitone: 69))?.bytesValue == [69, 0])
    }

    @Test
    func init_frequency_noChange() {
        #expect(TX81ZPitch(frequency: MIDITuningFrequency.noChange) == nil)
    }

    @Test
    func init_frequency_outOfRange() {
        #expect(TX81ZPitch(frequency: MIDITuningFrequency(semitone: 12)) == nil)
        #expect(TX81ZPitch(frequency: MIDITuningFrequency(semitone: 109)) == nil)
    }

    @Test
    func init_frequency_rounds() {
        #expect(TX81ZPitch(frequency: MIDITuningFrequency(semitone: 69, fraction: 127))?.bytesValue == [69, 0])
        #expect(TX81ZPitch(frequency: MIDITuningFrequency(semitone: 69, fraction: 128))?.bytesValue == [69, 1])
    }

    @Test
    func init_note() {
        #expect(TX81ZPitch(note: 13) == .lowest)
        #expect(TX81ZPitch(note: 108, fraction: 63) == .highest)
    }

    @Test
    func init_note_invalid() {
        #expect(TX81ZPitch(note: 12) == nil)
        #expect(TX81ZPitch(note: 109) == nil)
        #expect(TX81ZPitch(note: 69, fraction: 64) == nil)
    }

    @Test
    func init_semitones() {
        #expect(TX81ZPitch(semitones: 13) == .lowest)
        #expect(TX81ZPitch(semitones: 108 + 63.0 / 64) == .highest)
    }

    @Test
    func init_semitones_carriesIntoNote() {
        // Key 59 of 15-tET lands on 61,0.
        #expect(TX81ZPitch(semitones: 69 + (59 - 69) * 12.0 / 15)?.bytesValue == [61, 0])
        #expect(TX81ZPitch(semitones: 60.999)?.bytesValue == [61, 0])
    }

    @Test
    func init_semitones_halfRoundsUp() {
        #expect(TX81ZPitch(semitones: 69 + 0.5 / 64)?.bytesValue == [69, 1])
    }

    @Test(arguments: [Double.nan, .infinity, -.infinity, 1e300, -1e300, 12, 109])
    func init_semitones_invalid(value: Double) {
        #expect(TX81ZPitch(semitones: value) == nil)
    }

    @Test
    func init_uintValue() {
        #expect(TX81ZPitch(uintValue: 0) == .lowest)
        #expect(TX81ZPitch(uintValue: 6_143) == .highest)
        #expect(TX81ZPitch(uintValue: 6_144) == nil)
    }

    @Test
    func isValid() {
        #expect(TX81ZPitch.isValid(0))
        #expect(TX81ZPitch.isValid(6_143))
        #expect(!TX81ZPitch.isValid(6_144))
    }

    @Test
    func noteAndFraction() {
        let pitch: TX81ZPitch = 6_112

        #expect(pitch.note == 108)
        #expect(pitch.fraction == 32)
    }

    @Test
    func semitones() {
        #expect(TX81ZPitch.lowest.semitones == 13)
        #expect(TX81ZPitch(note: 69, fraction: 32)?.semitones == 69.5)
    }
}
