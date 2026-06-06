# ``IvorMIDI``

@Metadata {
    @PageColor(blue)
}

A Standard MIDI Files parser and formatter.

## Overview

IvorMIDI parses and formats [Standard MIDI Files](https://midi.org/standard-midi-files)
(SMF, RP-001). It handles all three SMF formats, all standard meta-event types, MIDI channel
messages, system-exclusive events, SMPTE time division, and the extended meta-event types
defined in RP-001 Appendix C (device name, program name, MIDI port, reserved text events
0x0A–0x0F).

### Parsing

``SMFParser`` decodes raw binary data into an ``SMFSequence``. By default it enforces strict
conformance to RP-001; any deviation causes a ``SMFParseError``. Pass
``SMFParser/Strictness/lenient`` to recover from common real-world issues instead — the parser
collects ``SMFDiagnostic`` values describing each deviation it repaired:

```swift
// Strict (default) — throws on any spec deviation
let sequence = try SMFParser().parse(data)

// Lenient — recovers from common issues and reports what was repaired
let (sequence, diagnostics) = try SMFParser(strictness: .lenient)
                                            .parseWithDiagnostics(data)
for diagnostic in diagnostics {
    print(diagnostic.message)
}
```

Lenient mode handles: truncated chunk lengths, missing End-of-Track events, stray
system-real-time bytes (0xF8–0xFE) embedded in the event stream, track-count mismatches
between the header and the actual MTrk chunks, and format-0 files that incorrectly contain
more than one track (coerced to format 1).

### Formatting

``SMFFormatter`` encodes an ``SMFSequence`` to binary data. It automatically appends an
End-of-Track meta-event to any track that lacks one, and throws ``SMFFormatError`` if a track
contains events after its End-of-Track marker:

```swift
let data = try SMFFormatter().format(sequence)
```

### Validation

``SMFSequence/validate()`` checks a sequence for spec violations without throwing, returning an
array of ``SMFValidationIssue`` values. Each issue has a ``SMFValidationIssue/severity``
(``SMFValidationIssue/Severity/error`` or ``SMFValidationIssue/Severity/warning``) and a
human-readable ``SMFValidationIssue/message``. An empty array means the sequence is fully
conformant:

```swift
let issues = sequence.validate()
if issues.isEmpty {
    print("Sequence is fully conformant")
} else {
    for issue in issues {
        print("[\(issue.severity)] \(issue.message)")
    }
}
```

Error-severity issues (missing or misplaced End-of-Track) will cause ``SMFFormatter`` to throw.
Warning-severity issues (tempo/time-signature in the wrong track, sequence number not at time
zero) may cause interoperability problems with some players.

### Scope and non-goals

IvorMIDI covers the RP-001 SMF specification as described above. The following are
**deliberately out of scope**:

- **RMID (`.rmi`) files** — the RIFF wrapper around an SMF payload is not supported.
- **Tempo-map to wall-clock conversion** — IvorMIDI works in ticks; converting to seconds
  requires integrating the tempo track, which is application-domain logic.
- **MIDI 2.0 / UMP** — IvorMIDI targets MIDI 1.0 SMF only.
- **Real-time MIDI I/O** — IvorMIDI is a file-format library; it does not transmit or receive
  live MIDI data.

## Topics

### Guides

- <doc:ReadingMessyFiles>

### Parsing

- ``SMFParser``
- ``SMFParser/Strictness``
- ``SMFDiagnostic``
- ``SMFParseError``

### Formatting

- ``SMFFormatter``
- ``SMFFormatError``

### Sequence model

- ``SMFSequence``
- ``SMFTrack``
- ``SMFEvent``
- ``SMFValidationIssue``
- ``SMFValidationIssue/Severity``

### Event content

- ``SMFMetaMessage``
- ``SMFSysExMessage``
- ``MIDIChannelMessage``
- ``MIDISystemMessage``

### Time and division

- ``SMFDivision``
- ``SMFTickRate``
- ``SMFEventTime``
- ``SMFTempo``
- ``SMFTimeSignature``
- ``SMPTETimeCode``
- ``SMPTETime``
- ``SMPTEFrameRate``

### Keys, text, and identifiers

- ``SMFKeySignature``
- ``SMFText``
- ``SMFData2Value``
- ``SMFFormat``

### MIDI primitives

- ``MIDIChannel``
- ``MIDIController``
- ``MIDIData1Value``
- ``MIDIData2Value``
- ``MIDIPitchBend``

### Protocols

- ``BytesValueConvertible``
