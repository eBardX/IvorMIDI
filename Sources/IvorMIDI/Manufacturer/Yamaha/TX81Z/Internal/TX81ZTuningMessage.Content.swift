// © 2026 John Gary Pusey (see LICENSE.md)

extension TX81ZTuningMessage {

    // The content of a TX81Z tuning message. Instruments are numbered 1–8, as in
    // the manual.
    internal enum Content {
        case dump(TX81ZTuningTable, pitches: [TX81ZPitch])
        case dumpRequest(TX81ZTuningTable)
        case microTuneEnable(instrument: MIDIData1Value, isEnabled: Bool)
        case microTuneKey(MIDIData1Value)
        case microTuneTable(TX81ZTuningSelection)
    }
}

// MARK: - Hashable

extension TX81ZTuningMessage.Content: Hashable {
}

// MARK: - Sendable

extension TX81ZTuningMessage.Content: Sendable {
}
