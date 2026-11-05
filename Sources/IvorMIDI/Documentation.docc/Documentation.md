# ``IvorMIDI``

@Metadata {
    @PageColor(blue)
}

MIDI channel message, system message, and data value types.

## Overview

The IvorMIDI framework provides MIDI channel message, system message, and data
value types written in Swift. Channel messages cover note on and off,
polyphonic and channel pressure, control change, program change, and pitch
bend change; system messages cover system exclusive, system common, and system
real-time messages. Channel and system messages, and the data values they
carry, can be converted to and from their [MIDI 1.0](https://midi.org/midi-1-0)
wire encoding.

Registered (RPN) and non-registered (NRPN) parameters, such as pitch bend
sensitivity and fine tuning, can be set with a single call that builds the
whole control change sequence. Universal system exclusive messages for master
volume, master tuning, and all of the MIDI Tuning Standard are built the same
way, as are the bank select and program change messages that set a channel to
a ``MIDIPatch``. ``MIDITuningMessage`` decodes MIDI Tuning Standard messages.
A ``MIDIPitchBend`` can be made from a bend in cents and the synthesizer’s
pitch bend sensitivity.

```swift
import IvorMIDI

// Middle C, velocity 100, on channel 1.
let noteOn = MIDIChannelMessage.noteOn(1, 60, 100)

noteOn.statusByte   // 0x90
noteOn.dataBytes    // [0x3C, 0x64]

// Decode a message from its wire encoding.
let decoded = MIDIChannelMessage(statusByte: 0x90,
                                 dataBytes: [0x3c, 0x64])

decoded == noteOn   // true
```

See <doc:UsingIvorMIDI> for a full guide to the messages, the data values, and
the wire encoding.

## Topics

### Guides

- <doc:UsingIvorMIDI>

### Messages

- ``MIDIChannelMessage``
- ``MIDISystemMessage``
- ``MIDITuningMessage``

### Data values

- ``MIDIChannel``
- ``MIDIController``
- ``MIDIData1Value``
- ``MIDIData2Value``
- ``MIDINonRegisteredParameter``
- ``MIDIPitchBend``
- ``MIDIProgram``
- ``MIDIRegisteredParameter``
- ``MIDITuningChange``
- ``MIDITuningFrequency``
- ``MIDITuningLocation``
- ``MIDITuningOffsets``

### Patches

- ``MIDIBank``
- ``MIDIPatch``

### Encoding

- ``MIDIBytesConvertible``
