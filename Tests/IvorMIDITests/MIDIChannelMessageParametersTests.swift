// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIChannelMessageParametersTests {
}

// MARK: -

extension MIDIChannelMessageParametersTests {
    @Test
    func dataDecrement() {
        #expect(MIDIChannelMessage.dataDecrement(on: 2) == .controlChange(2, .dataDecrement, 0))
        #expect(MIDIChannelMessage.dataDecrement(on: 2).bytesValue == [0xb1, 0x61, 0x00])
    }

    @Test
    func dataEntry() {
        #expect(MIDIChannelMessage.dataEntry(MIDIData2Value(msb: 0x60, lsb: 0x05),
                                             on: 3) == [.controlChange(3, .dataEntryMSB, 0x60),
                                                        .controlChange(3, .dataEntryLSB, 0x05)])
    }

    @Test
    func dataEntryMSB() {
        #expect(MIDIChannelMessage.dataEntryMSB(64, on: 1) == .controlChange(1, .dataEntryMSB, 64))
    }

    @Test
    func dataIncrement() {
        #expect(MIDIChannelMessage.dataIncrement(on: 2) == .controlChange(2, .dataIncrement, 0))
        #expect(MIDIChannelMessage.dataIncrement(on: 2).bytesValue == [0xb1, 0x60, 0x00])
    }

    @Test
    func nonRegisteredParameterChange_msb() {
        let messages = MIDIChannelMessage.nonRegisteredParameterChange(130,
                                                                       msb: 0x40,
                                                                       on: 1)

        #expect(messages.compactMap(\.bytesValue) == [[0xb0, 0x63, 0x01],
                                                      [0xb0, 0x62, 0x02],
                                                      [0xb0, 0x06, 0x40],
                                                      [0xb0, 0x65, 0x7f],
                                                      [0xb0, 0x64, 0x7f]])
    }

    @Test
    func nonRegisteredParameterChange_value() {
        let messages = MIDIChannelMessage.nonRegisteredParameterChange(130,
                                                                       value: MIDIData2Value(msb: 0x40, lsb: 0x10),
                                                                       on: 1)

        #expect(messages.compactMap(\.bytesValue) == [[0xb0, 0x63, 0x01],
                                                      [0xb0, 0x62, 0x02],
                                                      [0xb0, 0x06, 0x40],
                                                      [0xb0, 0x26, 0x10],
                                                      [0xb0, 0x65, 0x7f],
                                                      [0xb0, 0x64, 0x7f]])
    }

    @Test
    func nonRegisteredParameterSelect() {
        #expect(MIDIChannelMessage.nonRegisteredParameterSelect(16_383,
                                                                on: 16) == [.controlChange(16, .nonRegisteredParameterNumberMSB, 127),
                                                                            .controlChange(16, .nonRegisteredParameterNumberLSB, 127)])
    }

    @Test
    func parameterDeselect() {
        #expect(MIDIChannelMessage.parameterDeselect(on: 4) == [.controlChange(4, .registeredParameterNumberMSB, 127),
                                                                .controlChange(4, .registeredParameterNumberLSB, 127)])
    }

    @Test
    func registeredParameterChange_msb() {
        let messages = MIDIChannelMessage.registeredParameterChange(.fineTuning,
                                                                    msb: 0x40,
                                                                    on: 3)

        #expect(messages == [.controlChange(3, .registeredParameterNumberMSB, 0),
                             .controlChange(3, .registeredParameterNumberLSB, 1),
                             .controlChange(3, .dataEntryMSB, 0x40),
                             .controlChange(3, .registeredParameterNumberMSB, 127),
                             .controlChange(3, .registeredParameterNumberLSB, 127)])
    }

    @Test
    func registeredParameterChange_value() {
        let messages = MIDIChannelMessage.registeredParameterChange(.fineTuning,
                                                                    value: MIDIData2Value(msb: 0x60, lsb: 0x05),
                                                                    on: 3)

        #expect(messages == [.controlChange(3, .registeredParameterNumberMSB, 0),
                             .controlChange(3, .registeredParameterNumberLSB, 1),
                             .controlChange(3, .dataEntryMSB, 0x60),
                             .controlChange(3, .dataEntryLSB, 0x05),
                             .controlChange(3, .registeredParameterNumberMSB, 127),
                             .controlChange(3, .registeredParameterNumberLSB, 127)])
    }

    @Test
    func registeredParameterChange_value_bytes() {
        let messages = MIDIChannelMessage.registeredParameterChange(.pitchBendSensitivity,
                                                                    value: MIDIData2Value(msb: 2, lsb: 0),
                                                                    on: 1)

        #expect(messages.compactMap(\.bytesValue) == [[0xb0, 0x65, 0x00],
                                                      [0xb0, 0x64, 0x00],
                                                      [0xb0, 0x06, 0x02],
                                                      [0xb0, 0x26, 0x00],
                                                      [0xb0, 0x65, 0x7f],
                                                      [0xb0, 0x64, 0x7f]])
    }

    @Test
    func registeredParameterSelect() {
        #expect(MIDIChannelMessage.registeredParameterSelect(.coarseTuning,
                                                             on: 1) == [.controlChange(1, .registeredParameterNumberMSB, 0),
                                                                        .controlChange(1, .registeredParameterNumberLSB, 2)])
    }
}
