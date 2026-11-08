# TX81Z Micro Tuning SysEx

Findings on the Yamaha TX81Z micro tuning system exclusive messages. IvorMIDI
implements them in `TX81ZTuningCodec`, except for single-note changes and master
tune. No message has been sent to an instrument by that code.

## Summary

The TX81Z has two user-programmable tuning tables: an octave table of 12 notes
and a full keyboard table of 128 keys. Both can be sent as bulk dumps or changed
one note at a time, and both can be requested from the instrument.

- The **full keyboard bulk dump** is verified and is safe to implement. All 26
  real dumps can be rebuilt byte for byte from the rules below.
- The **octave bulk dump**, **dump requests**, **single-note parameter changes**
  and **Performance parameters** are confirmed by a disassembly of the V1.6
  firmware, which shows how the instrument itself parses and uses them. A
  published write-up and an open source editor agree.
- Nothing here has been sent to a TX81Z during this work, so a short hardware test
  is still worthwhile. See [Open questions](#open-questions).

## Sources and evidence

Page numbers are the printed ones. PDF page numbers are one higher.

- **Manual:** `Specifications/Yamaha TX81Z Owner’s Manual.pdf`. It is a scan with
  no text layer, so `pdftotext` returns nothing and the pages have to be read as
  images. The relevant pages are 24, 26, 31–32, 41, 49, 67–70, 73, 76 and 77–78.
- **Dumps:** 26 Standard MIDI Files that John Pusey used to set up his synths
  about 30 years ago, in
  `/Users/jgp/Documents/Composing/Sequences/Vision/Xenharmonicity/Set*.mid`. They
  cover 24 equal divisions of the octave from 5 to 53, plus 88CET and
  Bohlen-Pierce, which do not repeat at the octave. The four files in the sibling
  `Fragments` folder are identical copies of the 12-, 15-, 17- and 19-tET dumps.
  All of these are outside this repo, so [Test vectors](#test-vectors) reproduces
  the data needed to check against them.
- **Write-up:** [Microtuning the Yamaha DX11/TX81Z using MIDI System Exclusive
  Messages](http://www.rreid.net/tuning/sysex_microtune.txt), called "the Reid
  write-up" below. The server's HTTPS certificate is invalid, so use plain HTTP.
- **Firmware:** [raybellis/TX81Z](https://github.com/raybellis/TX81Z) (commit
  `0e79f4c`), a mostly unannotated disassembly of the firmware. Its version string
  is `V1.6  03-Feb-88`. See [Firmware behavior](#firmware-behavior).
- **Code:** [TX81Z Programmer](https://github.com/mgregory22/tx81z-programmer)
  (commit `08dd21c`). See [Other implementations](#other-implementations).

Each claim below carries one of these labels:

| Label | Meaning |
|---|---|
| **Verified** | Confirmed by the bytes of the 26 dumps |
| **Firmware** | Read from the V1.6 disassembly, and the Reid write-up and TX81Z Programmer agree |
| **Manual** | Stated by the manual only |

No message has been tested against a TX81Z during this work. "Verified" means
the dumps agree, and that these dumps are believed to have worked on the
hardware when they were sent. "Firmware" means the code was read, not run: it
shows what V1.6 should do, and the reading could contain mistakes. Other firmware
versions were not checked.

## Message formats

All bytes are hexadecimal. `n` is the channel, from 0 to F.

The second nibble of the third byte follows Yamaha's usual pattern: `1n` for a
parameter change, `0n` for a bulk dump and `2n` for a dump request.

### Full keyboard bulk dump (Verified)

```
F0 43 0n 7E 02 0A "LM  MCRTE1" <256 data bytes> cc F7
```

- The total length is 274 bytes.
- The payload is 128 `hh ll` pairs, one for each of keys 0–127 (C-2 to G8).
- The tag has exactly two spaces, making 10 ASCII characters.

### Octave bulk dump (Firmware)

```
F0 43 0n 7E 00 22 "LM  MCRTE0" <24 data bytes> cc F7
```

- The total length is 42 bytes.
- The payload is 12 `hh ll` pairs, for keys 60–71 (C3 to B3).
- Values are absolute pitches. The firmware subtracts 60 from each `hh`, then adds
  12 for each octave of the key, so equal temperament is `60,0` to `71,0`.
- The tuning of each note repeats every 1200 cents up and down the keyboard.

### Size and checksum

The size is a 14-bit value split into two 7-bit bytes, high byte first:
`size >> 7`, then `size & 0x7F`. It counts the 10-character tag and the payload,
so the size is 266 for the full table and 34 for the octave table. (**Verified**
for 266.)

The checksum is the two's complement of the low 7 bits of the sum of the tag and
payload bytes: `(-sum) & 0x7F`. The `7E` format byte and the two size bytes are
not included. (**Verified**: the checksum matches only when the tag is included.)

### Single-note parameter change (Firmware)

```
F0 43 1n 10 pp kk hh ll F7
```

| Byte | Meaning |
|---|---|
| `pp` | `7D` for the octave table, `7E` for the full keyboard table |
| `kk` | Key number: 0–11 for the octave table, 0–127 for the full keyboard table |
| `hh ll` | Pitch, encoded as below |

### Dump request (Firmware)

```
F0 43 2n 7E "LM  MCRTE0" F7    octave table
F0 43 2n 7E "LM  MCRTE1" F7    full keyboard table
```

The TX81Z answers only if `n` matches its Basic Receive channel, or it is set to
Omni. The reply goes out on its **Transmit** channel, which can differ.

### Identifying the instrument (Firmware)

The firmware drops any SysEx that doesn't start with `43`, so a TX81Z can't answer
a universal Identity Request (`F0 7E <device> 06 01 F7`). Nothing it sends names the
model, but a dump request can show which formats it understands.

**To check for micro tuning,** send the dump request from the previous section. A
valid reply shows that the device handles the format, which is all a tuning sender
needs to know.

**Voice tags are not a model test,** because they name data formats that several
models share:

| Tag | Format | Listed for |
|---|---|---|
| `LM  8976AE` | ACED | TX81Z, DS55, TQ5 |
| `LM  8023AE` | ACED2 | DX11, YS series, TQ5, WT11 |

The TX81Z V1.6 compares the `8976` digits one at a time, so it abandons `8023` at
the `0`. That rules out V1.6 if a device answers `8023`, but it doesn't name the
device. Apart from that firmware result, the table comes from third-party lists:
`BobanSpasic/MK2toMK1` (`units/untParConst.pas`, commit `bc222ca`),
`hypercube-software/Audio-Workshops` (`devices-library/Yamaha/TQ-5.yml`, commit
`4ed9ace`) and the `rec/ufor` WT11 notes. None of this was tested on hardware.

Other details from the firmware:

- **A request needs its whole tag.** The dump starts on the tag's last byte, and
  `F0 43 2n 7E F7` gets no reply, because the `F7` just ends the message.
- **Short forms exist.** `F0 43 2n 03 F7` requests VCED and `F0 43 2n 04 F7`
  requests VMEM. Format `7C` is rejected.
- **A request doesn't change memory.** It only sends data, though it touches the
  display.
- **The system setup request** is `F0 43 2n 7E "LM  8976S0" F7`, which TX81Z
  Programmer also uses.

## Pitch encoding

**Verified** for the full keyboard table.

- `hh` is a standard MIDI note number from 13 to 108 (C#-1 to C7). Yamaha numbers
  C3 as note 60, and A3 = 440 Hz is note 69.
- `ll` is an unsigned value from 0 to 63, in units of 1/64 semitone (100/64 cents,
  about 1.56 cents).

```
pitch in semitones = hh + ll/64
frequency          = 440 × 2^((hh + ll/64 − 69) / 12)
```

The valid range is `13,0` to `108,63`, which is the manual's 0–6143 scale, where
`scale = (hh − 13) × 64 + ll`.

**Do not sign-extend `ll`.** Page 68 describes it as "0 to +31, −31 to −1
(0-32, 33-63)", which reads like a signed value. In the dumps, the unsigned
reading matches the intended pitches exactly and every table ascends. The signed
reading breaks that order in 24 of the 26 dumps: 24-tET has no `ll` above 32, and
9-tET stays in order but gives the wrong pitches. The wording describes the LCD,
which shows values of 33–63 as a negative offset from the next note up. The Reid
write-up says so directly, and the firmware's LCD code does the same. Its pitch
lookup uses `ll` unsigned.

### Encoding a pitch

This reproduces all 26 dumps byte for byte, across all 128 keys:

```
pitch = 69 + (key − 69) × step       step = size of a scale step, in semitones
value = round(pitch × 64)
value = clamp(value, 13×64, 108×64 + 63)
hh    = value / 64
ll    = value % 64
```

- **Round the total.** Rounding matches every key of every dump. Truncating gets
  up to 63 of the 128 keys wrong, and is right only for 8-, 12-, 16- and 24-tET,
  where every value is exact. Rounding the total also carries into `hh` correctly,
  as key 59 in 15-tET does when it lands on `61,0`. No dump contains an exact
  half, so the tie-breaking rule is untested.
- **Clamp both ends.** Low keys clamp to `13,0` and high keys to `108,63`, not
  `108,0`. In the 12-tET dump, keys 0–12 are `13,0` and keys 109–127 are `108,63`.
  This is a convention, not a rule of the format. The firmware's Init Full Kbd
  wraps those keys by octave instead, staying within `13–24` and `97–108`. Only
  notes 13–108 sound at all (p.79), so either choice works.
- **Anchor at A3.** Key 69 is `69,0` in every dump. This and the rounding show how
  these dumps were made, not what the hardware requires, so the API should accept
  arbitrary pitches rather than assume this formula.
- **Don't assume octaves.** A full keyboard table is just 128 pitches. 88CET and
  Bohlen-Pierce use it for scales that do not repeat at 1200 cents, which the
  octave table can't express.

### Converting from the MIDI Tuning Standard

`MIDITuningFrequency` uses the same reference, with semitone 69 at 440 Hz, and
its `uintValue` is `semitone << 14 | fraction`. So:

```
TX81Z value = clamp(round(uintValue / 256), 13×64, 108×64 + 63)
hh          = value >> 6
ll          = value & 0x3F

decoded uintValue = (hh << 14) | (ll << 8)
```

Each TX81Z step is about 1.56 cents, compared with about 0.0061 cents in the
standard, so a tuning does not survive a round trip through the TX81Z format.
The largest rounding error is about 0.78 cents.
`MIDITuningFrequency.noChange` has no TX81Z equivalent.

## Using a tuning on the instrument

Sending a table is not enough to hear it.

- **Tuning applies only in a Performance**, not to single voices (p.41). The
  dumps do not select a tuning, so that must have come from a Performance already
  stored on the synth.
- **Each instrument opts in.** An instrument plays the tempered scale unless its
  Micro Tune setting is on.
- **Exclusive must be on**, or all SysEx is ignored (p.26). The firmware checks
  this before processing any SysEx byte.
- **Memory Protect must be off** for a bulk dump (p.26). With it on, the firmware
  shows an error and drops the message. Parameter changes are not blocked.
- **The channel must match** Basic Receive, unless that is set to Omni.
- **There are 13 tables:** the editable octave and full keyboard tables, plus 11
  presets (p.31). Page 49 lists the theoretical values of presets 1–8, and the
  actual data is in steps of about 1.56 cents.

### Performance parameters (Firmware)

These are PCED parameters from p.73, sent as `F0 43 1n 10 pp dd F7`. The manual's
header is wrong (see [Manual errors](#manual-errors)).

| Parameter | Meaning | Data |
|---|---|---|
| `11 + 12i` | Micro Tune Enable for instrument `i` (0–7) | 0–1 |
| 96 | Micro Tune Table | 0–12, see below |
| 99 | Key, for presets 2–5 only | 0–11 (C to B) |

The table values are 0 for Octave, 1 for Full, and 2–12 for presets 1–11, in the
order listed on p.31. These parameters change the Performance edit buffer.

For preset 3, Pure minor, the key value names the relative major: 0 selects A
minor, and the LCD shows `A`.

The Performance bulk format (PMEM, p.76) stores the same settings as MTE at address 6 of
each instrument block, plus MTBL and KEY at addresses 64 and 65.

### Master tune (Firmware and TX81Z Programmer)

Master tune is separate from micro tuning and retunes the whole instrument.

```
F0 43 1n 10 7B 00 dd F7
```

- `dd` is 0–127 with 64 at the centre, displayed as −64 to +63. The range is about
  one semitone either way (p.24), so a step is presumably about 1.56 cents.
- `7B` is the System Parameter group (p.67). Parameter number 0 is handled as a
  special case in the firmware, and TX81Z Programmer names it master tune.

## Firmware behavior

These come from reading `hi.asm` in the V1.6 disassembly.

**Receiving a bulk dump:**

1. The tag must match, and the two size bytes must exactly match the expected
   values (`00 22` or `02 0A`). If not, the message is **dropped silently**.
2. Memory Protect is checked. If it is on, the message is dropped with an error.
3. Bytes go straight into the live table **as they arrive**.
4. The checksum is compared at the end. If it fails, the LCD shows an error, but
   **the table has already been overwritten**.
5. After a good checksum, every entry is cleaned up: `hh` is clamped to 13–108 and
   `ll` is masked to 6 bits. The LCD then shows "Midi Received".

**Checksum:** the running sum starts from `84` or `85`, which is the sum of the
tag, confirming that the tag counts. Oddly, the receiver accepts a total of `00`,
`30` or `40`. Why is not clear, and encoders should always aim for `00`.

**Parameter changes:**

- An octave `kk` of 12 or more is ignored. A full keyboard `kk` is not checked.
- `hh` above 108 or `ll` above 63 is ignored, leaving the old value in place.
- Each change is stored as two separate writes, first `hh`, then `ll`.
- Each change also moves the front panel into tuning editing and redraws the LCD.

**Playing a note:** the table entry becomes a pitch of `(hh − 13) + ll/64`
semitones. Instrument Note Shift is then added, and a result outside 13–108 folds
back by octaves.

## Manual errors

| Page | Printed | Correct | Evidence |
|---|---|---|---|
| 69 | Full keyboard size `00 22` | `02 0A` | **Verified** by the dumps, and hard-coded in the firmware. The entry was apparently copied from the octave table. |
| 31 | 6143 is "C7+32" | 6143 is `108,63` | The LCD example on the same page shows C7+32 as 6112. |
| 67 | PCED `hh = 11` (3) | `hh = 00`, giving `10` | ACED has the same printed value, and both use parameter 0 for different things. The firmware handles PCED parameters under `10`, and under `13` handles only ACED and the remote switches. Every other source uses `10`. |
| 69 | VMEM size `10 00` | `20 00` | 4096 in 7-bit bytes. Not tuning-related, but it shows the size bytes need recalculating. |
| 78 | Master tune `0-172` | Almost certainly 0–127 | A 7-bit data byte can't hold 172. |

## Other implementations

GitHub code search for `MCRTE0` and `MCRTE1` found only these relevant repos. Scala
also supports the TX81Z, but it is freeware and I did not find its source.

| Item | Firmware | Reid write-up | TX81Z Programmer |
|---|---|---|---|
| Full dump size | `02 0A` | `02 0A` | `02 0A` |
| Checksum includes tag | Yes | Yes | Yes |
| Dump request | Agrees | Agrees | Agrees |
| Pitch | Unsigned | Unsigned | Unsigned |
| Octave `kk` | 0–11 | 0–11 | 0–11 |
| Parameter 96 order | Octave, Full, presets | Octave, Full, presets | Octave, Full, presets |
| PCED header | `10` | `10` | `10` |

**TX81Z Programmer** (`src/tx81z.c`, `src/tx81z_meta.c`, `src/dlg/mtgen.c`) agrees
with this document everywhere. Its equal-tempered preset matches the 12-tET dump
for keys 13–108. Across its 55 preset tables, covering each preset in each key,
every value is in range. Key 69 stays at `69,0` in all but the three shifted
tables, which match the manual: 1/4 Shift puts every key up 50 cents, and in both
1/4 Tone and 1/8 Tone key 48 is `60,0`. It is licensed under the GPL, so use it as
a reference rather than copying its code or tables into IvorMIDI.

**Other hits:** Audio-Workshops lists dump requests that agree, and BobanSpasic's
tools only recognize these messages. Neither adds anything further. The firmware
repo states no license, so treat it as a reference only.

A [forum thread](https://yamahamusicians.com/forum/threads/scala-scale-files-to-tx81z.10692/)
has a spreadsheet method and an octave dump. It also treats octave values as
absolute from C3, and its checksum follows the rule above. Nobody in the thread
reports testing it on hardware.

## Open questions

The firmware answers what the instrument should do, but not everything has been
seen working.

1. **Does it all behave as read?** A short test on a real TX81Z would confirm the
   firmware reading: send an octave dump, a `7D` and a `7E` change, then select
   table 0 with parameter 96 and check the LCD.
2. **Do other firmware versions differ?** Only V1.6 was read. The dumps show the
   full keyboard format worked on the user's instruments.
3. **Does anything need a pause between messages?** I found no required delay, but
   each parameter change redraws the LCD, and the firmware can report a receive
   buffer overflow. TX81Z Programmer waits 70 ms between messages, or 250 ms after
   a few slow parameters (none of them tuning), and 400–800 ms after dumps over
   2000 bytes. That is its own practice, not a documented limit. Timing belongs to
   the caller, not to the codec.
4. **How does the DX11 differ?** Reid's write-up covers both instruments and the
   dumps carry the same bytes for each, but the DX11 firmware and manual were not
   checked. The useful test is whether a DX11 answers `LM  MCRTE1`. See
   [Identifying the instrument](#identifying-the-instrument-firmware).

## Test vectors

The encoding formula reproduces all 26 dumps exactly. Each message appears twice
in its file, with identical bytes on the DX11 and TX81Z tracks, always on channel
1 (`n = 0`).

Tests should use the full messages below as golden data for encoding and
decoding. They cover the plain case, three octave-based tunings, and the two
non-octave scales.

The other 20 tunings can be generated from the formula and checked against their
checksums here. A checksum alone would not catch every mistake, so the full
messages are the stronger test.

| Tuning | `step` | Checksum |
|---|---|---|
| 5-tET | 12/5 | `2F` |
| 7-tET | 12/7 | `69` |
| 8-tET | 12/8 | `5B` |
| 9-tET | 12/9 | `5D` |
| 10-tET | 12/10 | `1D` |
| 11-tET | 12/11 | `1F` |
| 12-tET | 12/12 | `71` |
| 13-tET | 12/13 | `59` |
| 14-tET | 12/14 | `53` |
| 15-tET | 12/15 | `4D` |
| 16-tET | 12/16 | `0D` |
| 17-tET | 12/17 | `73` |
| 18-tET | 12/18 | `50` |
| 19-tET | 12/19 | `5D` |
| 20-tET | 12/20 | `6F` |
| 21-tET | 12/21 | `16` |
| 22-tET | 12/22 | `35` |
| 23-tET | 12/23 | `39` |
| 24-tET | 12/24 | `7B` |
| 25-tET | 12/25 | `06` |
| 31-tET | 12/31 | `6A` |
| 34-tET | 12/34 | `4D` |
| 41-tET | 12/41 | `4B` |
| 53-tET | 12/53 | `31` |
| 88CET | 0.88 | `04` |
| Bohlen-Pierce | 12 × log2(3) / 13 | `21` |

### Octave dump (not hardware-tested)

No verified octave dump exists yet. This one comes from the forum thread above,
and it is a 12-note scale, with checksum `33`. Its checksum matches the rule in
this document. It tests the framing, not behavior on the instrument.

```
F0 43 00 7E 00 22 4C 4D 20 20 4D 43 52 54 45 30
3C 00 3C 2D 3D 1A 3E 34 3F 21 40 3C 41 29 42 16
43 30 44 1E 45 38 46 25 33 F7
```

### 12-tET

From `Set 12-tET.mid`, with checksum `71`.

```
F0 43 00 7E 02 0A 4C 4D 20 20 4D 43 52 54 45 31
0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00
0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0E 00 0F 00
10 00 11 00 12 00 13 00 14 00 15 00 16 00 17 00
18 00 19 00 1A 00 1B 00 1C 00 1D 00 1E 00 1F 00
20 00 21 00 22 00 23 00 24 00 25 00 26 00 27 00
28 00 29 00 2A 00 2B 00 2C 00 2D 00 2E 00 2F 00
30 00 31 00 32 00 33 00 34 00 35 00 36 00 37 00
38 00 39 00 3A 00 3B 00 3C 00 3D 00 3E 00 3F 00
40 00 41 00 42 00 43 00 44 00 45 00 46 00 47 00
48 00 49 00 4A 00 4B 00 4C 00 4D 00 4E 00 4F 00
50 00 51 00 52 00 53 00 54 00 55 00 56 00 57 00
58 00 59 00 5A 00 5B 00 5C 00 5D 00 5E 00 5F 00
60 00 61 00 62 00 63 00 64 00 65 00 66 00 67 00
68 00 69 00 6A 00 6B 00 6C 00 6C 3F 6C 3F 6C 3F
6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
71 F7
```

### 15-tET

From `Set 15-tET.mid`, with checksum `4D`.

```
F0 43 00 7E 02 0A 4C 4D 20 20 4D 43 52 54 45 31
0D 33 0E 26 0F 1A 10 0D 11 00 11 33 12 26 13 1A
14 0D 15 00 15 33 16 26 17 1A 18 0D 19 00 19 33
1A 26 1B 1A 1C 0D 1D 00 1D 33 1E 26 1F 1A 20 0D
21 00 21 33 22 26 23 1A 24 0D 25 00 25 33 26 26
27 1A 28 0D 29 00 29 33 2A 26 2B 1A 2C 0D 2D 00
2D 33 2E 26 2F 1A 30 0D 31 00 31 33 32 26 33 1A
34 0D 35 00 35 33 36 26 37 1A 38 0D 39 00 39 33
3A 26 3B 1A 3C 0D 3D 00 3D 33 3E 26 3F 1A 40 0D
41 00 41 33 42 26 43 1A 44 0D 45 00 45 33 46 26
47 1A 48 0D 49 00 49 33 4A 26 4B 1A 4C 0D 4D 00
4D 33 4E 26 4F 1A 50 0D 51 00 51 33 52 26 53 1A
54 0D 55 00 55 33 56 26 57 1A 58 0D 59 00 59 33
5A 26 5B 1A 5C 0D 5D 00 5D 33 5E 26 5F 1A 60 0D
61 00 61 33 62 26 63 1A 64 0D 65 00 65 33 66 26
67 1A 68 0D 69 00 69 33 6A 26 6B 1A 6C 0D 6C 3F
6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
4D F7
```

### 17-tET

From `Set 17-tET.mid`, with checksum `73`.

```
F0 43 00 7E 02 0A 4C 4D 20 20 4D 43 52 54 45 31
14 13 15 00 15 2D 16 1A 17 08 17 35 18 22 19 0F
19 3C 1A 29 1B 17 1C 04 1C 31 1D 1E 1E 0B 1E 38
1F 26 20 13 21 00 21 2D 22 1A 23 08 23 35 24 22
25 0F 25 3C 26 29 27 17 28 04 28 31 29 1E 2A 0B
2A 38 2B 26 2C 13 2D 00 2D 2D 2E 1A 2F 08 2F 35
30 22 31 0F 31 3C 32 29 33 17 34 04 34 31 35 1E
36 0B 36 38 37 26 38 13 39 00 39 2D 3A 1A 3B 08
3B 35 3C 22 3D 0F 3D 3C 3E 29 3F 17 40 04 40 31
41 1E 42 0B 42 38 43 26 44 13 45 00 45 2D 46 1A
47 08 47 35 48 22 49 0F 49 3C 4A 29 4B 17 4C 04
4C 31 4D 1E 4E 0B 4E 38 4F 26 50 13 51 00 51 2D
52 1A 53 08 53 35 54 22 55 0F 55 3C 56 29 57 17
58 04 58 31 59 1E 5A 0B 5A 38 5B 26 5C 13 5D 00
5D 2D 5E 1A 5F 08 5F 35 60 22 61 0F 61 3C 62 29
63 17 64 04 64 31 65 1E 66 0B 66 38 67 26 68 13
69 00 69 2D 6A 1A 6B 08 6B 35 6C 22 6C 3F 6C 3F
73 F7
```

### 19-tET

From `Set 19-tET.mid`, with checksum `5D`.

```
F0 43 00 7E 02 0A 4C 4D 20 20 4D 43 52 54 45 31
19 1B 1A 03 1A 2C 1B 14 1B 3D 1C 25 1D 0D 1D 36
1E 1E 1F 07 1F 2F 20 18 21 00 21 28 22 11 22 39
23 22 24 0A 24 33 25 1B 26 03 26 2C 27 14 27 3D
28 25 29 0D 29 36 2A 1E 2B 07 2B 2F 2C 18 2D 00
2D 28 2E 11 2E 39 2F 22 30 0A 30 33 31 1B 32 03
32 2C 33 14 33 3D 34 25 35 0D 35 36 36 1E 37 07
37 2F 38 18 39 00 39 28 3A 11 3A 39 3B 22 3C 0A
3C 33 3D 1B 3E 03 3E 2C 3F 14 3F 3D 40 25 41 0D
41 36 42 1E 43 07 43 2F 44 18 45 00 45 28 46 11
46 39 47 22 48 0A 48 33 49 1B 4A 03 4A 2C 4B 14
4B 3D 4C 25 4D 0D 4D 36 4E 1E 4F 07 4F 2F 50 18
51 00 51 28 52 11 52 39 53 22 54 0A 54 33 55 1B
56 03 56 2C 57 14 57 3D 58 25 59 0D 59 36 5A 1E
5B 07 5B 2F 5C 18 5D 00 5D 28 5E 11 5E 39 5F 22
60 0A 60 33 61 1B 62 03 62 2C 63 14 63 3D 64 25
65 0D 65 36 66 1E 67 07 67 2F 68 18 69 00 69 28
5D F7
```

### 88CET

From `Set 88CET.mid`, with checksum `04`.

```
F0 43 00 7E 02 0A 4C 4D 20 20 4D 43 52 54 45 31
0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 24 0E 1C
0F 14 10 0D 11 05 11 3D 12 36 13 2E 14 26 15 1F
16 17 17 0F 18 08 19 00 19 38 1A 31 1B 29 1C 21
1D 1A 1E 12 1F 0A 20 03 20 3B 21 33 22 2C 23 24
24 1C 25 14 26 0D 27 05 27 3D 28 36 29 2E 2A 26
2B 1F 2C 17 2D 0F 2E 08 2F 00 2F 38 30 31 31 29
32 21 33 1A 34 12 35 0A 36 03 36 3B 37 33 38 2C
39 24 3A 1C 3B 14 3C 0D 3D 05 3D 3D 3E 36 3F 2E
40 26 41 1F 42 17 43 0F 44 08 45 00 45 38 46 31
47 29 48 21 49 1A 4A 12 4B 0A 4C 03 4C 3B 4D 33
4E 2C 4F 24 50 1C 51 14 52 0D 53 05 53 3D 54 36
55 2E 56 26 57 1F 58 17 59 0F 5A 08 5B 00 5B 38
5C 31 5D 29 5E 21 5F 1A 60 12 61 0A 62 03 62 3B
63 33 64 2C 65 24 66 1C 67 14 68 0D 69 05 69 3D
6A 36 6B 2E 6C 26 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
04 F7
```

### Bohlen-Pierce

From `Set Bohlen-Pierce.mid`, with checksum `21`.

```
F0 43 00 7E 02 0A 4C 4D 20 20 4D 43 52 54 45 31
0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00
0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00
0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00
0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 00 0D 1A
0E 38 10 15 11 33 13 10 14 2E 16 0C 17 29 19 07
1A 25 1C 02 1D 20 1E 3D 20 1B 21 39 23 16 24 34
26 12 27 2F 29 0D 2A 2B 2C 08 2D 26 2F 03 30 21
31 3F 33 1C 34 3A 36 18 37 35 39 13 3A 31 3C 0E
3D 2C 3F 09 40 27 42 05 43 22 45 00 46 1E 47 3B
49 19 4A 37 4C 14 4D 32 4F 0F 50 2D 52 0B 53 28
55 06 56 24 58 01 59 1F 5A 3D 5C 1A 5D 38 5F 15
60 33 62 11 63 2E 65 0C 66 2A 68 07 69 25 6B 03
6C 20 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F 6C 3F
21 F7
```
