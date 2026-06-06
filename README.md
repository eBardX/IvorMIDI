# IvorMIDI

A Standard MIDI Files parser and formatter.

## <a name="overview">Overview</a>

The IvorMIDI framework provides a [Standard MIDI
Files](https://midi.org/standard-midi-files) parser and formatter written in
Swift.

### Parsing

`SMFParser` decodes raw binary data into an `SMFSequence`. By default it enforces strict
conformance to RP-001 and throws `SMFParseError` on any deviation. For real-world files that
bend the spec, pass `.lenient` to recover silently and collect `SMFDiagnostic` values
describing each repair:

```swift
// Strict (default)
let sequence = try SMFParser().parse(data)

// Lenient — recovers from common deviations and reports what was repaired
let (sequence, diagnostics) = try SMFParser(strictness: .lenient)
                                            .parseWithDiagnostics(data)
```

### Formatting

`SMFFormatter` encodes an `SMFSequence` to binary data. It automatically appends a missing
End-of-Track event to any track that lacks one:

```swift
let data = try SMFFormatter().format(sequence)
```

### Validation

`SMFSequence.validate()` checks a sequence for spec violations without throwing, returning
`[SMFValidationIssue]`. Each issue has a severity (`.error` or `.warning`) and a
human-readable message:

```swift
let issues = sequence.validate()
for issue in issues {
    print("[\(issue.severity)] \(issue.message)")
}
```

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorMIDI is available under [the MIT license][license].

[docc]:     https://www.swift.org/documentation/docc/
[license]:  https://github.com/eBardX/IvorMIDI/blob/main/LICENSE.md
[refdoc]:   https://eBardX.github.io/ivor-packages-docs/documentation/ivormidi
