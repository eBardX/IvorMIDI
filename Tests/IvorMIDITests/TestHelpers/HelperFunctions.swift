// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import XestiTools

func corruptingChecksum(of message: MIDISystemMessage) -> MIDISystemMessage {
    guard case var .systemExclusive(bytes) = message
    else { return message }

    bytes[bytes.count - 2] ^= 0x01

    return .systemExclusive(bytes)
}

func tuningBytes(_ content: MIDITuningMessage.Content,
                 deviceID: MIDIData1Value = 0x7f) -> [UInt8]? {
    MIDITuningMessage(content: content, deviceID: deviceID).systemMessage?.dataBytes
}

func tx81zBytes(_ content: TX81ZTuningMessage.Content,
                _ channel: MIDIChannel) -> [UInt8]? {
    TX81ZTuningMessage(content: content, channel: channel).systemMessage?.bytesValue
}

func tx81zDumpPayload(_ data: [UInt8]) -> [UInt8] {
    YamahaSysEx.bulkDumpPayload(channel: 1, format: 0x7e, data: data)
}
