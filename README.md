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
* [Reference Documentation](#reference_documentation)
* [Credits](#credits)
* [License](#license)

## <a name="overview">Overview</a>

The IvorMIDI framework provides MIDI channel message, system message, and data
value types written in Swift. Channel messages cover note on and off,
polyphonic and channel pressure, control change, program change, and pitch
bend change; system messages cover system exclusive, system common, and system
real-time messages. Every message and data value can be converted to and from
its [MIDI 1.0][midi1] wire encoding.

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
             .upToNextMajor(from: "2.0.0"))
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

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorMIDI is available under [the MIT license][license].

[docc]:         https://www.swift.org/documentation/docc/
[license]:      https://github.com/eBardX/IvorMIDI/blob/main/LICENSE.md
[midi1]:        https://midi.org/midi-1-0
[refdoc]:       https://eBardX.github.io/ivor-packages-docs/documentation/ivormidi
[spm]:          https://swift.org/package-manager/
[xestitools]:   https://github.com/eBardX/XestiTools
