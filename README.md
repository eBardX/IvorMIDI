# IvorMIDI

MIDI channel message, system message, and data value types.

[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/eBardX/IvorMIDI/blob/main/LICENSE.md)

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
    * [Swift Package Manager](#spm_installation)
* [Quick Start](#quick_start)
* [Documentation](#documentation)
* [Reference Documentation](#reference_documentation)
* [Credits](#credits)
* [License](#license)

## <a name="overview">Overview</a>

The IvorMIDI framework provides MIDI channel message, system message, and data
value types written in Swift. Channel messages cover note on and off,
polyphonic and channel pressure, control change, program change, and pitch
bend change; system messages cover system exclusive, system common, and system
real-time messages. Channel and system messages, and the data values they
carry, can be converted to and from their [MIDI 1.0][midi1] wire encoding.

Registered (RPN) and non-registered (NRPN) parameters, such as pitch bend
sensitivity and fine tuning, can be set with a single call that builds the
whole control change sequence. Universal system exclusive messages for master
volume, master tuning, and all of the MIDI Tuning Standard are built the same
way, as are the bank select and program change messages that set a channel to
a `MIDIPatch`. `MIDITuningMessage` decodes MIDI Tuning Standard messages. A
`MIDIPitchBend` can be made from a bend in cents and the synthesizer's pitch
bend sensitivity.

## <a name="requirements">Requirements</a>

* iOS 18.0+ / macOS 15.0+
* Swift 6.3 toolchain
* Swift 6 language mode

## <a name="installation">Installation</a>

### <a name="spm_installation">Swift Package Manager</a>

IvorMIDI is distributed exclusively through the [Swift Package Manager][spm].

To add IvorMIDI to a Swift package, add it to the `dependencies` in your
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eBardX/IvorMIDI.git",
             .upToNextMinor(from: "0.4.0"))
]
```

Then add `IvorMIDI` to the dependencies of any target that uses it:

```swift
.target(name: "MyTarget",
        dependencies: [.product(name: "IvorMIDI",
                                package: "IvorMIDI")])
```

To add IvorMIDI to an Xcode project, choose **File ▸ Add Package Dependencies…**
and enter the repository URL:

```
https://github.com/eBardX/IvorMIDI.git
```

IvorMIDI depends on [XestiTools][xestitools]; the Swift Package Manager resolves
it automatically.

## <a name="quick_start">Quick Start</a>

Build a message, encode it, and decode it again:

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

For the complete story — the data values, the parameter and patch builders,
universal system exclusive messages, MIDI tuning, and the wire encoding — see
the [usage guide][guide].

## <a name="documentation">Documentation</a>

* [Using IvorMIDI][guide] — a guide to using the public API, published as part
  of the DocC documentation.
* Every public declaration carries a DocC comment.

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorMIDI is available under [the MIT license][license].

[docc]:         https://www.swift.org/documentation/docc/
[guide]:        https://eBardX.github.io/ivor-packages-docs/documentation/ivormidi/usingivormidi
[license]:      https://github.com/eBardX/IvorMIDI/blob/main/LICENSE.md
[midi1]:        https://midi.org/midi-1-0
[refdoc]:       https://eBardX.github.io/ivor-packages-docs/documentation/ivormidi
[spm]:          https://swift.org/package-manager/
[xestitools]:   https://github.com/eBardX/XestiTools
