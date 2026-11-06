// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorMIDI
import Testing

struct TX81ZTuningPresetTests {
}

// MARK: -

extension TX81ZTuningPresetTests {
    @Test
    func allCases() {
        #expect(TX81ZTuningPreset.allCases.count == 11)
    }

    @Test
    func codable() throws {
        let data = try JSONEncoder().encode(TX81ZTuningPreset.werckmeister)

        #expect(try JSONDecoder().decode(TX81ZTuningPreset.self, from: data) == .werckmeister)
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        #expect(Set(TX81ZTuningPreset.allCases).count == TX81ZTuningPreset.allCases.count)
    }

    @Test
    func rawValues() {
        let manualOrder: [TX81ZTuningPreset] = [.equal,
                                                .pureMajor,
                                                .pureMinor,
                                                .meanTone,
                                                .pythagorean,
                                                .werckmeister,
                                                .kirnberger,
                                                .vallottiYoung,
                                                .quarterShift,
                                                .quarterTone,
                                                .eighthTone]

        #expect(manualOrder.map(\.rawValue) == Array(1...11))
    }

    @Test
    func usesKey() {
        let presets = TX81ZTuningPreset.allCases.filter(\.usesKey)

        #expect(Set(presets) == [.pureMajor, .pureMinor, .meanTone, .pythagorean])
    }
}
