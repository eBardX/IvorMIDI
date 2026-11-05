// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDITuningMessageTests {
    private let coarse = MIDITuningOffsets.coarse((0..<12).map { MIDIData1Value(clamping: 58 + $0) })
    private let fine = MIDITuningOffsets.fine((0..<12).map { MIDIData2Value(clamping: 8_000 + $0 * 37) })
    private let frequencies = (0..<128).map { MIDITuningFrequency(semitone: MIDIData1Value(clamping: $0), fraction: 5) }
    private let name = "Werckmeister III"
}

// MARK: -

extension MIDITuningMessageTests {
    @Test
    func decode_bulkDumpIgnoresChecksum() throws {
        let message = try #require(MIDISystemMessage.bulkTuningDump(program: 5, name: name, frequencies: frequencies))

        #expect(MIDITuningMessage(corruptingChecksum(of: message)) != nil)
    }

    @Test
    func decode_dumpRequest() {
        let message = MIDITuningMessage(.bulkTuningDumpRequest(bank: 2, program: 5))

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
        let message = try #require(MIDISystemMessage.bulkTuningDump(program: 5, name: "Just", frequencies: frequencies))

        #expect(MIDITuningMessage(message)?.content == .keyBasedDump(MIDITuningLocation(program: 5),
                                                                     name: "Just",
                                                                     frequencies: frequencies))
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
        let message = try #require(MIDISystemMessage.scaleOctaveTuningDump(bank: 0,
                                                                           program: 0,
                                                                           name: "a b  ",
                                                                           offsets: coarse))

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
        #expect(MIDITuningMessage(.masterVolume(100)) == nil)
        #expect(MIDITuningMessage(.systemExclusive([0x41, 0x7f, 0x08, 0x00, 0x05, 0xf7])) == nil)   // Not universal
        #expect(MIDITuningMessage(.systemExclusive([0x7e, 0x7f, 0x08, 0x0a, 0x05, 0xf7])) == nil)   // Unknown sub-ID
    }

    @Test
    func decode_rejectsBadChecksum() throws {
        let dumps = [MIDISystemMessage.keyBasedTuningDump(bank: 2, program: 5, name: name, frequencies: frequencies),
                     .scaleOctaveTuningDump(bank: 2, program: 5, name: name, offsets: coarse),
                     .scaleOctaveTuningDump(bank: 2, program: 5, name: name, offsets: fine)]

        for dump in dumps {
            let message = try #require(dump)

            #expect(MIDITuningMessage(message) != nil)
            #expect(MIDITuningMessage(corruptingChecksum(of: message)) == nil)
        }
    }

    @Test
    func decode_scaleOctaveDump() throws {
        let message = try #require(MIDISystemMessage.scaleOctaveTuningDump(bank: 2,
                                                                           program: 5,
                                                                           name: name,
                                                                           offsets: fine))

        #expect(MIDITuningMessage(message)?.content == .scaleOctaveDump(bank: 2,
                                                                        program: 5,
                                                                        name: name,
                                                                        offsets: fine))
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
        let bytes: [UInt8] = [0x7f,
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
                              0xf7]
        let changes = [MIDITuningChange(key: 0x45, frequency: MIDITuningFrequency(semitone: 0x45)),
                       MIDITuningChange(key: 0x46, frequency: .noChange)]

        #expect(MIDITuningMessage(.systemExclusive(bytes))?.content
                == .singleNoteChange(MIDITuningLocation(program: 3), changes: changes, realTime: true))
    }

    @Test
    func decode_singleNoteChange_wrongCount() {
        #expect(MIDITuningMessage(.systemExclusive([0x7f, 0x7f, 0x08, 0x02, 0x03, 0x00, 0xf7])) == nil)
        #expect(MIDITuningMessage(.systemExclusive([0x7f,
                                                    0x7f,
                                                    0x08,
                                                    0x02,
                                                    0x03,
                                                    0x02,
                                                    0x45,
                                                    0x45,
                                                    0x00,
                                                    0x00,
                                                    0xf7])) == nil)
        #expect(MIDITuningMessage(.systemExclusive([0x7f, 0x7f, 0x08, 0x02, 0x03, 0xf7])) == nil)
    }

    @Test
    func decode_wrongHeaderForSubID() {
        #expect(MIDITuningMessage(.systemExclusive([0x7f, 0x7f, 0x08, 0x00, 0x05, 0xf7])) == nil)   // Real-time request
        #expect(MIDITuningMessage(.systemExclusive([0x7e,
                                                    0x7f,
                                                    0x08,
                                                    0x02,
                                                    0x03,
                                                    0x01,
                                                    0x45,
                                                    0x45,
                                                    0x00,
                                                    0x00,
                                                    0xf7])) == nil)         // Non-real-time 02
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
    func roundTrip() throws {
        let change = MIDITuningChange(key: 69, frequency: MIDITuningFrequency(semitone: 69, fraction: 300))
        let messages: [MIDISystemMessage?] = [.bulkTuningDumpRequest(program: 5, deviceID: 0x10),
                                              .bulkTuningDumpRequest(bank: 2, program: 5, deviceID: 0x10),
                                              .bulkTuningDump(program: 5, name: name, frequencies: frequencies, deviceID: 0x10),
                                              .keyBasedTuningDump(bank: 2, program: 5, name: name, frequencies: frequencies, deviceID: 0x10),
                                              .scaleOctaveTuningDump(bank: 2, program: 5, name: name, offsets: coarse, deviceID: 0x10),
                                              .scaleOctaveTuningDump(bank: 2, program: 5, name: name, offsets: fine, deviceID: 0x10),
                                              .singleNoteTuningChange([change, change], program: 5, deviceID: 0x10),
                                              .singleNoteTuningChange([change], bank: 2, program: 5, deviceID: 0x10),
                                              .singleNoteTuningChange([change], bank: 2, program: 5, realTime: false, deviceID: 0x10),
                                              .scaleOctaveTuning(channels: [1, 8, 16], offsets: coarse, deviceID: 0x10),
                                              .scaleOctaveTuning(channels: [1, 8, 16], offsets: coarse, realTime: true, deviceID: 0x10),
                                              .scaleOctaveTuning(channels: [7, 14, 15], offsets: fine, deviceID: 0x10),
                                              .scaleOctaveTuning(channels: [7, 14, 15], offsets: fine, realTime: true, deviceID: 0x10)]

        for message in messages {
            let original = try #require(message)
            let decoded = try #require(MIDITuningMessage(original))

            #expect(decoded.deviceID == 0x10)
            #expect(decoded.systemMessage == original)
        }
    }

    @Test
    func systemMessage_defaultDeviceID() {
        let message = MIDITuningMessage(content: .dumpRequest(MIDITuningLocation(program: 5)))

        #expect(message.systemMessage == .bulkTuningDumpRequest(program: 5))
    }

    @Test
    func systemMessage_uncodable() {
        let change = MIDITuningChange(key: 0, frequency: .noChange)
        let location = MIDITuningLocation(program: 0)

        #expect(MIDITuningMessage(content: .singleNoteChange(location, changes: [change], realTime: false))
            .systemMessage == nil)
        #expect(MIDITuningMessage(content: .singleNoteChange(location, changes: [], realTime: true))
            .systemMessage == nil)
        #expect(MIDITuningMessage(content: .keyBasedDump(location, name: "", frequencies: []))
            .systemMessage == nil)
        #expect(MIDITuningMessage(content: .scaleOctaveTuning(channels: [1], offsets: .coarse([]), realTime: false))
            .systemMessage == nil)
        #expect(MIDITuningMessage(content: .scaleOctaveDump(bank: 0, program: 0, name: "é", offsets: coarse))
            .systemMessage == nil)
    }
}
