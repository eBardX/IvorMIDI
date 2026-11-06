# TX81Z Micro Tuning

Install and read tunings on a Yamaha TX81Z through its tuning codec.

## Overview

A TX81Z ignores universal system exclusive messages, so it can’t use
``MIDITuningMessage`` or answer an Identity Request. ``TX81ZTuningCodec``
implements ``MIDITuningCodec`` with the instrument’s own messages, so the same
calling code works with a TX81Z and with a device that uses universal messages.

The instrument has one editable table of each kind, and neither stores a name:

Slot                                  | Table
:----                                 |:----
``MIDITuningSlot/tx81zFullKeyboard``  | 128 keys, for any scale
``MIDITuningSlot/tx81zOctave``        | 12 notes that repeat up and down the keyboard

## Installing a tuning

Use ``MIDIDeviceModel/yamahaTX81Z``, because a TX81Z can’t identify itself. Its
address is a channel, which must match the instrument’s Basic Receive channel
unless that is set to Omni.

```swift
let device = MIDIDevice(model: .yamahaTX81Z,
                        address: .channel(1))

guard let codec = device.tuningCodec
else { return }

let output = try codec.messages(for: tuning,
                                slot: codec.defaultSlot,
                                address: device.address)

// Show output.prerequisites and output.adjustments, then send output.messages.
```

The output holds the dump, then the Performance parameter message that selects
that table. Send them in order, and leave time for the dump to arrive. Pacing
belongs to the caller.

The instrument is less precise than a ``MIDIDeviceTuning``, so the output’s
adjustments report what changed:

Adjustment                                                    | Reason
:----                                                         |:----
``MIDITuningOutput/Adjustment/clamped(keys:)``                | A pitch was outside notes 13,0 to 108,63
``MIDITuningOutput/Adjustment/droppedName``                   | The instrument stores no name
``MIDITuningOutput/Adjustment/replacedNoChange(keys:)``       | The instrument can’t leave a key as it is, so the key became its equal-tempered pitch
``MIDITuningOutput/Adjustment/rounded(maximumCents:)``        | Pitches are in steps of 1/64 semitone, about 1.56 cents

The octave table uses keys 60–71. Its pitches are absolute, so equal temperament
is notes 60–71 with no fraction. A tuning that doesn’t repeat at the octave, such
as Bohlen-Pierce, throws ``MIDITuningError/nonRepeatingTuning``. Use the full
keyboard table for those.

## Hearing a tuning

Sending a tuning isn’t enough to hear it. ``MIDITuningOutput/prerequisites``
lists the steps that the messages can’t do:

- Exclusive must be on, or the instrument ignores all system exclusive messages.
- Memory Protect must be off for dumps.
- Micro Tune must be on for each instrument that should use the tuning.
- A tuning only applies in a Performance, not to a single voice.

Only notes 13–108 sound.

## Reading a tuning

Send the messages from ``TX81ZTuningCodec/requestMessages(slot:address:)``, then
pass the reply to ``TX81ZTuningCodec/tuning(from:)``. The instrument replies on
its Transmit channel, which can differ from the channel of the request. If
Exclusive is off, it stays silent, as if nothing were connected.

A request doesn’t change the instrument’s memory, but it touches the display.

## Model-specific messages

These go beyond the shared protocol, and each one changes the Performance edit
buffer:

- ``TX81ZTuningCodec/presetMessage(_:channel:)`` selects one of the 11 presets in
  ``TX81ZTuningPreset``.
- ``TX81ZTuningCodec/microTuneKeyMessage(_:channel:)`` sets the key of presets
  2–5, the ones where ``TX81ZTuningPreset/usesKey`` is `true`. For
  ``TX81ZTuningPreset/pureMinor``, the key names the relative major, so 0 selects
  A minor.
- ``TX81ZTuningCodec/microTuneEnableMessage(instrument:isEnabled:channel:)`` turns
  Micro Tune on or off for one of the eight instruments.

## Evidence

No message has been sent to an instrument by this package, so a passing test
suite doesn’t prove that they work on hardware.

- **Verified by real dumps:** the full keyboard dump. Twenty-six dumps that were
  used on instruments are rebuilt byte for byte.
- **Read from the V1.6 firmware:** the octave dump, dump requests, and the
  Performance parameters. The code was read, not run, and other firmware versions
  weren’t checked.

``MIDIDeviceModel/yamahaDX11`` uses the same codec. That rests on the dumps sent
to both instruments and on a published write-up, not on the DX11’s firmware or a
Yamaha manual.
