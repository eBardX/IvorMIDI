// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIPatchTests {
}

// MARK: -

extension MIDIPatchTests {
    @Test
    func codable() throws {
        let original = MIDIPatch(program: 20,
                                 bank: 15_489)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIPatch.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func init_defaultsToNoBank() {
        #expect(MIDIPatch(program: 41).bank == nil)
    }

    @Test
    func selectionMessages_afterBankedPatch_resetsBank() {
        let previous = MIDIPatch(program: 20,
                                 bank: MIDIBank(msb: 121, lsb: 1))

        #expect(MIDIPatch(program: 41).selectionMessages(on: 3, after: previous) == [.controlChange(3, .bankSelectMSB, 0),
                                                                                     .controlChange(3, .bankSelectLSB, 0),
                                                                                     .programChange(3, 41)])
    }

    @Test
    func selectionMessages_banked_selectsBankThenProgram() {
        let patch = MIDIPatch(program: 20,
                              bank: MIDIBank(msb: 121, lsb: 1))

        #expect(patch.selectionMessages(on: 1, after: nil) == [.controlChange(1, .bankSelectMSB, 121),
                                                               .controlChange(1, .bankSelectLSB, 1),
                                                               .programChange(1, 20)])
    }

    @Test
    func selectionMessages_unbanked_isProgramOnly() {
        #expect(MIDIPatch(program: 41).selectionMessages(on: 2, after: nil) == [.programChange(2, 41)])
        #expect(MIDIPatch(program: 41).selectionMessages(on: 2, after: MIDIPatch(program: 20)) == [.programChange(2, 41)])
    }
}
