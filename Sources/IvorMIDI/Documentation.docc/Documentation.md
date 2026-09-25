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
real-time messages. Every message and data value can be converted to and from
its [MIDI 1.0](https://midi.org/midi-1-0) wire encoding.

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

Every public type is a `Sendable` value type, so instances can be freely shared
across tasks and actor boundaries.

## Topics

### Messages

- ``MIDIChannelMessage``
- ``MIDISystemMessage``

### Data values

- ``MIDIChannel``
- ``MIDIController``
- ``MIDIData1Value``
- ``MIDIData2Value``
- ``MIDIPitchBend``

### Encoding

- ``MIDIBytesConvertible``
