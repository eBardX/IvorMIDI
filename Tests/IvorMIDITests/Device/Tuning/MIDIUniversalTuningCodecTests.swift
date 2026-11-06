// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDIUniversalTuningCodecTests {
    private let codec = MIDIUniversalTuningCodec()
    private let flat = [MIDITuningFrequency](repeating: MIDITuningFrequency(semitone: 0x45), count: 128)
    private let frequencies = (0..<128).map { MIDITuningFrequency(semitone: MIDIData1Value(clamping: $0), fraction: 5) }
}

// MARK: -

extension MIDIUniversalTuningCodecTests {
    @Test
    func defaultSlot() {
        #expect(codec.defaultSlot == .program(bank: nil, 0))
    }

    @Test
    func hashable() {
        #expect(Set([MIDIUniversalTuningCodec(), MIDIUniversalTuningCodec()]).count == 1)
    }

    @Test
    func limits() {
        #expect(codec.limits == MIDITuningLimits(maximumNameLength: 16,
                                                 resolutionInCents: 100.0 / 16_384,
                                                 soundingKeys: 0...127,
                                                 supportsNoChange: true))
    }

    @Test
    func messages_bank() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: flat))
        let output = try codec.messages(for: tuning, slot: .program(bank: 2, 5), address: .deviceID(0x10))

        #expect(output.messages.count == 1)
        #expect(output.messages.first?.dataBytes?.prefix(6) == [0x7e, 0x10, 0x08, 0x04, 0x02, 0x05])
    }

    @Test
    func messages_droppedName() throws {
        let tooLong = try #require(MIDIDeviceTuning(frequencies: flat, name: "seventeen letters"))
        let notASCII = try #require(MIDIDeviceTuning(frequencies: flat, name: "é"))

        for tuning in [tooLong, notASCII] {
            let output = try codec.messages(for: tuning, slot: codec.defaultSlot, address: .deviceID(127))
            let bytes = try #require(output.messages.first?.dataBytes)

            #expect(output.adjustments == [.droppedName])
            #expect(output.messages.count == 1)
            #expect(Array(bytes[5...20]) == [UInt8](repeating: 0x20, count: 16))
        }
    }

    @Test
    func messages_noBank() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: flat, name: "Just"))
        let output = try codec.messages(for: tuning, slot: .program(bank: nil, 5), address: .deviceID(0x10))
        let bytes = try #require(output.messages.first?.dataBytes)

        #expect(output.messages.count == 1)
        #expect(output.adjustments.isEmpty)
        #expect(output.prerequisites.isEmpty)
        #expect(bytes.count == 4 + 1 + 16 + 384 + 2)
        #expect(Array(bytes[0...4]) == [0x7e, 0x10, 0x08, 0x01, 0x05])
        #expect(Array(bytes[5...8]) == Array("Just".utf8))
        #expect(Array(bytes[21...23]) == [0x45, 0x00, 0x00])
    }

    @Test
    func messages_unsupportedAddress() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: flat))

        #expect(throws: MIDITuningError.unsupportedAddress(.channel(1))) {
            try codec.messages(for: tuning, slot: codec.defaultSlot, address: .channel(1))
        }
    }

    @Test
    func messages_unsupportedSlot() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: flat))

        #expect(throws: MIDITuningError.unsupportedSlot(.table(1))) {
            try codec.messages(for: tuning, slot: .table(1), address: .deviceID(127))
        }
    }

    @Test
    func probeAddresses() {
        #expect(codec.probeAddresses == [.deviceID(127)])
    }

    @Test
    func requestMessages() throws {
        let messages = try codec.requestMessages(slot: .program(bank: nil, 5), address: .deviceID(0x10))

        #expect(messages == [.systemExclusive([0x7e, 0x10, 0x08, 0x00, 0x05, 0xf7])])
    }

    @Test
    func requestMessages_bank() throws {
        let messages = try codec.requestMessages(slot: .program(bank: 2, 5), address: .deviceID(0x10))

        #expect(messages == [.systemExclusive([0x7e, 0x10, 0x08, 0x03, 0x02, 0x05, 0xf7])])
    }

    @Test
    func requestMessages_unsupportedAddress() {
        #expect(throws: MIDITuningError.unsupportedAddress(.channel(1))) {
            try codec.requestMessages(slot: codec.defaultSlot, address: .channel(1))
        }
    }

    @Test
    func requestMessages_unsupportedSlot() {
        #expect(throws: MIDITuningError.unsupportedSlot(.table(0))) {
            try codec.requestMessages(slot: .table(0), address: .deviceID(127))
        }
    }

    @Test
    func selectionMessages_bank() throws {
        let expected = MIDIChannelMessage.registeredParameterChange(.tuningBankSelect, msb: 2, on: 3)
            + MIDIChannelMessage.registeredParameterChange(.tuningProgramChange, msb: 5, on: 3)

        #expect(try codec.selectionMessages(slot: .program(bank: 2, 5), channels: [3]) == expected)
    }

    @Test
    func selectionMessages_eachChannel() throws {
        let expected = MIDIChannelMessage.registeredParameterChange(.tuningProgramChange, msb: 5, on: 1)
            + MIDIChannelMessage.registeredParameterChange(.tuningProgramChange, msb: 5, on: 16)

        #expect(try codec.selectionMessages(slot: .program(bank: nil, 5), channels: [1, 16]) == expected)
    }

    @Test
    func selectionMessages_noBank() throws {
        #expect(try codec.selectionMessages(slot: .program(bank: nil, 5), channels: [3])
                == MIDIChannelMessage.registeredParameterChange(.tuningProgramChange, msb: 5, on: 3))
    }

    @Test
    func selectionMessages_noChannels() throws {
        #expect(try codec.selectionMessages(slot: .program(bank: 2, 5), channels: []).isEmpty)
    }

    @Test
    func selectionMessages_unsupportedSlot() {
        #expect(throws: MIDITuningError.unsupportedSlot(.table(1))) {
            try codec.selectionMessages(slot: .table(1), channels: [1])
        }
    }

    @Test
    func tuning_coarseScaleOctaveDump() throws {
        var offsets = [MIDIData1Value](repeating: 64, count: 12)

        offsets[0] = 0      // C, −64 cents
        offsets[9] = 74     // A, +10 cents

        let message = MIDITuningMessage(content: .scaleOctaveDump(bank: 0, program: 0, name: "Well", offsets: .coarse(offsets)))
        let systemMessage = try #require(message.systemMessage)
        let tuning = try #require(codec.tuning(from: systemMessage))

        #expect(tuning.name == "Well")
        #expect(tuning.frequencies.count == 128)
        #expect(tuning.frequencies[0].uintValue == 0)                       // Clamped
        #expect(tuning.frequencies[12].uintValue == 12 * 16_384 - 10_486)   // 64 × 163.84, rounded
        #expect(tuning.frequencies[61].uintValue == 61 * 16_384)
        #expect(tuning.frequencies[69].uintValue == 69 * 16_384 + 1_638)    // 10 × 163.84, rounded
    }

    @Test
    func tuning_dumpRequest() throws {
        let messages = try codec.requestMessages(slot: codec.defaultSlot, address: .deviceID(127))
        let message = try #require(messages.first)

        #expect(codec.tuning(from: message) == nil)
    }

    @Test
    func tuning_emptyNameBecomesNil() throws {
        let original = try #require(MIDIDeviceTuning(frequencies: flat, name: ""))
        let output = try codec.messages(for: original, slot: codec.defaultSlot, address: .deviceID(127))
        let message = try #require(output.messages.first)

        #expect(codec.tuning(from: message)?.name == nil)
    }

    @Test
    func tuning_fineScaleOctaveDump() throws {
        var offsets = [MIDIData2Value](repeating: 8_192, count: 12)

        offsets[0] = 0          // C, −100 cents
        offsets[9] = 12_288     // A, +50 cents

        let message = MIDITuningMessage(content: .scaleOctaveDump(bank: 0, program: 0, name: "", offsets: .fine(offsets)))
        let systemMessage = try #require(message.systemMessage)
        let tuning = try #require(codec.tuning(from: systemMessage))

        #expect(tuning.name == nil)
        #expect(tuning.frequencies[0].uintValue == 0)                       // Clamped
        #expect(tuning.frequencies[12].uintValue == 11 * 16_384)
        #expect(tuning.frequencies[69].uintValue == 69 * 16_384 + 8_192)
    }

    @Test
    func tuning_highestOffsetsAvoidNoChange() throws {
        let offsets = [MIDIData2Value](repeating: 16_383, count: 12)
        let message = MIDITuningMessage(content: .scaleOctaveDump(bank: 0, program: 0, name: "", offsets: .fine(offsets)))
        let systemMessage = try #require(message.systemMessage)
        let tuning = try #require(codec.tuning(from: systemMessage))

        #expect(tuning.frequencies[127].uintValue == 2_097_150)
        #expect(!tuning.frequencies.contains(.noChange))
    }

    @Test
    func tuning_invalidDump() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: flat))
        let output = try codec.messages(for: tuning, slot: .program(bank: 2, 5), address: .deviceID(127))
        let message = try #require(output.messages.first)

        #expect(codec.tuning(from: corruptingChecksum(of: message)) == nil)
    }

    @Test
    func tuning_notTuningMessages() {
        #expect(codec.tuning(from: .start) == nil)
        #expect(codec.tuning(from: .systemExclusive([0x43, 0x00, 0xf7])) == nil)
    }

    @Test
    func tuning_preservesNoChange() throws {
        var values = frequencies

        values[10] = .noChange

        let original = try #require(MIDIDeviceTuning(frequencies: values))
        let output = try codec.messages(for: original, slot: codec.defaultSlot, address: .deviceID(127))
        let message = try #require(output.messages.first)

        #expect(codec.tuning(from: message)?.frequencies[10] == .noChange)
    }

    @Test
    func tuning_roundTrip() throws {
        let original = try #require(MIDIDeviceTuning(frequencies: frequencies, name: "Werckmeister III"))

        for slot: MIDITuningSlot in [.program(bank: nil, 5), .program(bank: 2, 5)] {
            let output = try codec.messages(for: original, slot: slot, address: .deviceID(0x10))
            let message = try #require(output.messages.first)

            #expect(codec.tuning(from: message) == original)
        }
    }
}
