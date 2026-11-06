// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

// A pitch in a TX81Z tuning table, from 13,0 to 108,63.
//
// uintValue is the manual’s 0–6,143 scale, in 1/64 semitone above note 13. The
// fraction is unsigned: the manual’s “−31 to −1” describes the LCD only, which
// shows values of 33–63 as an offset from the next note up.
//
// A frequency can move by up to about 0.78 cents when it becomes a pitch, so it
// doesn’t survive a round trip, while pitch → frequency → pitch is lossless.
internal struct TX81ZPitch {

    // MARK: Internal Initializers

    // Creates a pitch from a frequency, moving it into range, or returns nil for
    // MIDITuningFrequency.noChange.
    internal init?(clamping frequency: MIDITuningFrequency) {
        guard frequency != .noChange
        else { return nil }

        self.init(absoluteValue: Self._absoluteValue(frequency).clamped(to: Self.absoluteRange))
    }

    // Creates a pitch from semitones, moving it into range, or returns nil for
    // NaN. This takes a Double because generated scales can fall outside the
    // range of MIDITuningFrequency.
    internal init?(clampingSemitones semitones: Double) {
        guard !semitones.isNaN
        else { return nil }

        let lowest = Double(Self.absoluteRange.lowerBound)
        let highest = Double(Self.absoluteRange.upperBound)

        self.init(absoluteValue: Int(min(max((semitones * 64).rounded(), lowest), highest)))
    }

    // Creates a pitch from a frequency, or returns nil if it is out of range or
    // is MIDITuningFrequency.noChange.
    internal init?(frequency: MIDITuningFrequency) {
        let value = Self._absoluteValue(frequency)

        guard frequency != .noChange,
              Self.absoluteRange.contains(value)
        else { return nil }

        self.init(absoluteValue: value)
    }

    internal init?(note: MIDIData1Value,
                   fraction: MIDIData1Value = 0) {
        guard (13...108).contains(note.uintValue),
              (0...63).contains(fraction.uintValue)
        else { return nil }

        self.init(absoluteValue: Int(note.uintValue * 64 + fraction.uintValue))
    }

    // Creates a pitch from semitones, or returns nil if it is not finite or is
    // out of range. An exact half rounds up.
    internal init?(semitones: Double) {
        guard semitones.isFinite
        else { return nil }

        let value = (semitones * 64).rounded()

        guard value >= Double(Self.absoluteRange.lowerBound),
              value <= Double(Self.absoluteRange.upperBound)
        else { return nil }

        self.init(absoluteValue: Int(value))
    }

    internal init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Internal Instance Properties

    internal let uintValue: UInt

    // MARK: Private Initializers

    private init(absoluteValue: Int) {
        self.uintValue = UInt(absoluteValue - Self.absoluteRange.lowerBound)
    }
}

// MARK: -

extension TX81ZPitch {

    // MARK: Internal Type Properties

    internal static let highest = Self(6_143)
    internal static let lowest = Self(0)

    // MARK: Internal Type Methods

    internal static func isValid(_ uintValue: UInt) -> Bool {
        (0...6_143).contains(uintValue)
    }

    // MARK: Internal Instance Properties

    internal var fraction: MIDIData1Value {
        MIDIData1Value(clamping: absoluteValue & 0x3f)
    }

    internal var frequency: MIDITuningFrequency {
        MIDITuningFrequency(absoluteValue << 8)
    }

    internal var note: MIDIData1Value {
        MIDIData1Value(clamping: absoluteValue >> 6)
    }

    internal var semitones: Double {
        Double(absoluteValue) / 64
    }

    // MARK: Private Type Properties

    // The value of hh × 64 + ll, from 13,0 to 108,63.
    private static let absoluteRange = 832...6_975

    // MARK: Private Type Methods

    private static func _absoluteValue(_ frequency: MIDITuningFrequency) -> Int {
        Int((frequency.uintValue + 128) >> 8)
    }

    // MARK: Private Instance Properties

    private var absoluteValue: UInt {
        uintValue + UInt(Self.absoluteRange.lowerBound)
    }
}

// MARK: - MIDIBytesConvertible

extension TX81ZPitch: MIDIBytesConvertible {

    // MARK: Internal Initializers

    // This is strict, and doesn’t copy the firmware’s clean-up on receive.
    internal init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2,
              let note = MIDIData1Value(uintValue: UInt(bytesValue[0])),
              let fraction = MIDIData1Value(uintValue: UInt(bytesValue[1]))
        else { return nil }

        self.init(note: note,
                  fraction: fraction)
    }

    // MARK: Internal Instance Properties

    internal var bytesValue: [UInt8]? {
        [note.byteValue, fraction.byteValue]
    }
}

// MARK: - UIntRepresentable

extension TX81ZPitch: UIntRepresentable {
}
