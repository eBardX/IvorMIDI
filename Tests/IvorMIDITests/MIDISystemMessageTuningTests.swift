// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDISystemMessageTuningTests {
}

// MARK: - Dump requests

extension MIDISystemMessageTuningTests {
    @Test
    func bulkTuningDumpRequest() {
        #expect(MIDISystemMessage.bulkTuningDumpRequest(program: 5).dataBytes
                == [0x7e, 0x7f, 0x08, 0x00, 0x05, 0xf7])
        #expect(MIDISystemMessage.bulkTuningDumpRequest(program: 5, deviceID: 0x10).dataBytes
                == [0x7e, 0x10, 0x08, 0x00, 0x05, 0xf7])
    }

    @Test
    func bulkTuningDumpRequest_bank() {
        #expect(MIDISystemMessage.bulkTuningDumpRequest(bank: 2, program: 5).dataBytes
                == [0x7e, 0x7f, 0x08, 0x03, 0x02, 0x05, 0xf7])
        #expect(MIDISystemMessage.bulkTuningDumpRequest(bank: 2, program: 5, deviceID: 0x10).dataBytes
                == [0x7e, 0x10, 0x08, 0x03, 0x02, 0x05, 0xf7])
    }
}

// MARK: - Key-based dumps

extension MIDISystemMessageTuningTests {
    @Test
    func bulkTuningDump() throws {
        let frequencies = [MIDITuningFrequency](repeating: MIDITuningFrequency(semitone: 0x45), count: 128)
        let message = MIDISystemMessage.bulkTuningDump(program: 0, name: "", frequencies: frequencies)
        let bytes = try #require(message?.dataBytes)

        #expect(bytes.count == 4 + 1 + 16 + 384 + 2)
        #expect(Array(bytes[0...4]) == [0x7e, 0x7f, 0x08, 0x01, 0x00])
        #expect(Array(bytes[5...20]) == [UInt8](repeating: 0x20, count: 16))
        #expect(Array(bytes[21...23]) == [0x45, 0x00, 0x00])
        #expect(bytes[bytes.count - 2] == 0x00)         // 7E ^ 7F ^ 01 ^ tt, without sub-ID#1
        #expect(bytes.last == 0xf7)
    }

    @Test
    func bulkTuningDump_badArguments() {
        let frequencies = [MIDITuningFrequency](repeating: .noChange, count: 128)

        #expect(MIDISystemMessage.bulkTuningDump(program: 0, name: "", frequencies: Array(frequencies.dropLast())) == nil)
        #expect(MIDISystemMessage.bulkTuningDump(program: 0, name: "é", frequencies: frequencies) == nil)
    }

    @Test
    func keyBasedTuningDump() throws {
        let frequencies = [MIDITuningFrequency](repeating: MIDITuningFrequency(semitone: 0x45), count: 128)
        let message = MIDISystemMessage.keyBasedTuningDump(bank: 0, program: 0, name: "", frequencies: frequencies)
        let bytes = try #require(message?.dataBytes)

        #expect(bytes.count == 4 + 2 + 16 + 384 + 2)
        #expect(Array(bytes[0...5]) == [0x7e, 0x7f, 0x08, 0x04, 0x00, 0x00])
        #expect(bytes[bytes.count - 2] == 0x0d)         // 7E ^ 7F ^ 08 ^ 04
        #expect(bytes.last == 0xf7)
    }

    @Test
    func keyBasedTuningDump_badArguments() {
        let frequencies = [MIDITuningFrequency](repeating: .noChange, count: 128)

        #expect(MIDISystemMessage.keyBasedTuningDump(bank: 0,
                                                     program: 0,
                                                     name: "",
                                                     frequencies: frequencies + [.noChange]) == nil)
        #expect(MIDISystemMessage.keyBasedTuningDump(bank: 0,
                                                     program: 0,
                                                     name: "seventeen letters",
                                                     frequencies: frequencies) == nil)
    }

    @Test
    func tuningName() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 12)
        let bytes = { (name: String) in
            MIDISystemMessage.scaleOctaveTuningDump(bank: 0, program: 0, name: name, offsets: .coarse(offsets))?
                .dataBytes?[6...21].map(\.self)
        }

        #expect(bytes("Werckmeister") == Array("Werckmeister    ".utf8))
        #expect(bytes("sixteen  letters") == Array("sixteen  letters".utf8))
        #expect(bytes("seventeen letters") == nil)
    }
}

// MARK: - Scale/octave dumps

extension MIDISystemMessageTuningTests {
    @Test
    func scaleOctaveTuningDump_fineOffsets() throws {
        let offsets = [MIDIData2Value](repeating: 8_192, count: 12)
        let message = MIDISystemMessage.scaleOctaveTuningDump(bank: 0, program: 0, name: "", offsets: .fine(offsets))
        let bytes = try #require(message?.dataBytes)

        #expect(bytes.count == 4 + 2 + 16 + 24 + 2)
        #expect(Array(bytes[0...5]) == [0x7e, 0x7f, 0x08, 0x06, 0x00, 0x00])
        #expect(Array(bytes[22...23]) == [0x40, 0x00])
        #expect(bytes[bytes.count - 2] == 0x0f)         // 7E ^ 7F ^ 08 ^ 06
        #expect(bytes.last == 0xf7)
    }

    @Test
    func scaleOctaveTuningDump_offsets() throws {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 12)
        let message = MIDISystemMessage.scaleOctaveTuningDump(bank: 0, program: 0, name: "", offsets: .coarse(offsets))
        let bytes = try #require(message?.dataBytes)

        #expect(bytes.count == 4 + 2 + 16 + 12 + 2)
        #expect(Array(bytes[0...5]) == [0x7e, 0x7f, 0x08, 0x05, 0x00, 0x00])
        #expect(Array(bytes[22...33]) == [UInt8](repeating: 0x40, count: 12))
        #expect(bytes[bytes.count - 2] == 0x0c)         // 7E ^ 7F ^ 08 ^ 05
        #expect(bytes.last == 0xf7)
    }

    @Test
    func scaleOctaveTuningDump_checksumIsSevenBitAndCoversBody() throws {
        let offsets: [MIDIData1Value] = [0x01, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40]
        let message = MIDISystemMessage.scaleOctaveTuningDump(bank: 3,
                                                              program: 7,
                                                              name: "A",
                                                              offsets: .coarse(offsets),
                                                              deviceID: 0x10)
        let bytes = try #require(message?.dataBytes)
        let body = bytes.dropLast(2)

        #expect(bytes[bytes.count - 2] == body.reduce(0, ^) & 0x7f)
    }

    @Test
    func scaleOctaveTuningDump_wrongOffsetCount() {
        #expect(MIDISystemMessage.scaleOctaveTuningDump(bank: 0,
                                                        program: 0,
                                                        name: "",
                                                        offsets: .coarse([0x40])) == nil)
        #expect(MIDISystemMessage.scaleOctaveTuningDump(bank: 0,
                                                        program: 0,
                                                        name: "",
                                                        offsets: .fine([8_192])) == nil)
    }
}

// MARK: - Single note tuning changes

extension MIDISystemMessageTuningTests {
    @Test
    func singleNoteTuningChange() {
        let changes = [MIDITuningChange(key: 69, frequency: MIDITuningFrequency(semitone: 0x45)),
                       MIDITuningChange(key: 70, frequency: .noChange)]
        let message = MIDISystemMessage.singleNoteTuningChange(changes, program: 3)

        #expect(message?.dataBytes == [0x7f,
                                       0x7f,
                                       0x08,
                                       0x02,
                                       0x03,
                                       0x02,
                                       0x45,
                                       0x45,
                                       0x00,
                                       0x00,
                                       0x46,
                                       0x7f,
                                       0x7f,
                                       0x7f,
                                       0xf7])
    }

    @Test
    func singleNoteTuningChange_bank() {
        let changes = [MIDITuningChange(key: 69, frequency: MIDITuningFrequency(semitone: 0x45))]
        let realTime = MIDISystemMessage.singleNoteTuningChange(changes, bank: 2, program: 3)
        let nonRealTime = MIDISystemMessage.singleNoteTuningChange(changes, bank: 2, program: 3, realTime: false)

        #expect(realTime?.dataBytes == [0x7f, 0x7f, 0x08, 0x07, 0x02, 0x03, 0x01, 0x45, 0x45, 0x00, 0x00, 0xf7])
        #expect(nonRealTime?.dataBytes == [0x7e, 0x7f, 0x08, 0x07, 0x02, 0x03, 0x01, 0x45, 0x45, 0x00, 0x00, 0xf7])
    }

    @Test
    func singleNoteTuningChange_changeCount() {
        let change = MIDITuningChange(key: 0, frequency: .noChange)
        let changes = { (count: Int) in [MIDITuningChange](repeating: change, count: count) }

        #expect(MIDISystemMessage.singleNoteTuningChange(changes(0), program: 0) == nil)
        #expect(MIDISystemMessage.singleNoteTuningChange(changes(128), program: 0) == nil)
        #expect(MIDISystemMessage.singleNoteTuningChange(changes(0), bank: 0, program: 0) == nil)
        #expect(MIDISystemMessage.singleNoteTuningChange(changes(128), bank: 0, program: 0) == nil)

        // The specification gives the total length as 8 + (ll × 4) bytes,
        // which is one more than the data bytes, because of the status byte.
        #expect(MIDISystemMessage.singleNoteTuningChange(changes(127), program: 0)?.dataBytes?.count == 8 + 127 * 4 - 1)
    }
}

// MARK: - Scale/octave tuning, 2-byte form

extension MIDISystemMessageTuningTests {
    @Test
    func scaleOctaveTuning_fineOffsets() {
        let offsets: [MIDIData2Value] = [0, 8_192, 16_383, 8_192, 8_192, 8_192, 8_192, 8_192, 8_192, 8_192, 8_192, 8_192]
        let message = MIDISystemMessage.scaleOctaveTuning(channels: [1, 16], offsets: .fine(offsets))

        #expect(message?.dataBytes == [0x7e,
                                       0x7f,
                                       0x08,
                                       0x09,
                                       0x02,
                                       0x00,
                                       0x01,
                                       0x00,
                                       0x00,
                                       0x40,
                                       0x00,
                                       0x7f,
                                       0x7f]
                                      + [[UInt8]](repeating: [0x40, 0x00], count: 9).flatMap(\.self)
                                      + [0xf7])
    }

    @Test
    func scaleOctaveTuning_fineOffsets_realTime() {
        let offsets = [MIDIData2Value](repeating: 8_192, count: 12)
        let message = MIDISystemMessage.scaleOctaveTuning(channels: [10],
                                                          offsets: .fine(offsets),
                                                          realTime: true,
                                                          deviceID: 0x10)

        #expect(message?.dataBytes?.prefix(7) == [0x7f, 0x10, 0x08, 0x09, 0x00, 0x04, 0x00])
    }

    @Test
    func scaleOctaveTuning_fineOffsets_wrongOffsetCount() {
        let offsets = [MIDIData2Value](repeating: 8_192, count: 11)

        #expect(MIDISystemMessage.scaleOctaveTuning(channels: [1], offsets: .fine(offsets)) == nil)
    }

    @Test
    func scaleOctaveTuning_deviceID() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 12)
        let message = MIDISystemMessage.scaleOctaveTuning(channels: [1], offsets: .coarse(offsets), deviceID: 0x10)

        #expect(message?.dataBytes?.prefix(4) == [0x7e, 0x10, 0x08, 0x08])
    }
}

// MARK: - Tuning program and bank selection

extension MIDISystemMessageTuningTests {
    @Test
    func tuningBankSelect() {
        #expect(MIDIChannelMessage.registeredParameterChange(.tuningBankSelect, msb: 5, on: 1).prefix(3)
                == [.controlChange(1, .registeredParameterNumberMSB, 0x00),
                    .controlChange(1, .registeredParameterNumberLSB, 0x04),
                    .controlChange(1, .dataEntryMSB, 5)])
    }

    @Test
    func tuningProgramSelect() {
        #expect(MIDIChannelMessage.registeredParameterChange(.tuningProgramChange, msb: 5, on: 1).prefix(3)
                == [.controlChange(1, .registeredParameterNumberMSB, 0x00),
                    .controlChange(1, .registeredParameterNumberLSB, 0x03),
                    .controlChange(1, .dataEntryMSB, 5)])
    }
}

// MARK: - Scale/octave tuning, 1-byte form

extension MIDISystemMessageTuningTests {
    @Test
    func scaleOctaveTuning() {
        let offsets: [MIDIData1Value] = [0x40, 0x3e, 0x40, 0x42, 0x40, 0x40, 0x3e, 0x40, 0x3e, 0x40, 0x42, 0x40]
        let message = MIDISystemMessage.scaleOctaveTuning(channels: [1], offsets: .coarse(offsets))

        #expect(message?.dataBytes == [0x7e, 0x7f, 0x08, 0x08, 0x00, 0x00, 0x01]
                                      + [0x40, 0x3e, 0x40, 0x42, 0x40, 0x40, 0x3e, 0x40, 0x3e, 0x40, 0x42, 0x40]
                                      + [0xf7])
    }

    @Test
    func scaleOctaveTuning_channelBits() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 12)
        let channelBytes = { (channels: [MIDIChannel]) in
            MIDISystemMessage.scaleOctaveTuning(channels: channels, offsets: .coarse(offsets))?.dataBytes?[4...6].map(\.self)
        }

        #expect(channelBytes([]) == [0x00, 0x00, 0x00])
        #expect(channelBytes([7]) == [0x00, 0x00, 0x40])
        #expect(channelBytes([8]) == [0x00, 0x01, 0x00])
        #expect(channelBytes([14]) == [0x00, 0x40, 0x00])
        #expect(channelBytes([15, 16]) == [0x03, 0x00, 0x00])
        #expect(channelBytes((1...16).compactMap { MIDIChannel(uintValue: $0) }) == [0x03, 0x7f, 0x7f])
    }

    @Test
    func scaleOctaveTuning_realTime() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 12)
        let message = MIDISystemMessage.scaleOctaveTuning(channels: [10], offsets: .coarse(offsets), realTime: true)

        #expect(message?.dataBytes?.prefix(7) == [0x7f, 0x7f, 0x08, 0x08, 0x00, 0x04, 0x00])
    }

    @Test
    func scaleOctaveTuning_wrongOffsetCount() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 11)

        #expect(MIDISystemMessage.scaleOctaveTuning(channels: [1], offsets: .coarse(offsets)) == nil)
        #expect(MIDISystemMessage.scaleOctaveTuning(channels: [1], offsets: .coarse(offsets + [0x40, 0x40])) == nil)
    }
}
