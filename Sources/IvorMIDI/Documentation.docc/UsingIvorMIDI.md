# Using IvorMIDI

Build MIDI 1.0 messages from typed values, and convert them to and from their
wire encoding.

## Overview

IvorMIDI models the MIDI 1.0 message set with two enumerations, built from a
family of small data value types that each validate their own range. Typed
system exclusive messages and device codecs build on them:

 Type                              | Represents
:----                              |:----------
 ``MIDIChannelMessage``            | A channel voice or mode message
 ``MIDISystemMessage``             | A system exclusive, common, or real-time message
 ``MIDIChannel``                   | A channel number (1–16)
 ``MIDIData1Value``                | A 7-bit data value (0–127)
 ``MIDIData2Value``                | A 14-bit data value (0–16,383)
 ``MIDIController``                | A controller number (0–127)
 ``MIDIProgram``                   | A program number (1–128)
 ``MIDIPitchBend``                 | A pitch bend value (−8,192–8,191)
 ``MIDIRegisteredParameter``       | A registered parameter number (0–16,383)
 ``MIDINonRegisteredParameter``    | A non-registered parameter number (0–16,383)
 ``MIDIBank``                      | A bank number (0–16,383)
 ``MIDIPatch``                     | A program and, optionally, its bank
 ``MIDISysExEnvelope``             | The owner and payload of a system exclusive message
 ``MIDIManufacturerID``            | The owner of a manufacturer-specific message
 ``MIDIDeviceControlMessage``      | A master volume or tuning message
 ``MIDIIdentityMessage``           | An Identity Request or Identity Reply
 ``MIDIDeviceIdentity``            | What a device reports about itself
 ``MIDITuningMessage``             | A MIDI Tuning message
 ``MIDITuningFrequency``           | A frequency in the MIDI Tuning format
 ``MIDITuningChange``              | A retuning of one key
 ``MIDITuningLocation``            | A tuning program and, optionally, its bank
 ``MIDITuningOffsets``             | The tuning offsets of the 12 notes of the octave
 ``MIDIDevice``                    | One device in use
 ``MIDIDeviceModel``               | What is known about a model of device
 ``MIDIDeviceTuning``              | A complete tuning, not tied to any device
 ``MIDITuningCodec``               | A device’s tuning messages behind one interface
 ``MIDIUniversalTuningCodec``      | Tuning messages for devices that use universal messages
 ``TX81ZTuningCodec``              | Tuning messages for a Yamaha TX81Z
 ``TX81ZTuningPreset``             | A preset tuning of a Yamaha TX81Z

Messages are values, so building one is just naming its case:

```swift
let noteOn  = MIDIChannelMessage.noteOn(1, 60, 100)     // channel, note, velocity
let sustain = MIDIChannelMessage.controlChange(1, .sustain, 127)
let start   = MIDISystemMessage.start
```

## Data values

Each data value type wraps one number. An integer literal creates one directly,
which suits constants; a literal out of range stops execution. For values that
come from outside the program, use the failable `init?(uintValue:)` (or
``MIDIPitchBend/init(intValue:)``), which returns `nil` for a value out of
range, or check it first with `isValid(_:)`. ``MIDIChannel``,
``MIDIData1Value``, ``MIDIData2Value``, ``MIDIProgram``, and ``MIDIPitchBend``
also offer `init(clamping:)`, which pulls any integer into range:

```swift
let channel: MIDIChannel = 10                   // a literal: traps if out of range
let program = MIDIProgram(uintValue: 129)       // nil
let velocity = MIDIData1Value(clamping: 200)    // 127
```

Channels and programs are numbered from 1, as the MIDI and General MIDI
specifications number them; the wire encoding stores them zero-based. The
14-bit types — ``MIDIData2Value``, ``MIDIBank``, ``MIDIRegisteredParameter``,
and ``MIDINonRegisteredParameter`` — expose their 7-bit halves as `msb` and
`lsb`, and ``MIDIData2Value`` and ``MIDIBank`` can also be made from them:

```swift
let bank = MIDIBank(msb: 121, lsb: 1)
bank.uintValue      // 15489
```

A ``MIDIPitchBend`` is centered at 0. Rather than work out the value by hand,
make one from a bend in cents and the synthesizer’s pitch bend sensitivity
(also in cents); the result uses the full 14-bit range and is clamped to it:

```swift
let bend = MIDIPitchBend(cents: 100, sensitivity: 200)  // 4096
```

The data value types are `Codable`, `Comparable`, and `Hashable`, and describe
themselves by their number.

## Channel messages

``MIDIChannelMessage`` has one case per channel voice message: note on and
off, polyphonic and channel pressure, control change, program change, and
pitch bend change. Channel mode messages, such as all notes off, are control
changes; ``MIDIController`` names every controller the MIDI 1.0 specification
assigns, from ``MIDIController/bankSelectMSB`` to
``MIDIController/polyModeOn``. Every message knows its
``MIDIChannelMessage/channel``.

## Parameters and patches

A registered or non-registered parameter is set with a sequence of control
changes: select the parameter, send its value with data entry, then deselect
it so that later data entry does not change it by accident. One call builds
the whole sequence, with a 7-bit (`msb:`) or 14-bit (`value:`) value:

```swift
// Set pitch bend sensitivity to 2 semitones on channel 1.
let bendRange = MIDIChannelMessage.registeredParameterChange(.pitchBendSensitivity,
                                                             msb: 2,
                                                             on: 1)
// RPN MSB, RPN LSB, data entry MSB, then the null RPN to deselect.
```

The pieces are available separately too — `registeredParameterSelect(_:on:)`,
`nonRegisteredParameterSelect(_:on:)`, `dataEntry(_:on:)`,
`dataEntryMSB(_:on:)`, `dataIncrement(on:)`, `dataDecrement(on:)`, and
`parameterDeselect(on:)` — for a controller that adjusts a parameter step by
step.

A ``MIDIPatch`` is a program and, optionally, the bank it comes from.
``MIDIPatch/selectionMessages(on:after:)`` returns the bank select and program
change messages that set a channel to it. Given the patch the channel had, it
also selects bank 0 when moving from a banked patch to one without a bank, so
the channel doesn’t stay in the old bank:

```swift
let ukulele  = MIDIPatch(program: 25, bank: MIDIBank(msb: 121, lsb: 1))
let messages = ukulele.selectionMessages(on: 1, after: nil)
// Bank select MSB 121, bank select LSB 1, then program change 25.
```

## System messages

``MIDISystemMessage`` covers system exclusive messages, system common messages
(MIDI time code quarter frame, song position, song select, tune request, and
EOX), and system real-time messages (timing clock, start, continue, stop,
active sensing, and system reset).

A ``MIDISystemMessage/systemExclusive(_:)`` message holds the bytes that follow
the 0xF0 status byte, up to and including the terminating 0xF7. It holds raw
bytes, so it can carry a message that nothing here decodes, or one that is
malformed, without changing it.

## System exclusive messages

System exclusive support has three layers, and most code only needs the top one.

- A ``MIDISysExEnvelope`` says whose message this is.
- A typed message, such as ``MIDITuningMessage``, says what the message means.
- A ``MIDITuningCodec`` reaches the right messages for a device. See
  [Devices](#Devices).

### Envelopes

An envelope splits a system exclusive message into its owner and its payload,
without interpreting the payload. The owner is a manufacturer, the non-commercial
ID, or a universal ID. That’s enough to label any message, even one with no
decoder:

```swift
let label = switch MIDISysExEnvelope(message) {
case .none:
    "Malformed SysEx"

case let .manufacturer(.yamaha, payload):
    "Yamaha, \(payload.count) bytes"

case let .manufacturer(id, payload):
    "Manufacturer \(id.bytes), \(payload.count) bytes"

case .nonCommercial:
    "Non-commercial"

case .universal(.generalInformation, _, _):
    "General information"

case .universal(.tuning, _, _),
     .universal(.realTimeTuning, _, _):
    "MIDI Tuning"

case let .universal(id, deviceID, _):
    "Universal \(id.subID.uintValue), device \(deviceID.uintValue)"
}
```

A payload never includes 0xF0, the header, or 0xF7. For a universal message, it
starts with sub-ID#2 if the message has one.

``MIDISysExEnvelope/init(_:)`` returns `nil` if a message doesn’t end with 0xF7,
has any other byte above 0x7F, or is too short to hold its header. The original
message still holds the bytes. The cases of ``MIDISysExEnvelope`` can also be used
directly, so ``MIDISysExEnvelope/hasValidPayload`` reports whether every payload
byte is a data byte, and ``MIDISysExEnvelope/systemMessage`` is `nil` if one isn’t.

``MIDIManufacturerID`` has constants for widely known manufacturers, such as
``MIDIManufacturerID/yamaha``, and ``MIDIManufacturerID/init(bytes:)`` makes any
other ID from the MIDI Association’s
[table of assigned IDs](https://midi.org/SysExIDtable).

### Typed messages

A typed message conforms to ``MIDISysExRepresentable``, so it converts to and from
both an envelope and a ``MIDISystemMessage``. Each has a `Content` enumeration and
a device ID, which defaults to all devices (127):

```swift
let volume = MIDIDeviceControlMessage(content: .masterVolume(16_383))   // full volume
let tuning = MIDIDeviceControlMessage(content: .masterCoarseTuning(64)) // A440
let request = MIDIIdentityMessage(content: .request)

volume.systemMessage    // .systemExclusive([0x7F, 0x7F, 0x04, 0x01, 0x7F, 0x7F, 0xF7])
```

To decode a message, try the initializer of the type you expect, which returns
`nil` for anything else:

```swift
if let reply = MIDIIdentityMessage(message),
   case let .reply(identity) = reply.content {
    identity.manufacturer       // .yamaha, for example
}
```

To add a message in another package, implement the two requirements of
``MIDISysExRepresentable``, and start your decoder by checking
``MIDISysExEnvelope/hasValidPayload``.

## MIDI tuning

``MIDITuningMessage`` covers the messages of the *MIDI Tuning Messages*
specification (the MIDI Tuning Standard, with its CA-020, CA-021, and RP-020
extensions). Unlike ``MIDIProgram``, tuning programs and banks are numbered from
0, as they appear on the wire (0–127).

 Message                                           | `Content` case
:----                                              |:----
 Bulk tuning dump request, with or without a bank  | ``MIDITuningMessage/Content/dumpRequest(_:)``
 Bulk tuning dump, or key-based tuning dump        | ``MIDITuningMessage/Content/keyBasedDump(_:name:frequencies:)``
 Scale/octave tuning dump, 1 or 2 byte format      | ``MIDITuningMessage/Content/scaleOctaveDump(bank:program:name:offsets:)``
 Scale/octave tuning, 1 or 2 byte form             | ``MIDITuningMessage/Content/scaleOctaveTuning(channels:offsets:realTime:)``
 Single note tuning change, with or without a bank | ``MIDITuningMessage/Content/singleNoteChange(_:changes:realTime:)``

A ``MIDITuningLocation`` with a bank selects the form of a message that has one.

Key-based messages give keys absolute frequencies as
``MIDITuningFrequency`` values, which you can make from a frequency in hertz
or from a semitone and a fraction of a semitone.
``MIDITuningFrequency/noChange`` leaves a key as it is:

```swift
// Retune key 69 to 442 Hz in tuning program 0, even while it sounds.
let change = MIDITuningMessage(
    content: .singleNoteChange(MIDITuningLocation(program: 0),
                               changes: [MIDITuningChange(key: 69,
                                                          frequency: MIDITuningFrequency(hertz: 442)!)],
                               realTime: true)
)
```

Scale/octave messages give the 12 notes from C to B offsets from the selected
preset, or from equal temperament if there is none, as a
``MIDITuningOffsets`` value. ``MIDITuningOffsets/coarse(_:)`` is the 1-byte
form, in whole cents from −64 to +63; ``MIDITuningOffsets/fine(_:)`` is the
2-byte form, about ±100 cents in steps of about 0.012 cents:

```swift
let offsets = [MIDIData1Value](repeating: 64, count: 12)
let scale   = MIDITuningMessage(content: .scaleOctaveTuning(channels: [1, 2],
                                                            offsets: .coarse(offsets),
                                                            realTime: false))
```

Each scale/octave message replaces the offsets of the last one rather than
adding to them. To start from equal temperament on a device with tuning
presets, RP-020 recommends selecting bank 0, program 0 first.

``MIDITuningMessage/envelope`` and ``MIDITuningMessage/systemMessage`` are `nil` if
a message has the wrong number of elements, or a tuning name that is not ASCII or
is longer than 16 characters. A shorter name is padded with spaces.

To make a stored tuning the active one on a channel, set the
``MIDIRegisteredParameter/tuningBankSelect`` and
``MIDIRegisteredParameter/tuningProgramChange`` registered parameters:

```swift
let select = MIDIChannelMessage.registeredParameterChange(.tuningProgramChange,
                                                          msb: 5,
                                                          on: 1)
```

To read a tuning message, such as a device’s reply to a dump request, decode
it with ``MIDITuningMessage``. Its ``MIDITuningMessage/content`` holds what
the message says, and its ``MIDITuningMessage/systemMessage`` encodes it
again, so you can edit a tuning and send it back:

```swift
if let tuning = MIDITuningMessage(reply),
   case let .keyBasedDump(location, name, frequencies) = tuning.content {
    // Use the tuning.
}
```

The decoder returns `nil` for anything that is not a valid tuning message,
including a key-based or scale/octave tuning dump with a wrong checksum. It
does not check the checksum of a bulk tuning dump, because manufacturers have
calculated it differently and the specification lets receivers ignore it.

## Devices

Devices differ in ways that universal messages can’t hide. A Yamaha TX81Z ignores
them entirely, and has its own messages instead. A ``MIDITuningCodec`` puts both
kinds behind one interface, so the same code installs a tuning on any supported
device:

```swift
guard let codec = device.tuningCodec
else { return }     // this device has no known tuning support

let slot = codec.defaultSlot
let output = try codec.messages(for: tuning,
                                slot: slot,
                                address: device.address)
let selection = try codec.selectionMessages(slot: slot,
                                            channels: channels)

// Show output.prerequisites and output.adjustments, then send output.messages,
// followed by selection.
```

A ``MIDIDevice`` is one device in use, however it was found. It holds an address
and a codec, which can come from a ``MIDIDeviceModel``:

```swift
// A model from the catalog, chosen by the user.
let synth = MIDIDevice(model: .yamahaTX81Z,
                       address: .channel(1))

// A device with no known model, which might honor universal messages.
let other = MIDIDevice(tuningCodec: MIDIUniversalTuningCodec(),
                       address: .deviceID(127))
```

``MIDIDeviceModel/init(matching:)`` finds the model for a ``MIDIDeviceIdentity``
from an Identity Reply. A reply doesn’t say which universal messages a device
supports, and a TX81Z can’t reply at all, so a user may still need to choose a
model.

A ``MIDIDeviceTuning`` isn’t tied to a device or a location, so a tuning stays
portable, and a ``MIDITuningSlot`` says where to install it. The output’s
adjustments say how the installed tuning differs from the one requested, and its
prerequisites list the steps that its messages don’t cover.

IvorMIDI performs no I/O: a codec only builds and reads messages, so they can also
be written to a Standard MIDI File. See <doc:TX81ZMicroTuning> for the details of
one device.

## Wire encoding

Both message types expose the two halves of their MIDI 1.0 wire encoding,
`statusByte` and `dataBytes`, and can be made from them with
`init?(statusByte:dataBytes:)`. That initializer returns `nil` if the data
bytes are the wrong number for the status byte, or are not valid data bytes;
`expectedDataByteCount(for:)` tells you how many a status byte takes, which
helps when reading a byte stream.

``MIDIChannelMessage``, ``MIDISystemMessage``, ``MIDIChannel``,
``MIDIController``, ``MIDIData1Value``, ``MIDIData2Value``, ``MIDIPitchBend``,
``MIDIProgram``, ``MIDITuningFrequency``, and ``MIDITuningOffsets`` also adopt
``MIDIBytesConvertible``, which converts a value to and from one array of
bytes — for a message, the status byte followed by the data bytes:

```swift
MIDIChannelMessage.noteOn(1, 60, 100).bytesValue    // [0x90, 0x3C, 0x64]
MIDISystemMessage(bytesValue: [0xfa])               // .start
```

Other packages adopt ``MIDIBytesConvertible`` for their own binary encodings.

## Error handling

Every conversion that can fail returns `nil`: the failable initializers of the
data value types, the `init?(statusByte:dataBytes:)` and `init?(bytesValue:)`
decoders, ``MIDISysExEnvelope``, and the decoding and encoding of typed messages.
An integer literal out of range stops execution, so use a failable initializer
for any value you have not checked.

A ``MIDITuningCodec`` is the exception, because a caller needs to know why a
request can’t be met. Its methods throw a ``MIDITuningError`` if a device can’t
use an address, a slot, or a tuning.

## Concurrency

IvorMIDI is built for Swift 6 strict concurrency. Every public message and
data value type is a `Sendable` value type, so instances can be freely shared
across tasks and actor boundaries.
