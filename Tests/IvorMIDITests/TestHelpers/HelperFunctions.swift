// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI

func corruptingChecksum(of message: MIDISystemMessage) -> MIDISystemMessage {
    guard case var .systemExclusive(bytes) = message
    else { return message }

    bytes[bytes.count - 2] ^= 0x01

    return .systemExclusive(bytes)
}
