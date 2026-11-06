// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDIDeviceModel {

    // MARK: Public Type Properties

    /// The Yamaha DX11.
    ///
    /// This model assumes that a DX11 uses the same tuning format as a TX81Z.
    /// That rests on the dumps sent to both instruments and on a published
    /// write-up, not on the DX11’s firmware or a Yamaha manual.
    public static let yamahaDX11 = Self(manufacturer: .yamaha,
                                        name: "DX11",
                                        tuningCodec: TX81ZTuningCodec())

    /// The Yamaha TX81Z.
    ///
    /// A TX81Z ignores universal system exclusive messages, so it can’t answer an
    /// Identity Request, and this model has no family or member code.
    public static let yamahaTX81Z = Self(manufacturer: .yamaha,
                                         name: "TX81Z",
                                         tuningCodec: TX81ZTuningCodec())
}
