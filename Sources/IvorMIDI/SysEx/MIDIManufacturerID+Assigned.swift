// © 2026 John Gary Pusey (see LICENSE.md)

// Widely known manufacturer IDs, from the MIDI Association’s table of assigned
// IDs (https://midi.org/SysExIDtable). This is a selection, not the full table.
// Any other assigned ID can be created with init?(bytes:).
extension MIDIManufacturerID {

    // MARK: Public Type Properties

    /// The manufacturer ID of Ableton (0x00 0x21 0x1D).
    public static let ableton = Self(uncheckedBytes: [0x00, 0x21, 0x1d])

    /// The manufacturer ID of Access Music Electronics (0x00 0x20 0x33).
    public static let access = Self(uncheckedBytes: [0x00, 0x20, 0x33])

    /// The manufacturer ID of Akai (0x47).
    public static let akai = Self(uncheckedBytes: [0x47])

    /// The manufacturer ID of Alesis (0x00 0x00 0x0E).
    public static let alesis = Self(uncheckedBytes: [0x00, 0x00, 0x0e])

    /// The manufacturer ID of Apple (0x11).
    public static let apple = Self(uncheckedBytes: [0x11])

    /// The manufacturer ID of Arturia (0x00 0x20 0x6B).
    public static let arturia = Self(uncheckedBytes: [0x00, 0x20, 0x6b])

    /// The manufacturer ID of Behringer (0x00 0x20 0x32).
    public static let behringer = Self(uncheckedBytes: [0x00, 0x20, 0x32])

    /// The manufacturer ID of Casio (0x44).
    public static let casio = Self(uncheckedBytes: [0x44])

    /// The manufacturer ID of Clavia Digital Instruments (0x33).
    public static let clavia = Self(uncheckedBytes: [0x33])

    /// The manufacturer ID of Digidesign (0x13).
    public static let digidesign = Self(uncheckedBytes: [0x13])

    /// The manufacturer ID of Elektron (0x00 0x20 0x3C).
    public static let elektron = Self(uncheckedBytes: [0x00, 0x20, 0x3c])

    /// The manufacturer ID of E-mu (0x18).
    public static let emu = Self(uncheckedBytes: [0x18])

    /// The manufacturer ID of Ensoniq (0x0F).
    public static let ensoniq = Self(uncheckedBytes: [0x0f])

    /// The manufacturer ID of Eventide (0x1C).
    public static let eventide = Self(uncheckedBytes: [0x1c])

    /// The manufacturer ID of Fender (0x08).
    public static let fender = Self(uncheckedBytes: [0x08])

    /// The manufacturer ID of IK Multimedia (0x00 0x21 0x1A).
    public static let ikMultimedia = Self(uncheckedBytes: [0x00, 0x21, 0x1a])

    /// The manufacturer ID of Kawai (0x40).
    public static let kawai = Self(uncheckedBytes: [0x40])

    /// The manufacturer ID of Korg (0x42).
    public static let korg = Self(uncheckedBytes: [0x42])

    /// The manufacturer ID of Kurzweil / Young Chang (0x07).
    public static let kurzweil = Self(uncheckedBytes: [0x07])

    /// The manufacturer ID of Lexicon (0x06).
    public static let lexicon = Self(uncheckedBytes: [0x06])

    /// The manufacturer ID of Line 6 (0x00 0x01 0x0C).
    public static let line6 = Self(uncheckedBytes: [0x00, 0x01, 0x0c])

    /// The manufacturer ID of Loud Technologies / Mackie (0x00 0x00 0x66).
    public static let mackie = Self(uncheckedBytes: [0x00, 0x00, 0x66])

    /// The manufacturer ID of M-Audio (0x00 0x01 0x05).
    public static let mAudio = Self(uncheckedBytes: [0x00, 0x01, 0x05])

    /// The manufacturer ID of Microsoft (0x00 0x00 0x41).
    public static let microsoft = Self(uncheckedBytes: [0x00, 0x00, 0x41])

    /// The manufacturer ID of Moog Music (0x04).
    public static let moog = Self(uncheckedBytes: [0x04])

    /// The manufacturer ID of Mark of the Unicorn (0x00 0x00 0x3B).
    public static let motu = Self(uncheckedBytes: [0x00, 0x00, 0x3b])

    /// The manufacturer ID of Native Instruments (0x00 0x21 0x09).
    public static let nativeInstruments = Self(uncheckedBytes: [0x00, 0x21, 0x09])

    /// The manufacturer ID of Focusrite/Novation (0x00 0x20 0x29).
    public static let novation = Self(uncheckedBytes: [0x00, 0x20, 0x29])

    /// The manufacturer ID of Oberheim (0x10).
    public static let oberheim = Self(uncheckedBytes: [0x10])

    /// The manufacturer ID of PreSonus (0x00 0x01 0x06).
    public static let presonus = Self(uncheckedBytes: [0x00, 0x01, 0x06])

    /// The manufacturer ID of Roland (0x41).
    public static let roland = Self(uncheckedBytes: [0x41])

    /// The manufacturer ID of ROLI (0x00 0x21 0x10).
    public static let roli = Self(uncheckedBytes: [0x00, 0x21, 0x10])

    /// The manufacturer ID of Sequential Circuits (0x01).
    public static let sequential = Self(uncheckedBytes: [0x01])

    /// The manufacturer ID of Steinberg (0x3A).
    public static let steinberg = Self(uncheckedBytes: [0x3a])

    /// The manufacturer ID of Teenage Engineering (0x00 0x20 0x76).
    public static let teenageEngineering = Self(uncheckedBytes: [0x00, 0x20, 0x76])

    /// The manufacturer ID of Waldorf (0x3E).
    public static let waldorf = Self(uncheckedBytes: [0x3e])

    /// The manufacturer ID of Yamaha (0x43).
    public static let yamaha = Self(uncheckedBytes: [0x43])

    /// The manufacturer ID of Zoom (0x52).
    public static let zoom = Self(uncheckedBytes: [0x52])
}
