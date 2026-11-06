// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct TX81ZTuningTableTests {
}

// MARK: -

extension TX81ZTuningTableTests {
    @Test
    func allCases() {
        #expect(TX81ZTuningTable.allCases == [.fullKeyboard, .octave])
    }

    @Test
    func codable() throws {
        let data = try JSONEncoder().encode(TX81ZTuningTable.octave)

        #expect(try JSONDecoder().decode(TX81ZTuningTable.self, from: data) == .octave)
    }

    @Test
    func entryCount() {
        #expect(TX81ZTuningTable.fullKeyboard.entryCount == 128)
        #expect(TX81ZTuningTable.octave.entryCount == 12)
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        #expect(Set(TX81ZTuningTable.allCases).count == TX81ZTuningTable.allCases.count)
    }

    @Test
    func init_slot() {
        #expect(TX81ZTuningTable(slot: .tx81zFullKeyboard) == .fullKeyboard)
        #expect(TX81ZTuningTable(slot: .tx81zOctave) == .octave)
    }

    @Test
    func init_slot_unknown() {
        #expect(TX81ZTuningTable(slot: .table(2)) == nil)
        #expect(TX81ZTuningTable(slot: .program(bank: nil, 0)) == nil)
    }

    @Test
    func init_tagBytes() {
        #expect(TX81ZTuningTable(tagBytes: Array("LM  MCRTE1".utf8)) == .fullKeyboard)
        #expect(TX81ZTuningTable(tagBytes: Array("LM  MCRTE0".utf8)[...]) == .octave)
    }

    @Test(arguments: ["", "LM  MCRTE", "LM  MCRTE2", "LM MCRTE1", "LM  8976AE"])
    func init_tagBytes_unknown(tag: String) {
        #expect(TX81ZTuningTable(tagBytes: Array(tag.utf8)) == nil)
    }

    @Test
    func slot() {
        #expect(TX81ZTuningTable.fullKeyboard.slot == .tx81zFullKeyboard)
        #expect(TX81ZTuningTable.octave.slot == .tx81zOctave)
    }

    @Test
    func tagBytes() {
        #expect(TX81ZTuningTable.fullKeyboard.tagBytes == [0x4c, 0x4d, 0x20, 0x20, 0x4d, 0x43, 0x52, 0x54, 0x45, 0x31])
        #expect(TX81ZTuningTable.octave.tagBytes == [0x4c, 0x4d, 0x20, 0x20, 0x4d, 0x43, 0x52, 0x54, 0x45, 0x30])
    }
}
