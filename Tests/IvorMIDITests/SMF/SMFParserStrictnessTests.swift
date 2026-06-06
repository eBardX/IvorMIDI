// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFParserStrictnessTests {
}

// MARK: -

extension SMFParserStrictnessTests {
    @Test
    func equality() {
        #expect(SMFParser.Strictness.lenient == .lenient)
        #expect(SMFParser.Strictness.strict == .strict)
    }

    @Test
    func inequality() {
        #expect(SMFParser.Strictness.lenient != .strict)
    }
}
