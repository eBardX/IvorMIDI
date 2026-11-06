// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDITuningCodecTests {
    private let frequencies = (0..<128).map { MIDITuningFrequency(semitone: MIDIData1Value(clamping: $0)) }
}

// MARK: -

extension MIDITuningCodecTests {
    @Test
    func install_throughExistential() throws {
        let device = MIDIDevice(tuningCodec: MIDIUniversalTuningCodec(),
                                address: .deviceID(127))
        let codec = try #require(device.tuningCodec)
        let tuning = try #require(MIDIDeviceTuning(frequencies: frequencies))
        let slot = codec.defaultSlot
        let output = try codec.messages(for: tuning, slot: slot, address: device.address)
        let selection = try codec.selectionMessages(slot: slot, channels: [1, 2])

        #expect(output.messages.count == 1)
        #expect(selection.count == 10)
    }

    @Test
    func probe_throughExistential() throws {
        let codec: any MIDITuningCodec = MIDIUniversalTuningCodec()
        let tuning = try #require(MIDIDeviceTuning(frequencies: frequencies))
        let address = try #require(codec.probeAddresses.first)
        let requests = try codec.requestMessages(slot: codec.defaultSlot, address: address)
        let output = try codec.messages(for: tuning, slot: codec.defaultSlot, address: address)
        let reply = try #require(output.messages.first)

        #expect(requests.count == 1)
        #expect(codec.tuning(from: reply) == tuning)
    }
}
