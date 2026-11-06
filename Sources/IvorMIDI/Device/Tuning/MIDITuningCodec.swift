// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that converts between a device’s tuning messages and shared values.
///
/// A codec performs no I/O. It builds messages for a caller to send, and reads
/// messages that a caller received, so the same calling code works with any
/// device, whether its messages are universal or manufacturer-specific.
///
/// This protocol is provisional, and may change when a device needs a different
/// format.
public protocol MIDITuningCodec: Sendable {

    // MARK: Public Instance Properties

    /// The slot to use when a caller doesn’t need a particular one.
    var defaultSlot: MIDITuningSlot { get }

    /// What this codec’s device can store.
    var limits: MIDITuningLimits { get }

    /// The addresses to try when searching for a device with this codec.
    var probeAddresses: [MIDIDeviceAddress] { get }

    // MARK: Public Instance Methods

    /// Returns the output that installs a tuning in a slot.
    ///
    /// - Parameter tuning:     The tuning to install.
    /// - Parameter slot:       The slot to install it in.
    /// - Parameter address:    The address of the device.
    ///
    /// - Returns:  The messages to send, and what the caller needs to know
    ///             about them.
    ///
    /// - Throws:   A ``MIDITuningError`` if this device can’t use the tuning,
    ///             the slot, or the address.
    func messages(for tuning: MIDIDeviceTuning,
                  slot: MIDITuningSlot,
                  address: MIDIDeviceAddress) throws -> MIDITuningOutput

    /// Returns the messages that ask a device for the tuning in a slot.
    ///
    /// - Parameter slot:       The slot to ask for.
    /// - Parameter address:    The address of the device.
    ///
    /// - Returns:  The messages to send, in order.
    ///
    /// - Throws:   A ``MIDITuningError`` if this device can’t use the slot or
    ///             the address.
    func requestMessages(slot: MIDITuningSlot,
                         address: MIDIDeviceAddress) throws -> [MIDISystemMessage]

    /// Returns the channel messages that make a stored tuning sound on the
    /// provided channels.
    ///
    /// A codec returns no messages if installing a tuning already selects it.
    ///
    /// - Parameter slot:       The slot that holds the tuning.
    /// - Parameter channels:   The channels in use.
    ///
    /// - Returns:  The messages to send, in order.
    ///
    /// - Throws:   A ``MIDITuningError`` if this device can’t use the slot.
    func selectionMessages(slot: MIDITuningSlot,
                           channels: [MIDIChannel]) throws -> [MIDIChannelMessage]

    /// Returns the tuning held in a message from a device, or `nil` if the
    /// message doesn’t hold one that this codec understands.
    ///
    /// - Parameter message:    The message to decode.
    ///
    /// - Returns:  The tuning, or `nil`.
    func tuning(from message: MIDISystemMessage) -> MIDIDeviceTuning?
}
