// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDISysExUniversalIDTests {
}

// MARK: -

extension MIDISysExUniversalIDTests {
    @Test
    func codable() throws {
        let original = MIDISysExUniversalID.realTimeTuning
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDISysExUniversalID.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidSubIDThrows() {
        let data = Data(#"{"realTime":false,"subID":128}"#.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDISysExUniversalID.self,
                                     from: data)
        }
    }

    @Test
    func constants() {
        #expect(MIDISysExUniversalID.deviceControl == MIDISysExUniversalID(realTime: true, subID: 0x04))
        #expect(MIDISysExUniversalID.generalInformation == MIDISysExUniversalID(realTime: false, subID: 0x06))
        #expect(MIDISysExUniversalID.generalMIDI == MIDISysExUniversalID(realTime: false, subID: 0x09))
        #expect(MIDISysExUniversalID.realTimeTuning == MIDISysExUniversalID(realTime: true, subID: 0x08))
        #expect(MIDISysExUniversalID.tuning == MIDISysExUniversalID(realTime: false, subID: 0x08))
    }

    @Test
    func hashable() {
        let set: Set<MIDISysExUniversalID> = [.tuning,
                                              .tuning,
                                              .realTimeTuning]

        #expect(set.count == 2)
    }

    @Test
    func inequality_sameSubIDDifferentHeader() {
        #expect(MIDISysExUniversalID(realTime: false, subID: 0x04) != .deviceControl)
    }

    @Test
    func init_storesValues() {
        let id = MIDISysExUniversalID(realTime: true,
                                      subID: 0x0a)

        #expect(id.realTime)
        #expect(id.subID == 0x0a)
    }
}
