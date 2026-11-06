// © 2026 John Gary Pusey (see LICENSE.md)

/// A MIDI patch: a program and, optionally, the bank it comes from.
///
/// A channel is set to a patch with a bank select, if the patch has a bank,
/// then a program change. Use ``selectionMessages(on:after:)`` to build them.
public struct MIDIPatch {

    // MARK: Public Initializers

    /// Creates a `MIDIPatch` instance with the provided program and bank.
    ///
    /// - Parameter program:    The program.
    /// - Parameter bank:       The bank, or `nil` to select no bank.
    public init(program: MIDIProgram,
                bank: MIDIBank? = nil) {
        self.bank = bank
        self.program = program
    }

    // MARK: Public Instance Properties

    /// The bank, or `nil` if the patch selects no bank.
    public let bank: MIDIBank?

    /// The program.
    public let program: MIDIProgram
}

// MARK: -

extension MIDIPatch {

    // MARK: Public Instance Methods

    /// Returns the channel messages that set the provided channel to this
    /// patch, given the patch it had.
    ///
    /// The messages are a bank select MSB and LSB, if this patch has a bank,
    /// then a program change. A patch without a bank still selects bank 0 if
    /// the previous patch had a bank, so the channel doesn’t stay in it.
    ///
    /// - Parameter channel:    The channel to set.
    /// - Parameter previous:   The patch the channel had, or `nil` if it had
    ///                         none.
    ///
    /// - Returns:  The bank select and program change messages, in the order
    ///             to send them.
    public func selectionMessages(on channel: MIDIChannel,
                                  after previous: Self?) -> [MIDIChannelMessage] {
        var messages: [MIDIChannelMessage] = []

        if let bank = bank ?? (previous?.bank == nil ? nil : Self.defaultBank) {
            messages.append(.controlChange(channel, .bankSelectMSB, bank.msb))
            messages.append(.controlChange(channel, .bankSelectLSB, bank.lsb))
        }

        messages.append(.programChange(channel, program))

        return messages
    }

    // MARK: Private Type Properties

    private static let defaultBank = MIDIBank(msb: MIDIData1Value(clamping: 0),
                                              lsb: MIDIData1Value(clamping: 0))
}

// MARK: - Codable

extension MIDIPatch: Codable {
}

// MARK: - Hashable

extension MIDIPatch: Hashable {
}

// MARK: - Sendable

extension MIDIPatch: Sendable {
}
