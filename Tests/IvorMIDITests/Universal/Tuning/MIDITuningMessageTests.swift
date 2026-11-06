// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDITuningMessageTests {
    private let bankZero = MIDITuningLocation(program: 0, bank: 0)
    private let centered = MIDITuningOffsets.coarse([MIDIData1Value](repeating: 0x40, count: 12))
    private let centeredFine = MIDITuningOffsets.fine([MIDIData2Value](repeating: 8_192, count: 12))
    private let coarse = MIDITuningOffsets.coarse((0..<12).map { MIDIData1Value(clamping: 58 + $0) })
    private let fine = MIDITuningOffsets.fine((0..<12).map { MIDIData2Value(clamping: 8_000 + $0 * 37) })
    private let flatFrequencies = [MIDITuningFrequency](repeating: MIDITuningFrequency(semitone: 0x45), count: 128)
    private let frequencies = (0..<128).map { MIDITuningFrequency(semitone: MIDIData1Value(clamping: $0), fraction: 5) }
    private let name = "Werckmeister III"
    private let noChanges = [MIDITuningFrequency](repeating: .noChange, count: 128)
    private let programZero = MIDITuningLocation(program: 0)
}

// MARK: -

extension MIDITuningMessageTests {
    @Test
    func decode_bulkDumpIgnoresChecksum() throws {
        let message = try #require(MIDITuningMessage(content: .keyBasedDump(MIDITuningLocation(program: 5),
                                                                            name: name,
                                                                            frequencies: frequencies)).systemMessage)

        #expect(MIDITuningMessage(corruptingChecksum(of: message)) != nil)
    }

    @Test
    func decode_dumpRequest() {
        let message = MIDITuningMessage(.systemExclusive([0x7e, 0x7f, 0x08, 0x03, 0x02, 0x05, 0xf7]))

        #expect(message?.deviceID == 0x7f)
        #expect(message?.content == .dumpRequest(MIDITuningLocation(program: 5, bank: 2)))
    }

    @Test
    func decode_ignoresReservedChannelBits() {
        let bytes: [UInt8] = [0x7e, 0x7f, 0x08, 0x08, 0x7c, 0x00, 0x01]
                             + [UInt8](repeating: 0x40, count: 12)
                             + [0xf7]

        guard case let .scaleOctaveTuning(channels, _, _) = MIDITuningMessage(.systemExclusive(bytes))?.content
        else {
            Issue.record("Not a scale/octave tuning message")
            return
        }

        #expect(channels == [1])
    }

    @Test
    func decode_keyBasedDump_withoutBank() throws {
        let content = MIDITuningMessage.Content.keyBasedDump(MIDITuningLocation(program: 5),
                                                             name: "Just",
                                                             frequencies: frequencies)
        let message = try #require(MIDITuningMessage(content: content).systemMessage)

        #expect(MIDITuningMessage(message)?.content == content)
    }

    @Test
    func decode_malformed() {
        #expect(MIDITuningMessage(.systemExclusive([0x7e, 0x7f, 0x08, 0x00, 0x05])) == nil)         // No EOX
        #expect(MIDITuningMessage(.systemExclusive([0x7e, 0x7f, 0x08, 0x00, 0x85, 0xf7])) == nil)   // Not a data byte
        #expect(MIDITuningMessage(.systemExclusive([0x7e, 0x7f, 0x08, 0x00, 0xf7])) == nil)         // Too short
        #expect(MIDITuningMessage(.systemExclusive([0x7e, 0x7f, 0x08, 0x00, 0x05, 0x06, 0xf7])) == nil) // Too long
    }

    @Test
    func decode_nameKeepsInnerSpaces() throws {
        let message = try #require(MIDITuningMessage(content: .scaleOctaveDump(bank: 0,
                                                                               program: 0,
                                                                               name: "a b  ",
                                                                               offsets: coarse)).systemMessage)

        guard case let .scaleOctaveDump(_, _, name, _) = MIDITuningMessage(message)?.content
        else {
            Issue.record("Not a scale/octave dump")
            return
        }

        #expect(name == "a b")
    }

    @Test
    func decode_notTuningMessages() {
        #expect(MIDITuningMessage(.start) == nil)
        #expect(MIDITuningMessage(.systemExclusive([])) == nil)
        #expect(MIDITuningMessage(.systemExclusive([0xf7])) == nil)
        #expect(MIDITuningMessage(.systemExclusive([0x7f, 0x7f, 0x04, 0x01, 0x64, 0x00, 0xf7])) == nil)   // Master volume
        #expect(MIDITuningMessage(.systemExclusive([0x41, 0x7f, 0x08, 0x00, 0x05, 0xf7])) == nil)   // Not universal
        #expect(MIDITuningMessage(.systemExclusive([0x7e, 0x7f, 0x08, 0x0a, 0x05, 0xf7])) == nil)   // Unknown sub-ID
    }

    @Test
    func decode_rejectsBadChecksum() throws {
        let contents: [MIDITuningMessage.Content] = [.keyBasedDump(MIDITuningLocation(program: 5, bank: 2),
                                                                   name: name,
                                                                   frequencies: frequencies),
                                                     .scaleOctaveDump(bank: 2, program: 5, name: name, offsets: coarse),
                                                     .scaleOctaveDump(bank: 2, program: 5, name: name, offsets: fine)]

        for content in contents {
            let message = try #require(MIDITuningMessage(content: content).systemMessage)

            #expect(MIDITuningMessage(message) != nil)
            #expect(MIDITuningMessage(corruptingChecksum(of: message)) == nil)
        }
    }

    @Test
    func decode_scaleOctaveDump() throws {
        let content = MIDITuningMessage.Content.scaleOctaveDump(bank: 2, program: 5, name: name, offsets: fine)
        let message = try #require(MIDITuningMessage(content: content).systemMessage)

        #expect(MIDITuningMessage(message)?.content == content)
    }

    @Test
    func decode_scaleOctaveTuning() {
        let bytes: [UInt8] = [0x7f, 0x7f, 0x08, 0x08, 0x02, 0x41, 0x01]
                             + [0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45]
                             + [0xf7]

        #expect(MIDITuningMessage(.systemExclusive(bytes))?.content == .scaleOctaveTuning(channels: [1, 8, 14, 16],
                                                                                          offsets: coarse,
                                                                                          realTime: true))
    }

    @Test
    func decode_singleNoteChange() {
        let bytes: [UInt8] = [0x7f, 0x7f, 0x08, 0x02, 0x03, 0x02] + [0x45, 0x45, 0x00, 0x00, 0x46, 0x7f, 0x7f, 0x7f, 0xf7]
        let changes = [MIDITuningChange(key: 0x45, frequency: MIDITuningFrequency(semitone: 0x45)),
                       MIDITuningChange(key: 0x46, frequency: .noChange)]

        #expect(MIDITuningMessage(.systemExclusive(bytes))?.content
                == .singleNoteChange(MIDITuningLocation(program: 3), changes: changes, realTime: true))
    }

    @Test
    func decode_singleNoteChange_wrongCount() {
        let bytes: [UInt8] = [0x7f, 0x7f, 0x08, 0x02, 0x03, 0x02, 0x45, 0x45, 0x00, 0x00, 0xf7]

        #expect(MIDITuningMessage(.systemExclusive([0x7f, 0x7f, 0x08, 0x02, 0x03, 0x00, 0xf7])) == nil)
        #expect(MIDITuningMessage(.systemExclusive(bytes)) == nil)
        #expect(MIDITuningMessage(.systemExclusive([0x7f, 0x7f, 0x08, 0x02, 0x03, 0xf7])) == nil)
    }

    @Test
    func decode_wrongHeaderForSubID() {
        let nonRealTimeChange: [UInt8] = [0x7e, 0x7f, 0x08, 0x02, 0x03, 0x01, 0x45, 0x45, 0x00, 0x00, 0xf7]

        #expect(MIDITuningMessage(.systemExclusive([0x7f, 0x7f, 0x08, 0x00, 0x05, 0xf7])) == nil)   // Real-time request
        #expect(MIDITuningMessage(.systemExclusive(nonRealTimeChange)) == nil)
    }

    @Test
    func envelope() {
        let location = MIDITuningLocation(program: 5)
        let change = MIDITuningChange(key: 69, frequency: .noChange)

        #expect(MIDITuningMessage(content: .dumpRequest(location)).envelope
                == .universal(.tuning, deviceID: 127, payload: [0x00, 0x05]))
        #expect(MIDITuningMessage(content: .singleNoteChange(location, changes: [change], realTime: true), deviceID: 3).envelope
                == .universal(.realTimeTuning, deviceID: 3, payload: [0x02, 0x05, 0x01, 0x45, 0x7f, 0x7f, 0x7f]))
    }

    @Test
    func hashable() {
        let message = MIDITuningMessage(content: .dumpRequest(MIDITuningLocation(program: 5)))
        let other = MIDITuningMessage(content: .dumpRequest(MIDITuningLocation(program: 5)), deviceID: 0x10)

        #expect(Set([message, message, other]).count == 2)
    }

    @Test
    func init_content() {
        let content = MIDITuningMessage.Content.dumpRequest(MIDITuningLocation(program: 5))

        #expect(MIDITuningMessage(content: content).content == content)
        #expect(MIDITuningMessage(content: content).deviceID == 0x7f)
        #expect(MIDITuningMessage(content: content, deviceID: 0x10).deviceID == 0x10)
    }

    @Test
    func init_envelope_dataByteAbove7F() {
        #expect(MIDITuningMessage(MIDISysExEnvelope.universal(.tuning, deviceID: 127, payload: [0x00, 0x85])) == nil)
    }

    @Test
    func init_envelope_emptyPayload() {
        #expect(MIDITuningMessage(MIDISysExEnvelope.universal(.tuning, deviceID: 127, payload: [])) == nil)
    }

    @Test
    func init_envelope_otherOwners() {
        #expect(MIDITuningMessage(MIDISysExEnvelope.manufacturer(.yamaha, payload: [0x00, 0x05])) == nil)
        #expect(MIDITuningMessage(MIDISysExEnvelope.nonCommercial(payload: [0x00, 0x05])) == nil)
        #expect(MIDITuningMessage(MIDISysExEnvelope.universal(.generalInformation, deviceID: 127, payload: [0x00, 0x05])) == nil)
    }

    @Test
    func roundTrip() throws {
        let change = MIDITuningChange(key: 69, frequency: MIDITuningFrequency(semitone: 69, fraction: 300))
        let program = MIDITuningLocation(program: 5)
        let bank = MIDITuningLocation(program: 5, bank: 2)
        let contents: [MIDITuningMessage.Content] = [.dumpRequest(program),
                                                     .dumpRequest(bank),
                                                     .keyBasedDump(program, name: name, frequencies: frequencies),
                                                     .keyBasedDump(bank, name: name, frequencies: frequencies),
                                                     .scaleOctaveDump(bank: 2, program: 5, name: name, offsets: coarse),
                                                     .scaleOctaveDump(bank: 2, program: 5, name: name, offsets: fine),
                                                     .singleNoteChange(program, changes: [change, change], realTime: true),
                                                     .singleNoteChange(bank, changes: [change], realTime: true),
                                                     .singleNoteChange(bank, changes: [change], realTime: false),
                                                     .scaleOctaveTuning(channels: [1, 8, 16], offsets: coarse, realTime: false),
                                                     .scaleOctaveTuning(channels: [1, 8, 16], offsets: coarse, realTime: true),
                                                     .scaleOctaveTuning(channels: [7, 14, 15], offsets: fine, realTime: false),
                                                     .scaleOctaveTuning(channels: [7, 14, 15], offsets: fine, realTime: true)]

        for content in contents {
            let original = MIDITuningMessage(content: content, deviceID: 0x10)
            let message = try #require(original.systemMessage)
            let decoded = try #require(MIDITuningMessage(message))

            #expect(decoded == original)
            #expect(decoded.systemMessage == message)
        }
    }

    @Test
    func systemMessage_bulkDump() throws {
        let bytes = try #require(tuningBytes(.keyBasedDump(programZero, name: "", frequencies: flatFrequencies)))

        #expect(bytes.count == 4 + 1 + 16 + 384 + 2)
        #expect(Array(bytes[0...4]) == [0x7e, 0x7f, 0x08, 0x01, 0x00])
        #expect(Array(bytes[5...20]) == [UInt8](repeating: 0x20, count: 16))
        #expect(Array(bytes[21...23]) == [0x45, 0x00, 0x00])
        #expect(bytes[bytes.count - 2] == 0x00)         // 7E ^ 7F ^ 01 ^ tt, without sub-ID#1
        #expect(bytes.last == 0xf7)
    }

    @Test
    func systemMessage_bulkDump_badArguments() {
        #expect(tuningBytes(.keyBasedDump(programZero, name: "", frequencies: Array(noChanges.dropLast()))) == nil)
        #expect(tuningBytes(.keyBasedDump(programZero, name: "é", frequencies: noChanges)) == nil)
    }

    @Test
    func systemMessage_defaultDeviceID() {
        let message = MIDITuningMessage(content: .dumpRequest(MIDITuningLocation(program: 5)))

        #expect(message.systemMessage == .systemExclusive([0x7e, 0x7f, 0x08, 0x00, 0x05, 0xf7]))
    }

    @Test
    func systemMessage_dumpRequest() {
        let content = MIDITuningMessage.Content.dumpRequest(MIDITuningLocation(program: 5))

        #expect(tuningBytes(content) == [0x7e, 0x7f, 0x08, 0x00, 0x05, 0xf7])
        #expect(tuningBytes(content, deviceID: 0x10) == [0x7e, 0x10, 0x08, 0x00, 0x05, 0xf7])
    }

    @Test
    func systemMessage_dumpRequest_bank() {
        let content = MIDITuningMessage.Content.dumpRequest(MIDITuningLocation(program: 5, bank: 2))

        #expect(tuningBytes(content) == [0x7e, 0x7f, 0x08, 0x03, 0x02, 0x05, 0xf7])
        #expect(tuningBytes(content, deviceID: 0x10) == [0x7e, 0x10, 0x08, 0x03, 0x02, 0x05, 0xf7])
    }

    @Test
    func systemMessage_keyBasedDump() throws {
        let bytes = try #require(tuningBytes(.keyBasedDump(bankZero, name: "", frequencies: flatFrequencies)))

        #expect(bytes.count == 4 + 2 + 16 + 384 + 2)
        #expect(Array(bytes[0...5]) == [0x7e, 0x7f, 0x08, 0x04, 0x00, 0x00])
        #expect(bytes[bytes.count - 2] == 0x0d)         // 7E ^ 7F ^ 08 ^ 04
        #expect(bytes.last == 0xf7)
    }

    @Test
    func systemMessage_keyBasedDump_badArguments() {
        #expect(tuningBytes(.keyBasedDump(bankZero, name: "", frequencies: noChanges + [.noChange])) == nil)
        #expect(tuningBytes(.keyBasedDump(bankZero, name: "seventeen letters", frequencies: noChanges)) == nil)
    }

    @Test
    func systemMessage_scaleOctaveDump_checksumIsSevenBitAndCoversBody() throws {
        let offsets: [MIDIData1Value] = [0x01, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40]
        let bytes = try #require(tuningBytes(.scaleOctaveDump(bank: 3, program: 7, name: "A", offsets: .coarse(offsets)),
                                             deviceID: 0x10))
        let body = bytes.dropLast(2)

        #expect(bytes[bytes.count - 2] == body.reduce(0, ^) & 0x7f)
    }

    @Test
    func systemMessage_scaleOctaveDump_fineOffsets() throws {
        let bytes = try #require(tuningBytes(.scaleOctaveDump(bank: 0, program: 0, name: "", offsets: centeredFine)))

        #expect(bytes.count == 4 + 2 + 16 + 24 + 2)
        #expect(Array(bytes[0...5]) == [0x7e, 0x7f, 0x08, 0x06, 0x00, 0x00])
        #expect(Array(bytes[22...23]) == [0x40, 0x00])
        #expect(bytes[bytes.count - 2] == 0x0f)         // 7E ^ 7F ^ 08 ^ 06
        #expect(bytes.last == 0xf7)
    }

    @Test
    func systemMessage_scaleOctaveDump_offsets() throws {
        let bytes = try #require(tuningBytes(.scaleOctaveDump(bank: 0, program: 0, name: "", offsets: centered)))

        #expect(bytes.count == 4 + 2 + 16 + 12 + 2)
        #expect(Array(bytes[0...5]) == [0x7e, 0x7f, 0x08, 0x05, 0x00, 0x00])
        #expect(Array(bytes[22...33]) == [UInt8](repeating: 0x40, count: 12))
        #expect(bytes[bytes.count - 2] == 0x0c)         // 7E ^ 7F ^ 08 ^ 05
        #expect(bytes.last == 0xf7)
    }

    @Test
    func systemMessage_scaleOctaveDump_wrongOffsetCount() {
        #expect(tuningBytes(.scaleOctaveDump(bank: 0, program: 0, name: "", offsets: .coarse([0x40]))) == nil)
        #expect(tuningBytes(.scaleOctaveDump(bank: 0, program: 0, name: "", offsets: .fine([8_192]))) == nil)
    }

    @Test
    func systemMessage_scaleOctaveTuning() {
        let offsets: [MIDIData1Value] = [0x40, 0x3e, 0x40, 0x42, 0x40, 0x40, 0x3e, 0x40, 0x3e, 0x40, 0x42, 0x40]

        #expect(tuningBytes(.scaleOctaveTuning(channels: [1], offsets: .coarse(offsets), realTime: false))
                == [0x7e, 0x7f, 0x08, 0x08, 0x00, 0x00, 0x01]
                + [0x40, 0x3e, 0x40, 0x42, 0x40, 0x40, 0x3e, 0x40, 0x3e, 0x40, 0x42, 0x40]
                + [0xf7])
    }

    @Test
    func systemMessage_scaleOctaveTuning_channelBits() {
        let channelBytes = { (channels: [MIDIChannel]) in
            tuningBytes(.scaleOctaveTuning(channels: channels, offsets: centered, realTime: false))?[4...6].map(\.self)
        }

        #expect(channelBytes([]) == [0x00, 0x00, 0x00])
        #expect(channelBytes([7]) == [0x00, 0x00, 0x40])
        #expect(channelBytes([8]) == [0x00, 0x01, 0x00])
        #expect(channelBytes([14]) == [0x00, 0x40, 0x00])
        #expect(channelBytes([15, 16]) == [0x03, 0x00, 0x00])
        #expect(channelBytes((1...16).compactMap { MIDIChannel(uintValue: $0) }) == [0x03, 0x7f, 0x7f])
    }

    @Test
    func systemMessage_scaleOctaveTuning_deviceID() {
        let bytes = tuningBytes(.scaleOctaveTuning(channels: [1], offsets: centered, realTime: false), deviceID: 0x10)

        #expect(bytes?.prefix(4) == [0x7e, 0x10, 0x08, 0x08])
    }

    @Test
    func systemMessage_scaleOctaveTuning_fineOffsets() {
        let offsets: [MIDIData2Value] = [0, 8_192, 16_383, 8_192, 8_192, 8_192, 8_192, 8_192, 8_192, 8_192, 8_192, 8_192]

        #expect(tuningBytes(.scaleOctaveTuning(channels: [1, 16], offsets: .fine(offsets), realTime: false))
                == [0x7e, 0x7f, 0x08, 0x09, 0x02, 0x00, 0x01, 0x00, 0x00, 0x40, 0x00, 0x7f, 0x7f]
                + [[UInt8]](repeating: [0x40, 0x00], count: 9).flatMap(\.self)
                + [0xf7])
    }

    @Test
    func systemMessage_scaleOctaveTuning_fineOffsets_realTime() {
        let bytes = tuningBytes(.scaleOctaveTuning(channels: [10], offsets: centeredFine, realTime: true), deviceID: 0x10)

        #expect(bytes?.prefix(7) == [0x7f, 0x10, 0x08, 0x09, 0x00, 0x04, 0x00])
    }

    @Test
    func systemMessage_scaleOctaveTuning_fineOffsets_wrongOffsetCount() {
        let offsets = [MIDIData2Value](repeating: 8_192, count: 11)

        #expect(tuningBytes(.scaleOctaveTuning(channels: [1], offsets: .fine(offsets), realTime: false)) == nil)
    }

    @Test
    func systemMessage_scaleOctaveTuning_realTime() {
        let bytes = tuningBytes(.scaleOctaveTuning(channels: [10], offsets: centered, realTime: true))

        #expect(bytes?.prefix(7) == [0x7f, 0x7f, 0x08, 0x08, 0x00, 0x04, 0x00])
    }

    @Test
    func systemMessage_scaleOctaveTuning_wrongOffsetCount() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 11)

        #expect(tuningBytes(.scaleOctaveTuning(channels: [1], offsets: .coarse(offsets), realTime: false)) == nil)
        #expect(tuningBytes(.scaleOctaveTuning(channels: [1], offsets: .coarse(offsets + [0x40, 0x40]), realTime: false)) == nil)
    }

    @Test
    func systemMessage_singleNoteChange() {
        let changes = [MIDITuningChange(key: 69, frequency: MIDITuningFrequency(semitone: 0x45)),
                       MIDITuningChange(key: 70, frequency: .noChange)]
        let location = MIDITuningLocation(program: 3)

        #expect(tuningBytes(.singleNoteChange(location, changes: changes, realTime: true))
                == [0x7f, 0x7f, 0x08, 0x02, 0x03, 0x02, 0x45, 0x45, 0x00, 0x00, 0x46, 0x7f, 0x7f, 0x7f, 0xf7])
    }

    @Test
    func systemMessage_singleNoteChange_bank() {
        let changes = [MIDITuningChange(key: 69, frequency: MIDITuningFrequency(semitone: 0x45))]
        let location = MIDITuningLocation(program: 3, bank: 2)

        #expect(tuningBytes(.singleNoteChange(location, changes: changes, realTime: true))
                == [0x7f, 0x7f, 0x08, 0x07, 0x02, 0x03, 0x01, 0x45, 0x45, 0x00, 0x00, 0xf7])
        #expect(tuningBytes(.singleNoteChange(location, changes: changes, realTime: false))
                == [0x7e, 0x7f, 0x08, 0x07, 0x02, 0x03, 0x01, 0x45, 0x45, 0x00, 0x00, 0xf7])
    }

    @Test
    func systemMessage_singleNoteChange_changeCount() {
        let change = MIDITuningChange(key: 0, frequency: .noChange)
        let changes = { (count: Int) in [MIDITuningChange](repeating: change, count: count) }

        #expect(tuningBytes(.singleNoteChange(programZero, changes: changes(0), realTime: true)) == nil)
        #expect(tuningBytes(.singleNoteChange(programZero, changes: changes(128), realTime: true)) == nil)
        #expect(tuningBytes(.singleNoteChange(bankZero, changes: changes(0), realTime: true)) == nil)
        #expect(tuningBytes(.singleNoteChange(bankZero, changes: changes(128), realTime: true)) == nil)

        // The specification gives the total length as 8 + (ll × 4) bytes,
        // which is one more than the data bytes, because of the status byte.
        #expect(tuningBytes(.singleNoteChange(programZero, changes: changes(127), realTime: true))?.count == 8 + 127 * 4 - 1)
    }

    @Test
    func systemMessage_tuningName() {
        let bytes = { (name: String) in
            tuningBytes(.scaleOctaveDump(bank: 0, program: 0, name: name, offsets: centered))?[6...21].map(\.self)
        }

        #expect(bytes("Werckmeister") == Array("Werckmeister    ".utf8))
        #expect(bytes("sixteen  letters") == Array("sixteen  letters".utf8))
        #expect(bytes("seventeen letters") == nil)
    }

    @Test
    func systemMessage_uncodable() {
        let change = MIDITuningChange(key: 0, frequency: .noChange)

        #expect(tuningBytes(.singleNoteChange(programZero, changes: [change], realTime: false)) == nil)
        #expect(tuningBytes(.singleNoteChange(programZero, changes: [], realTime: true)) == nil)
        #expect(tuningBytes(.keyBasedDump(programZero, name: "", frequencies: [])) == nil)
        #expect(tuningBytes(.scaleOctaveTuning(channels: [1], offsets: .coarse([]), realTime: false)) == nil)
        #expect(tuningBytes(.scaleOctaveDump(bank: 0, program: 0, name: "é", offsets: coarse)) == nil)
    }
}
