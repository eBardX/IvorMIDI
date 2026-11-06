// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing

struct TX81ZTuningSelectionTests {
}

// MARK: -

extension TX81ZTuningSelectionTests {
    @Test
    func codable() throws {
        let original = TX81ZTuningSelection.preset(.werckmeister)
        let data = try JSONEncoder().encode(original)

        #expect(try JSONDecoder().decode(TX81ZTuningSelection.self, from: data) == original)
    }

    @Test
    func dataByte_order() {
        // Octave, Full, then presets. Edisyn puts the presets first.
        #expect(TX81ZTuningSelection.table(.octave).dataByte == 0)
        #expect(TX81ZTuningSelection.table(.fullKeyboard).dataByte == 1)
        #expect(TX81ZTuningSelection.preset(.equal).dataByte == 2)
        #expect(TX81ZTuningSelection.preset(.eighthTone).dataByte == 12)
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let selections: [TX81ZTuningSelection] = [.preset(.equal),
                                                  .preset(.pureMajor),
                                                  .table(.fullKeyboard),
                                                  .table(.octave)]

        #expect(Set(selections).count == selections.count)
    }

    @Test
    func init_dataByte_invalid() {
        #expect(TX81ZTuningSelection(dataByte: 13) == nil)
        #expect(TX81ZTuningSelection(dataByte: 0xff) == nil)
    }

    @Test(arguments: 0...12)
    func init_dataByte_roundTrip(value: Int) {
        let byte = UInt8(value)

        #expect(TX81ZTuningSelection(dataByte: byte)?.dataByte == byte)
    }
}
