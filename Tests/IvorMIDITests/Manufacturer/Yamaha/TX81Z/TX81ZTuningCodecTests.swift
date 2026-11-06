// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct TX81ZTuningCodecTests {
    private let codec = TX81ZTuningCodec()
    private let equal = Fixtures.tx81zFrequencies(step: 1)
    private let prerequisites: [MIDITuningPrerequisite] = [.exclusiveEnabled,
                                                           .memoryProtectOff,
                                                           .microTuningEnabled,
                                                           .performanceMode]
}

// MARK: -

extension TX81ZTuningCodecTests {
    @Test
    func defaultSlot() {
        #expect(codec.defaultSlot == .tx81zFullKeyboard)
    }

    @Test
    func hashable() {
        #expect(Set([TX81ZTuningCodec(), TX81ZTuningCodec()]).count == 1)
    }

    @Test
    func limits() {
        #expect(codec.limits == MIDITuningLimits(maximumNameLength: 0,
                                                 resolutionInCents: 1.5625,
                                                 soundingKeys: 13...108,
                                                 supportsNoChange: false))
    }

    @Test
    func messages_clamped() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: equal))
        let output = try codec.messages(for: tuning, slot: .tx81zFullKeyboard, address: .channel(1))

        #expect(output.adjustments == [.clamped(keys: Array(0...12) + Array(109...127))])
    }

    @Test
    func messages_droppedName() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: equal, name: "Equal"))
        let output = try codec.messages(for: tuning, slot: .tx81zFullKeyboard, address: .channel(1))

        #expect(output.adjustments.last == .droppedName)
    }

    @Test(arguments: Fixtures.tx81zFullKeyboardVectors)
    func messages_golden(step: Double, bytes: [UInt8]) throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: Fixtures.tx81zFrequencies(step: step)))
        let output = try codec.messages(for: tuning, slot: .tx81zFullKeyboard, address: .channel(1))

        #expect(output.messages.first?.bytesValue == bytes)
    }

    @Test
    func messages_install() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: equal))
        let output = try codec.messages(for: tuning, slot: .tx81zFullKeyboard, address: .channel(5))

        #expect(output.messages.count == 2)
        #expect(output.messages.first?.dataBytes?.prefix(5) == [0x43, 0x04, 0x7e, 0x02, 0x0a])
        #expect(output.messages.last == .systemExclusive([0x43, 0x14, 0x10, 0x60, 1, 0xf7]))
        #expect(output.prerequisites == prerequisites)
    }

    @Test
    func messages_noChange() throws {
        var frequencies = equal

        frequencies[0] = .noChange
        frequencies[69] = .noChange

        let tuning = try #require(MIDIDeviceTuning(frequencies: frequencies))
        let output = try codec.messages(for: tuning, slot: .tx81zFullKeyboard, address: .channel(1))
        let message = try #require(output.messages.first)
        let result = try #require(codec.tuning(from: message))

        #expect(output.adjustments.first == .replacedNoChange(keys: [0, 69]))
        #expect(result.frequencies[0] == TX81ZPitch.lowest.frequency)
        #expect(result.frequencies[69] == MIDITuningFrequency(semitone: 69))
    }

    @Test
    func messages_octave_12TET() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: equal))
        let output = try codec.messages(for: tuning, slot: .tx81zOctave, address: .channel(1))
        let bytes = try #require(output.messages.first?.dataBytes)

        #expect(bytes.count == 41)
        #expect(Array(bytes[3...4]) == [0x00, 0x22])
        #expect(Array(bytes[15...16]) == [60, 0])
        #expect(Array(bytes[37...38]) == [71, 0])
        #expect(output.messages.last == .systemExclusive([0x43, 0x10, 0x10, 0x60, 0, 0xf7]))
        #expect(output.adjustments.isEmpty)
        #expect(output.prerequisites == prerequisites)
    }

    @Test
    func messages_octave_adjustmentsCoverKeys60To71() throws {
        var frequencies = equal

        frequencies[61] = .noChange
        frequencies[60] = MIDITuningFrequency(semitone: 60, fraction: 100)
        frequencies[72] = MIDITuningFrequency(semitone: 72, fraction: 100)

        let tuning = try #require(MIDIDeviceTuning(frequencies: frequencies))
        let output = try codec.messages(for: tuning, slot: .tx81zOctave, address: .channel(1))

        #expect(output.adjustments.first == .replacedNoChange(keys: [61]))
    }

    @Test
    func messages_octave_ignoresKeysOutsideSoundingRange() throws {
        var frequencies = equal

        frequencies[12] = MIDITuningFrequency(semitone: 50)
        frequencies[109] = MIDITuningFrequency(semitone: 50)

        let tuning = try #require(MIDIDeviceTuning(frequencies: frequencies))

        #expect(try codec.messages(for: tuning, slot: .tx81zOctave, address: .channel(1)).messages.count == 2)
    }

    @Test
    func messages_octave_nonRepeating() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: Fixtures.tx81zFrequencies(step: Fixtures.bohlenPierceStep)))

        #expect(throws: MIDITuningError.nonRepeatingTuning) {
            try codec.messages(for: tuning, slot: .tx81zOctave, address: .channel(1))
        }
    }

    @Test
    func messages_octave_skipsNoChangeWhenChecking() throws {
        var frequencies = equal

        frequencies[30] = .noChange

        let tuning = try #require(MIDIDeviceTuning(frequencies: frequencies))

        #expect(try codec.messages(for: tuning, slot: .tx81zOctave, address: .channel(1)).adjustments.isEmpty)
    }

    @Test
    func messages_octave_tolerance() throws {
        var frequencies = equal

        frequencies[30] = MIDITuningFrequency(semitone: 30, fraction: 256)

        let within = try #require(MIDIDeviceTuning(frequencies: frequencies))

        #expect(try codec.messages(for: within, slot: .tx81zOctave, address: .channel(1)).messages.count == 2)

        frequencies[30] = MIDITuningFrequency(semitone: 30, fraction: 257)

        let beyond = try #require(MIDIDeviceTuning(frequencies: frequencies))

        #expect(throws: MIDITuningError.nonRepeatingTuning) {
            try codec.messages(for: beyond, slot: .tx81zOctave, address: .channel(1))
        }
    }

    @Test
    func messages_rounded() throws {
        var frequencies = equal

        frequencies[69] = MIDITuningFrequency(semitone: 69, fraction: 100)

        let tuning = try #require(MIDIDeviceTuning(frequencies: frequencies))
        let output = try codec.messages(for: tuning, slot: .tx81zFullKeyboard, address: .channel(1))

        #expect(output.adjustments.contains(.rounded(maximumCents: 100 * 100 / 16_384.0)))
    }

    @Test
    func messages_unsupportedAddress() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: equal))

        #expect(throws: MIDITuningError.unsupportedAddress(.deviceID(127))) {
            try codec.messages(for: tuning, slot: .tx81zFullKeyboard, address: .deviceID(127))
        }
    }

    @Test
    func messages_unsupportedSlot() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: equal))

        #expect(throws: MIDITuningError.unsupportedSlot(.table(2))) {
            try codec.messages(for: tuning, slot: .table(2), address: .channel(1))
        }
        #expect(throws: MIDITuningError.unsupportedSlot(.program(bank: nil, 0))) {
            try codec.messages(for: tuning, slot: .program(bank: nil, 0), address: .channel(1))
        }
    }

    @Test
    func microTuneEnableMessage() {
        #expect(codec.microTuneEnableMessage(instrument: 1, isEnabled: true, channel: 1)
                == .systemExclusive([0x43, 0x10, 0x10, 11, 1, 0xf7]))
        #expect(codec.microTuneEnableMessage(instrument: 8, isEnabled: false, channel: 16)
                == .systemExclusive([0x43, 0x1f, 0x10, 95, 0, 0xf7]))
    }

    @Test
    func microTuneEnableMessage_invalidInstrument() {
        #expect(codec.microTuneEnableMessage(instrument: 0, isEnabled: true, channel: 1) == nil)
        #expect(codec.microTuneEnableMessage(instrument: 9, isEnabled: true, channel: 1) == nil)
    }

    @Test
    func microTuneKeyMessage() {
        #expect(codec.microTuneKeyMessage(11, channel: 2) == .systemExclusive([0x43, 0x11, 0x10, 0x63, 11, 0xf7]))
        #expect(codec.microTuneKeyMessage(12, channel: 2) == nil)
    }

    @Test
    func presetMessage() {
        #expect(codec.presetMessage(.equal, channel: 1) == .systemExclusive([0x43, 0x10, 0x10, 0x60, 2, 0xf7]))
        #expect(codec.presetMessage(.eighthTone, channel: 3) == .systemExclusive([0x43, 0x12, 0x10, 0x60, 12, 0xf7]))
    }

    @Test
    func probe_roundTrip() throws {
        let requests = try codec.requestMessages(slot: codec.defaultSlot, address: .channel(1))
        let reply = try #require(MIDISystemMessage(bytesValue: Fixtures.tx81z19TET))

        #expect(requests.map(\.bytesValue) == [[0xf0, 0x43, 0x20, 0x7e] + Array("LM  MCRTE1".utf8) + [0xf7]])
        #expect(codec.tuning(from: reply) != nil)
    }

    @Test
    func probeAddresses() {
        #expect(codec.probeAddresses == (1...16).map { .channel(MIDIChannel(clamping: $0)) })
    }

    @Test
    func requestMessages_octave() throws {
        let requests = try codec.requestMessages(slot: .tx81zOctave, address: .channel(16))

        #expect(requests.map(\.bytesValue) == [[0xf0, 0x43, 0x2f, 0x7e] + Array("LM  MCRTE0".utf8) + [0xf7]])
    }

    @Test
    func requestMessages_unsupportedAddress() {
        #expect(throws: MIDITuningError.unsupportedAddress(.deviceID(1))) {
            try codec.requestMessages(slot: .tx81zOctave, address: .deviceID(1))
        }
    }

    @Test
    func requestMessages_unsupportedSlot() {
        #expect(throws: MIDITuningError.unsupportedSlot(.table(5))) {
            try codec.requestMessages(slot: .table(5), address: .channel(1))
        }
    }

    @Test
    func selectionMessages() throws {
        #expect(try codec.selectionMessages(slot: .tx81zFullKeyboard, channels: [1, 2]).isEmpty)
        #expect(try codec.selectionMessages(slot: .tx81zOctave, channels: [1, 2]).isEmpty)
    }

    @Test
    func selectionMessages_unsupportedSlot() {
        #expect(throws: MIDITuningError.unsupportedSlot(.table(5))) {
            try codec.selectionMessages(slot: .table(5), channels: [1])
        }
    }

    @Test
    func tuning_fullKeyboardDump() throws {
        let message = try #require(MIDISystemMessage(bytesValue: Fixtures.tx81z12TET))
        let tuning = try #require(codec.tuning(from: message))

        #expect(tuning.name == nil)
        #expect(tuning.frequencies[0] == TX81ZPitch.lowest.frequency)
        #expect(tuning.frequencies[69] == MIDITuningFrequency(semitone: 69))
        #expect(tuning.frequencies[127] == TX81ZPitch.highest.frequency)
    }

    @Test
    func tuning_notDumps() throws {
        let request = try #require(try codec.requestMessages(slot: .tx81zOctave, address: .channel(1)).first)

        #expect(codec.tuning(from: request) == nil)
        #expect(codec.tuning(from: codec.presetMessage(.equal, channel: 1)) == nil)
        #expect(codec.tuning(from: .start) == nil)
    }

    @Test
    func tuning_octaveDump() throws {
        let pitches = (60...71).compactMap { TX81ZPitch(note: MIDIData1Value(clamping: $0)) }
        let message = try #require(TX81ZTuningMessage(content: .dump(.octave, pitches: pitches), channel: 1).systemMessage)
        let tuning = try #require(codec.tuning(from: message))

        #expect(tuning.name == nil)
        #expect(tuning.frequencies == (0..<128).map { MIDITuningFrequency(semitone: MIDIData1Value(clamping: $0)) })
    }

    @Test
    func tuning_octaveDump_clampsAvoidingNoChange() throws {
        let pitches = [TX81ZPitch.lowest] + [TX81ZPitch](repeating: .highest, count: 11)
        let message = try #require(TX81ZTuningMessage(content: .dump(.octave, pitches: pitches), channel: 1).systemMessage)
        let tuning = try #require(codec.tuning(from: message))

        #expect(tuning.frequencies[0].uintValue == 0)
        #expect(tuning.frequencies[127].uintValue == 2_097_150)
        #expect(!tuning.frequencies.contains(.noChange))
    }

    @Test
    func tuning_octaveDump_roundTrip() throws {
        let message = try #require(MIDISystemMessage(bytesValue: Fixtures.tx81zOctaveDump))
        let tuning = try #require(codec.tuning(from: message))
        let output = try codec.messages(for: tuning, slot: .tx81zOctave, address: .channel(1))

        #expect(output.messages.first?.bytesValue == Fixtures.tx81zOctaveDump)
    }
}
