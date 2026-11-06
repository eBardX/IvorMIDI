// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDIManufacturerIDAssignedTests {
}

// MARK: -

extension MIDIManufacturerIDAssignedTests {
    @Test(arguments: [(.ableton, [0x00, 0x21, 0x1d]),
                      (.access, [0x00, 0x20, 0x33]),
                      (.akai, [0x47]),
                      (.alesis, [0x00, 0x00, 0x0e]),
                      (.apple, [0x11]),
                      (.arturia, [0x00, 0x20, 0x6b]),
                      (.behringer, [0x00, 0x20, 0x32]),
                      (.casio, [0x44]),
                      (.clavia, [0x33]),
                      (.digidesign, [0x13]),
                      (.elektron, [0x00, 0x20, 0x3c]),
                      (.emu, [0x18]),
                      (.ensoniq, [0x0f]),
                      (.eventide, [0x1c]),
                      (.fender, [0x08]),
                      (.ikMultimedia, [0x00, 0x21, 0x1a]),
                      (.kawai, [0x40]),
                      (.korg, [0x42]),
                      (.kurzweil, [0x07]),
                      (.lexicon, [0x06]),
                      (.line6, [0x00, 0x01, 0x0c]),
                      (.mackie, [0x00, 0x00, 0x66]),
                      (.mAudio, [0x00, 0x01, 0x05]),
                      (.microsoft, [0x00, 0x00, 0x41]),
                      (.moog, [0x04]),
                      (.motu, [0x00, 0x00, 0x3b]),
                      (.nativeInstruments, [0x00, 0x21, 0x09]),
                      (.novation, [0x00, 0x20, 0x29]),
                      (.oberheim, [0x10]),
                      (.presonus, [0x00, 0x01, 0x06]),
                      (.roland, [0x41]),
                      (.roli, [0x00, 0x21, 0x10]),
                      (.sequential, [0x01]),
                      (.steinberg, [0x3a]),
                      (.teenageEngineering, [0x00, 0x20, 0x76]),
                      (.waldorf, [0x3e]),
                      (.yamaha, [0x43]),
                      (.zoom, [0x52])] as [(MIDIManufacturerID, [UInt8])])
    func constants(id: MIDIManufacturerID,
                   bytes: [UInt8]) {
        #expect(id.bytes == bytes)
        #expect(MIDIManufacturerID(bytes: bytes) == id)
    }
}
