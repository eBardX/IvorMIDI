// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI

// Golden messages from TX81Z_TUNING.md. These include F0.
extension Fixtures {

    // MARK: Internal Type Properties

    static let bohlenPierceStep = 12 * log2(3.0) / 13

    static let tx81z12TET = _bytes(hex: """
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
        """)

    static let tx81z15TET = _bytes(hex: """
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
        """)

    static let tx81z17TET = _bytes(hex: """
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
        """)

    static let tx81z19TET = _bytes(hex: """
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
        """)

    static let tx81z88CET = _bytes(hex: """
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
        """)

    static let tx81zAllVectors = tx81zFullKeyboardVectors.map(\.bytes) + [tx81zOctaveDump]

    static let tx81zBohlenPierce = _bytes(hex: """
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
        """)

    static let tx81zChecksums: [(name: String, step: Double, checksum: UInt8)] = [(name: "5-tET", step: 12.0 / 5, checksum: 0x2f),
                                                                                  (name: "7-tET", step: 12.0 / 7, checksum: 0x69),
                                                                                  (name: "8-tET", step: 12.0 / 8, checksum: 0x5b),
                                                                                  (name: "9-tET", step: 12.0 / 9, checksum: 0x5d),
                                                                                  (name: "10-tET", step: 12.0 / 10, checksum: 0x1d),
                                                                                  (name: "11-tET", step: 12.0 / 11, checksum: 0x1f),
                                                                                  (name: "12-tET", step: 12.0 / 12, checksum: 0x71),
                                                                                  (name: "13-tET", step: 12.0 / 13, checksum: 0x59),
                                                                                  (name: "14-tET", step: 12.0 / 14, checksum: 0x53),
                                                                                  (name: "15-tET", step: 12.0 / 15, checksum: 0x4d),
                                                                                  (name: "16-tET", step: 12.0 / 16, checksum: 0x0d),
                                                                                  (name: "17-tET", step: 12.0 / 17, checksum: 0x73),
                                                                                  (name: "18-tET", step: 12.0 / 18, checksum: 0x50),
                                                                                  (name: "19-tET", step: 12.0 / 19, checksum: 0x5d),
                                                                                  (name: "20-tET", step: 12.0 / 20, checksum: 0x6f),
                                                                                  (name: "21-tET", step: 12.0 / 21, checksum: 0x16),
                                                                                  (name: "22-tET", step: 12.0 / 22, checksum: 0x35),
                                                                                  (name: "23-tET", step: 12.0 / 23, checksum: 0x39),
                                                                                  (name: "24-tET", step: 12.0 / 24, checksum: 0x7b),
                                                                                  (name: "25-tET", step: 12.0 / 25, checksum: 0x06),
                                                                                  (name: "31-tET", step: 12.0 / 31, checksum: 0x6a),
                                                                                  (name: "34-tET", step: 12.0 / 34, checksum: 0x4d),
                                                                                  (name: "41-tET", step: 12.0 / 41, checksum: 0x4b),
                                                                                  (name: "53-tET", step: 12.0 / 53, checksum: 0x31),
                                                                                  (name: "88CET", step: 0.88, checksum: 0x04),
                                                                                  (name: "Bohlen-Pierce", step: bohlenPierceStep, checksum: 0x21)]

    static let tx81zFullKeyboardVectors: [(step: Double, bytes: [UInt8])] = [(step: 12.0 / 12, bytes: tx81z12TET),
                                                                             (step: 12.0 / 15, bytes: tx81z15TET),
                                                                             (step: 12.0 / 17, bytes: tx81z17TET),
                                                                             (step: 12.0 / 19, bytes: tx81z19TET),
                                                                             (step: 0.88, bytes: tx81z88CET),
                                                                             (step: bohlenPierceStep, bytes: tx81zBohlenPierce)]

    static let tx81zOctaveDump = _bytes(hex: """
        F0 43 00 7E 00 22 4C 4D 20 20 4D 43 52 54 45 30
        3C 00 3C 2D 3D 1A 3E 34 3F 21 40 3C 41 29 42 16
        43 30 44 1E 45 38 46 25 33 F7
        """)

    // MARK: Internal Type Methods

    // A key of a scale, moved into the range of MIDITuningFrequency.
    static func tx81zFrequencies(step: Double) -> [MIDITuningFrequency] {
        (0..<128).compactMap { key in
            let value = ((69 + Double(key - 69) * step) * 16_384).rounded()

            return MIDITuningFrequency(uintValue: UInt(min(max(value, 0), 2_097_150)))
        }
    }

    static func tx81zPitches(step: Double) -> [TX81ZPitch] {
        (0..<128).compactMap { TX81ZPitch(clampingSemitones: 69 + Double($0 - 69) * step) }
    }

    // MARK: Private Type Methods

    private static func _bytes(hex: String) -> [UInt8] {
        hex.split(whereSeparator: \.isWhitespace).compactMap { UInt8($0, radix: 16) }
    }
}
