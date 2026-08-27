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
        #expect(MIDIController.allNotesOff.uintValue == 123)
        #expect(MIDIController.allSoundOff.uintValue == 120)
        #expect(MIDIController.attackTime.uintValue == 73)
        #expect(MIDIController.balanceLSB.uintValue == 40)
        #expect(MIDIController.balanceMSB.uintValue == 8)
        #expect(MIDIController.bankSelectLSB.uintValue == 32)
        #expect(MIDIController.bankSelectMSB.uintValue == 0)
        #expect(MIDIController.breathControllerLSB.uintValue == 34)
        #expect(MIDIController.breathControllerMSB.uintValue == 2)
        #expect(MIDIController.brightness.uintValue == 74)
        #expect(MIDIController.celesteDepth.uintValue == 94)
        #expect(MIDIController.channelVolumeLSB.uintValue == 39)
        #expect(MIDIController.channelVolumeMSB.uintValue == 7)
        #expect(MIDIController.chorusSendLevel.uintValue == 93)
        #expect(MIDIController.dataDecrement.uintValue == 97)
        #expect(MIDIController.dataEntryLSB.uintValue == 38)
        #expect(MIDIController.dataEntryMSB.uintValue == 6)
        #expect(MIDIController.dataIncrement.uintValue == 96)
        #expect(MIDIController.decayTime.uintValue == 75)
        #expect(MIDIController.effectControl1LSB.uintValue == 44)
        #expect(MIDIController.effectControl1MSB.uintValue == 12)
        #expect(MIDIController.effectControl2LSB.uintValue == 45)
        #expect(MIDIController.effectControl2MSB.uintValue == 13)
        #expect(MIDIController.expressionControllerLSB.uintValue == 43)
        #expect(MIDIController.expressionControllerMSB.uintValue == 11)
        #expect(MIDIController.footControllerLSB.uintValue == 36)
        #expect(MIDIController.footControllerMSB.uintValue == 4)
        #expect(MIDIController.generalPurposeController1LSB.uintValue == 48)
        #expect(MIDIController.generalPurposeController1MSB.uintValue == 16)
        #expect(MIDIController.generalPurposeController2LSB.uintValue == 49)
        #expect(MIDIController.generalPurposeController2MSB.uintValue == 17)
        #expect(MIDIController.generalPurposeController3LSB.uintValue == 50)
        #expect(MIDIController.generalPurposeController3MSB.uintValue == 18)
        #expect(MIDIController.generalPurposeController4LSB.uintValue == 51)
        #expect(MIDIController.generalPurposeController4MSB.uintValue == 19)
        #expect(MIDIController.generalPurposeController5.uintValue == 80)
        #expect(MIDIController.generalPurposeController6.uintValue == 81)
        #expect(MIDIController.generalPurposeController7.uintValue == 82)
        #expect(MIDIController.generalPurposeController8.uintValue == 83)
        #expect(MIDIController.harmonicContent.uintValue == 71)
        #expect(MIDIController.highResolutionVelocityPrefix.uintValue == 88)
        #expect(MIDIController.hold2.uintValue == 69)
        #expect(MIDIController.legato.uintValue == 68)
        #expect(MIDIController.localControl.uintValue == 122)
        #expect(MIDIController.modulationWheelLSB.uintValue == 33)
        #expect(MIDIController.modulationWheelMSB.uintValue == 1)
        #expect(MIDIController.monoModeOn.uintValue == 126)
        #expect(MIDIController.nonRegisteredParameterNumberLSB.uintValue == 98)
        #expect(MIDIController.nonRegisteredParameterNumberMSB.uintValue == 99)
        #expect(MIDIController.omniModeOff.uintValue == 124)
        #expect(MIDIController.omniModeOn.uintValue == 125)
        #expect(MIDIController.panLSB.uintValue == 42)
        #expect(MIDIController.panMSB.uintValue == 10)
        #expect(MIDIController.phaserDepth.uintValue == 95)
        #expect(MIDIController.polyModeOn.uintValue == 127)
        #expect(MIDIController.portamento.uintValue == 65)
        #expect(MIDIController.portamentoControl.uintValue == 84)
        #expect(MIDIController.portamentoTimeLSB.uintValue == 37)
        #expect(MIDIController.portamentoTimeMSB.uintValue == 5)
        #expect(MIDIController.registeredParameterNumberLSB.uintValue == 100)
        #expect(MIDIController.registeredParameterNumberMSB.uintValue == 101)
        #expect(MIDIController.releaseTime.uintValue == 72)
        #expect(MIDIController.resetAllControllers.uintValue == 121)
        #expect(MIDIController.reverbSendLevel.uintValue == 91)
        #expect(MIDIController.softPedal.uintValue == 67)
        #expect(MIDIController.sostenuto.uintValue == 66)
        #expect(MIDIController.soundVariation.uintValue == 70)
        #expect(MIDIController.sustain.uintValue == 64)
        #expect(MIDIController.tremoloDepth.uintValue == 92)
        #expect(MIDIController.vibratoDelay.uintValue == 78)
        #expect(MIDIController.vibratoDepth.uintValue == 77)
        #expect(MIDIController.vibratoRate.uintValue == 76)
    }
}
