// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct TX81ZTuningMessageTests {
    private let flat = [TX81ZPitch](repeating: TX81ZPitch(69), count: 128)
    private let flatBytes = [UInt8](repeating: 0x45, count: 256)
    private let fullTag = Array("LM  MCRTE1".utf8)
}

// MARK: -

extension TX81ZTuningMessageTests {
    @Test(arguments: Fixtures.tx81zChecksums)
    func checksums_allTunings(name: String, step: Double, checksum: UInt8) throws {
        let message = TX81ZTuningMessage(content: .dump(.fullKeyboard, pitches: Fixtures.tx81zPitches(step: step)),
                                         channel: 1)
        let bytes = try #require(message.systemMessage?.bytesValue)

        #expect(bytes.count == 274, "\(name)")
        #expect(bytes[272] == checksum, "\(name)")
    }

    @Test
    func decode_badChecksum() throws {
        let message = try #require(MIDISystemMessage(bytesValue: Fixtures.tx81z12TET))

        #expect(TX81ZTuningMessage(message) != nil)
        #expect(TX81ZTuningMessage(corruptingChecksum(of: message)) == nil)
    }

    @Test
    func decode_badTag() {
        let data = Array("LM  MCRTE2".utf8) + flatBytes

        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: tx81zDumpPayload(data))) == nil)
    }

    @Test
    func decode_checksumOmittingTag() throws {
        // Edisyn leaves the tag out of the checksum.
        var bytes = Fixtures.tx81z12TET

        bytes[272] = YamahaSysEx.checksum(bytes[16..<272])

        let message = try #require(MIDISystemMessage(bytesValue: bytes))

        #expect(TX81ZTuningMessage(message) == nil)
    }

    @Test
    func decode_dataByteAbove7F() {
        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: [0x10, 0x10, 96, 0x80])) == nil)
    }

    @Test
    func decode_fullDumpSizedLikeOctave() throws {
        // The p.69 misprint, also Edisyn’s bug.
        var bytes = Fixtures.tx81z12TET

        bytes[4] = 0x00
        bytes[5] = 0x22

        let message = try #require(MIDISystemMessage(bytesValue: bytes))

        #expect(TX81ZTuningMessage(message) == nil)
    }

    @Test(arguments: Fixtures.tx81zAllVectors)
    func decode_golden(bytes: [UInt8]) throws {
        let system = try #require(MIDISystemMessage(bytesValue: bytes))
        let message = try #require(TX81ZTuningMessage(system))

        #expect(message.channel == 1)
        #expect(message.systemMessage?.bytesValue == bytes)
    }

    @Test
    func decode_goldenContent() throws {
        let system = try #require(MIDISystemMessage(bytesValue: Fixtures.tx81z15TET))

        #expect(TX81ZTuningMessage(system)?.content == .dump(.fullKeyboard,
                                                             pitches: Fixtures.tx81zPitches(step: 12.0 / 15)))
    }

    @Test
    func decode_goldenOctaveContent() throws {
        let system = try #require(MIDISystemMessage(bytesValue: Fixtures.tx81zOctaveDump))

        guard case let .dump(table, pitches) = TX81ZTuningMessage(system)?.content
        else {
            Issue.record("Not a dump")
            return
        }

        #expect(table == .octave)
        #expect(pitches.count == 12)
        #expect(pitches.first?.bytesValue == [0x3c, 0x00])
        #expect(pitches.last?.bytesValue == [0x46, 0x25])
    }

    @Test
    func decode_invalidPitches() {
        for pair in [[12, 0], [109, 0], [69, 64]] as [[UInt8]] {
            let data = fullTag + pair + flatBytes.dropFirst(2)

            #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: tx81zDumpPayload(data))) == nil)
        }
    }

    @Test
    func decode_lengthenedDump() {
        let data = fullTag + flatBytes + [0x45, 0x00]

        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: tx81zDumpPayload(data))) == nil)
    }

    @Test
    func decode_otherKind() {
        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: [0x30, 0x10, 96, 0])) == nil)
    }

    @Test(arguments: [[0x10, 0x10, 12, 0],      // An unrelated PCED parameter
                      [0x10, 0x10, 97, 0],
                      [0x10, 0x10, 107, 0],
                      [0x10, 0x10, 11, 2],      // Enable above 1
                      [0x10, 0x10, 96, 13],     // Table above 12
                      [0x10, 0x10, 99, 12],     // Key above 11
                      [0x10, 0x13, 96, 0],      // The p.67 misprint
                      [0x10, 0x10, 96],
                      [0x10, 0x10, 96, 0, 0],
                      [0x10, 0x10, 0x7e, 69, 69, 0],
                      [0x10, 0x10, 0x7d, 9, 69, 0]] as [[UInt8]])
    func decode_otherParameter(payload: [UInt8]) {
        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: payload)) == nil)
    }

    @Test
    func decode_otherRequest() {
        let tag = Array("LM  8976AE".utf8)

        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: [0x20, 0x7e] + tag)) == nil)
        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: [0x20, 0x7e] + fullTag.dropLast())) == nil)
        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: [0x20, 0x7f] + fullTag)) == nil)
    }

    @Test
    func decode_tooShort() {
        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: [])) == nil)
        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: [0x00])) == nil)
    }

    @Test
    func decode_truncatedDump() {
        let data = fullTag + flatBytes.dropLast(2)

        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: tx81zDumpPayload(data))) == nil)
    }

    @Test
    func decode_wrongFormat() {
        let payload = YamahaSysEx.bulkDumpPayload(channel: 1, format: 0x7d, data: fullTag + flatBytes)

        #expect(TX81ZTuningMessage(.manufacturer(.yamaha, payload: payload)) == nil)
    }

    @Test
    func decode_wrongMaker() {
        #expect(TX81ZTuningMessage(.manufacturer(.korg, payload: [0x10, 0x10, 96, 0])) == nil)
        #expect(TX81ZTuningMessage(.nonCommercial(payload: [0x10, 0x10, 96, 0])) == nil)
        #expect(TX81ZTuningMessage(.universal(.tuning, deviceID: 127, payload: [0x10, 0x10, 96, 0])) == nil)
    }

    @Test
    func encode_channel16() {
        let channel: MIDIChannel = 16

        #expect(tx81zBytes(.dump(.octave, pitches: Array(flat.prefix(12))), channel)?[2] == 0x0f)
        #expect(tx81zBytes(.microTuneKey(0), channel)?[2] == 0x1f)
        #expect(tx81zBytes(.dumpRequest(.octave), channel)?[2] == 0x2f)
    }

    @Test
    func encode_dumpRequest() {
        #expect(tx81zBytes(.dumpRequest(.fullKeyboard), 1) == [0xf0, 0x43, 0x20, 0x7e] + fullTag + [0xf7])
    }

    @Test
    func encode_dumpSizes() throws {
        let full = try #require(TX81ZTuningMessage(content: .dump(.fullKeyboard, pitches: flat),
                                                   channel: 1).systemMessage?.dataBytes)
        let octave = try #require(TX81ZTuningMessage(content: .dump(.octave, pitches: Array(flat.prefix(12))),
                                                     channel: 1).systemMessage?.dataBytes)

        #expect(full.count == 273)
        #expect(Array(full[3...4]) == [0x02, 0x0a])
        #expect(octave.count == 41)
        #expect(Array(octave[3...4]) == [0x00, 0x22])
    }

    @Test(arguments: Fixtures.tx81zFullKeyboardVectors)
    func encode_golden(step: Double, bytes expected: [UInt8]) {
        #expect(tx81zBytes(.dump(.fullKeyboard, pitches: Fixtures.tx81zPitches(step: step)), 1) == expected)
    }

    @Test
    func encode_instruments() {
        #expect(tx81zBytes(.microTuneEnable(instrument: 1, isEnabled: true), 1) == [0xf0, 0x43, 0x10, 0x10, 11, 1, 0xf7])
        #expect(tx81zBytes(.microTuneEnable(instrument: 8, isEnabled: false), 1) == [0xf0, 0x43, 0x10, 0x10, 95, 0, 0xf7])
    }

    @Test
    func encode_invalidContent() {
        #expect(tx81zBytes(.dump(.fullKeyboard, pitches: Array(flat.dropLast())), 1) == nil)
        #expect(tx81zBytes(.dump(.octave, pitches: flat), 1) == nil)
        #expect(tx81zBytes(.microTuneEnable(instrument: 0, isEnabled: true), 1) == nil)
        #expect(tx81zBytes(.microTuneEnable(instrument: 9, isEnabled: true), 1) == nil)
        #expect(tx81zBytes(.microTuneKey(12), 1) == nil)
    }

    @Test
    func encode_parameters() {
        #expect(tx81zBytes(.microTuneTable(.table(.octave)), 1) == [0xf0, 0x43, 0x10, 0x10, 0x60, 0, 0xf7])
        #expect(tx81zBytes(.microTuneKey(11), 1) == [0xf0, 0x43, 0x10, 0x10, 0x63, 11, 0xf7])
    }

    @Test
    func envelope_splitsFraming() {
        #expect(TX81ZTuningMessage(content: .microTuneKey(3), channel: 2).envelope
                == .manufacturer(.yamaha, payload: [0x11, 0x10, 99, 3]))
    }

    @Test
    func hashable() {
        let message = TX81ZTuningMessage(content: .microTuneKey(3), channel: 1)
        let other = TX81ZTuningMessage(content: .microTuneKey(3), channel: 2)

        #expect(Set([message, message, other]).count == 2)
    }

    @Test
    func roundTrip() throws {
        let contents: [TX81ZTuningMessage.Content] = [.dump(.fullKeyboard, pitches: flat),
                                                      .dump(.octave, pitches: Array(flat.prefix(12))),
                                                      .dumpRequest(.fullKeyboard),
                                                      .dumpRequest(.octave),
                                                      .microTuneEnable(instrument: 1, isEnabled: true),
                                                      .microTuneEnable(instrument: 8, isEnabled: false),
                                                      .microTuneKey(0),
                                                      .microTuneKey(11),
                                                      .microTuneTable(.preset(.eighthTone)),
                                                      .microTuneTable(.table(.fullKeyboard)),
                                                      .microTuneTable(.table(.octave))]

        for content in contents {
            let original = TX81ZTuningMessage(content: content, channel: 16)
            let envelope = try #require(original.envelope)

            #expect(TX81ZTuningMessage(envelope) == original)
        }
    }
}
