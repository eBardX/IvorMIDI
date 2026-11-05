// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorMIDI
import Testing
import XestiTools

struct MIDITuningFrequencyTests {
}

// MARK: -

extension MIDITuningFrequencyTests {
    @Test
    func bytesValue() {
        #expect(MIDITuningFrequency(semitone: 0x45).bytesValue == [0x45, 0x00, 0x00])
        #expect(MIDITuningFrequency(semitone: 0x44, fraction: 16_383).bytesValue == [0x44, 0x7f, 0x7f])
        #expect(MIDITuningFrequency(semitone: 0x01, fraction: 0x81).bytesValue == [0x01, 0x01, 0x01])
        #expect(MIDITuningFrequency.noChange.bytesValue == [0x7f, 0x7f, 0x7f])
    }

    @Test
    func codable() throws {
        let original = MIDITuningFrequency(semitone: 0x45, fraction: 1)
        let data = try JSONEncoder().encode(original)

        #expect(try JSONDecoder().decode(MIDITuningFrequency.self, from: data) == original)
    }

    @Test
    func components() {
        let frequency = MIDITuningFrequency(semitone: 0x44, fraction: 0x1234)

        #expect(frequency.semitone == 0x44)
        #expect(frequency.fraction == 0x1234)
        #expect(MIDITuningFrequency(semitone: 127, fraction: 16_383) == .noChange)
    }

    // The table of examples in “Frequency Data Format”, leaving out 00 00 01,
    // which the specification misprints as 8.2104 Hz: it is one unit, or 0.0061
    // cents, above 8.1758 Hz. The values above 8 kHz are printed up to 0.08 Hz
    // too high, which is about 0.1 cents; hertz_topOfRange checks the true one.
    @Test(arguments: [([0x00, 0x00, 0x00], 8.1758, 0.0001),
                      ([0x01, 0x00, 0x00], 8.6620, 0.0001),
                      ([0x0c, 0x00, 0x00], 16.3516, 0.0001),
                      ([0x3c, 0x00, 0x00], 261.6256, 0.0001),
                      ([0x3d, 0x00, 0x00], 277.1827, 0.0001),
                      ([0x44, 0x7f, 0x7f], 439.9984, 0.0001),
                      ([0x45, 0x00, 0x00], 440.0000, 0.0001),
                      ([0x45, 0x00, 0x01], 440.0016, 0.0001),
                      ([0x78, 0x00, 0x00], 8_372.0190, 0.08),
                      ([0x78, 0x00, 0x01], 8_372.0630, 0.08),
                      ([0x7f, 0x00, 0x00], 12_543.8800, 0.08),
                      ([0x7f, 0x00, 0x01], 12_543.9200, 0.08),
                      ([0x7f, 0x7f, 0x7e], 13_289.7300, 0.08)] as [([UInt8], Double, Double)])
    func hertz(bytes: [UInt8], hertz: Double, tolerance: Double) throws {
        let frequency = try #require(MIDITuningFrequency(bytesValue: bytes))

        #expect(try abs(#require(frequency.hertz) - hertz) <= tolerance)
    }

    @Test
    func hertz_topOfRange() throws {
        let frequency = try #require(MIDITuningFrequency(bytesValue: [0x7f, 0x7f, 0x7e]))

        #expect(try abs(#require(frequency.hertz) - 13_289.6566) <= 0.0001)
    }

    @Test
    func hertz_noChange() {
        #expect(MIDITuningFrequency.noChange.hertz == nil)
    }

    @Test
    func initBytesValue_invalid() {
        #expect(MIDITuningFrequency(bytesValue: [0x45, 0x00]) == nil)
        #expect(MIDITuningFrequency(bytesValue: [0x45, 0x00, 0x00, 0x00]) == nil)
        #expect(MIDITuningFrequency(bytesValue: [0x80, 0x00, 0x00]) == nil)
        #expect(MIDITuningFrequency(bytesValue: [0x45, 0x80, 0x00]) == nil)
        #expect(MIDITuningFrequency(bytesValue: [0x45, 0x00, 0x80]) == nil)
    }

    @Test
    func initHertz() {
        #expect(MIDITuningFrequency(hertz: 440) == MIDITuningFrequency(semitone: 0x45))
        #expect(MIDITuningFrequency(hertz: 261.6256)?.semitone == 0x3c)
    }

    @Test
    func initHertz_outOfRange() {
        #expect(MIDITuningFrequency(hertz: 0) == nil)
        #expect(MIDITuningFrequency(hertz: -440) == nil)
        #expect(MIDITuningFrequency(hertz: 8) == nil)
        #expect(MIDITuningFrequency(hertz: 13_290) == nil)
        #expect(MIDITuningFrequency(hertz: .infinity) == nil)
        #expect(MIDITuningFrequency(hertz: .nan) == nil)
    }

    @Test
    func initHertz_roundTrips() throws {
        for value in stride(from: UInt(0), to: 2_097_151, by: 4_099) {
            let frequency = try #require(MIDITuningFrequency(uintValue: value))
            let hertz = try #require(frequency.hertz)

            #expect(MIDITuningFrequency(hertz: hertz) == frequency)
        }
    }

    @Test
    func isValid() {
        #expect(MIDITuningFrequency.isValid(0))
        #expect(MIDITuningFrequency.isValid(2_097_151))
        #expect(!MIDITuningFrequency.isValid(2_097_152))
        #expect(MIDITuningFrequency(uintValue: 2_097_152) == nil)
    }
}
