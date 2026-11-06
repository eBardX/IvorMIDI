// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDITuningSlot {

    // MARK: Public Type Properties

    /// The editable full keyboard tuning table of a TX81Z, with 128 keys.
    public static let tx81zFullKeyboard = Self.table(1)

    /// The editable octave tuning table of a TX81Z, with 12 notes that repeat
    /// up and down the keyboard.
    public static let tx81zOctave = Self.table(0)
}
