// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDIControllerTests {
}

// MARK: -

extension MIDIControllerTests {
    @Test
    func bytesValue() {
        let controller = MIDIController(uintValue: 7)

        #expect(controller?.bytesValue == [0x07])
    }

    @Test
    func init_bytesValue() {
        let controller = MIDIController(bytesValue: [0x07])

        #expect(controller != nil)
        #expect(controller?.uintValue == 7)
    }

    @Test
    func init_bytesValue_invalidCount() {
        #expect(MIDIController(bytesValue: []) == nil)
        #expect(MIDIController(bytesValue: [0x01, 0x02]) == nil)
    }

    @Test
    func init_uintValue() {
        let controller = MIDIController(uintValue: 0)

        #expect(controller != nil)
        #expect(controller?.uintValue == 0)

        let controller127 = MIDIController(uintValue: 127)

        #expect(controller127 != nil)
        #expect(controller127?.uintValue == 127)
    }

    @Test
    func init_uintValue_invalid() {
        #expect(MIDIController(uintValue: 128) == nil)
    }

    @Test
    func isValid() {
        #expect(MIDIController.isValid(0))
        #expect(MIDIController.isValid(1))
        #expect(MIDIController.isValid(64))
        #expect(MIDIController.isValid(127))
        #expect(!MIDIController.isValid(128))
    }

    @Test
    func staticConstants() {
        #expect(MIDIController.bankSelectMSB.uintValue == 0)
        #expect(MIDIController.modulationWheelMSB.uintValue == 1)
        #expect(MIDIController.channelVolumeMSB.uintValue == 7)
        #expect(MIDIController.sustain.uintValue == 64)
        #expect(MIDIController.allNotesOff.uintValue == 123)
        #expect(MIDIController.polyModeOn.uintValue == 127)
    }
}
