# Reading messy files

Use lenient parsing to recover from common real-world SMF deviations, inspect what
was repaired, and re-export a clean file.

## Overview

Real-world MIDI files frequently deviate from the RP-001 specification — truncated chunk
lengths, missing End-of-Track markers, extra bytes after the last event, or track-count
mismatches in the header are all common. Strict parsing (the default) throws on any such
deviation; lenient parsing repairs what it can and reports what it found.

## Parse in lenient mode

Create a parser with ``SMFParser/Strictness/lenient`` and call
``SMFParser/parseWithDiagnostics(_:)`` instead of ``SMFParser/parse(_:)``:

```swift
import IvorMIDI

let data = try Data(contentsOf: fileURL)
let parser = SMFParser(strictness: .lenient)

let (sequence, diagnostics) = try parser.parseWithDiagnostics(data)
```

If the file is beyond recovery (for example, the header chunk is completely absent or the
format byte is invalid) ``parseWithDiagnostics(_:)`` still throws a ``SMFParseError``. Lenient
mode only handles deviations it can repair without losing data.

## Inspect the diagnostics

Each ``SMFDiagnostic`` value describes one repair the parser made. Log them or present them to
the user:

```swift
if diagnostics.isEmpty {
    print("File is clean")
} else {
    print("Repaired \(diagnostics.count) issue(s):")
    for diagnostic in diagnostics {
        print("  • \(diagnostic.message)")
    }
}
```

The possible diagnostics are:

| Case | Meaning |
|------|---------|
| ``SMFDiagnostic/chunkLengthClamped(declared:available:)`` | A chunk's declared length exceeded the remaining data; clamped to what was available. |
| ``SMFDiagnostic/missingEndOfTrack(trackIndex:)`` | A track had no End-of-Track meta-event. |
| ``SMFDiagnostic/strayRealTimeByteSkipped`` | A system real-time byte (0xF8–0xFE) appeared in the event stream and was discarded. |
| ``SMFDiagnostic/trackCountMismatch(declared:actual:)`` | The header's `ntrks` field did not match the number of MTrk chunks found. |
| ``SMFDiagnostic/trackFormatCoerced(from:to:)`` | A format-0 file contained multiple tracks and was reinterpreted as format 1. |

## Validate the repaired sequence

Even after successful lenient parsing the resulting ``SMFSequence`` may have higher-level
issues. Run ``SMFSequence/validate()`` to find them:

```swift
let issues = sequence.validate()

let errors = issues.filter { $0.severity == .error }
let warnings = issues.filter { $0.severity == .warning }

if !errors.isEmpty {
    print("\(errors.count) error(s) — formatting will fail:")
    for issue in errors { print("  ✕ \(issue.message)") }
}

if !warnings.isEmpty {
    print("\(warnings.count) warning(s) — interoperability may be affected:")
    for issue in warnings { print("  ⚠ \(issue.message)") }
}
```

Error-severity issues (``SMFValidationIssue/eventAfterEndOfTrack(trackIndex:)`` and
``SMFValidationIssue/missingEndOfTrack(trackIndex:)``) mean that ``SMFFormatter`` will throw if
you try to re-export as-is. Warning-severity issues (tempo or time-signature events in the
wrong track, sequence number not at time zero) are spec violations that may cause playback
problems but do not prevent formatting.

## Re-export a clean file

``SMFFormatter`` automatically appends a missing End-of-Track event to any track that lacks
one, so a sequence with ``SMFDiagnostic/missingEndOfTrack(trackIndex:)`` diagnostics can be
re-exported cleanly without manual repair. A sequence with
``SMFValidationIssue/eventAfterEndOfTrack(trackIndex:)`` errors requires manual intervention
before formatting:

```swift
// Only re-export if there are no error-severity issues
guard issues.filter({ $0.severity == .error }).isEmpty else {
    print("Cannot reformat: sequence has error-severity issues")
    return
}

let cleanData = try SMFFormatter().format(sequence)
try cleanData.write(to: outputURL)
```
