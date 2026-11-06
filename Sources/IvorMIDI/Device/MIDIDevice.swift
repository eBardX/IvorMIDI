// © 2026 John Gary Pusey (see LICENSE.md)

/// One device in use, however it was found.
///
/// A device can come from a matched Identity Reply, from the user choosing a
/// model, or from a search that found a working codec with no known model.
///
/// ```swift
/// guard let codec = device.tuningCodec
/// else { return }     // this device has no known tuning support
///
/// let slot = codec.defaultSlot
/// let output = try codec.messages(for: tuning,
///                                 slot: slot,
///                                 address: device.address)
/// let selection = try codec.selectionMessages(slot: slot,
///                                             channels: channels)
///
/// // Show output.prerequisites and output.adjustments, then send
/// // output.messages, followed by selection.
/// ```
public struct MIDIDevice {

    // MARK: Public Initializers

    /// Creates a `MIDIDevice` instance from a model, which also provides the
    /// codec.
    ///
    /// - Parameter model:      The model, matched from an identity or chosen
    ///                         by the user.
    /// - Parameter address:    How to reach the device.
    /// - Parameter identity:   What the device reported, or `nil` if it reported
    ///                         nothing.
    public init(model: MIDIDeviceModel,
                address: MIDIDeviceAddress,
                identity: MIDIDeviceIdentity? = nil) {
        self.address = address
        self.identity = identity
        self.model = model
        self.tuningCodec = model.tuningCodec
    }

    /// Creates a `MIDIDevice` instance with no known model.
    ///
    /// - Parameter tuningCodec:    The codec for the device’s tuning messages,
    ///                             or `nil` if it has no known tuning support.
    /// - Parameter address:        How to reach the device.
    /// - Parameter identity:       What the device reported, or `nil` if it
    ///                             reported nothing.
    public init(tuningCodec: (any MIDITuningCodec)?,
                address: MIDIDeviceAddress,
                identity: MIDIDeviceIdentity? = nil) {
        self.address = address
        self.identity = identity
        self.model = nil
        self.tuningCodec = tuningCodec
    }

    // MARK: Public Instance Properties

    /// How to reach the device.
    public let address: MIDIDeviceAddress

    /// What the device reported, or `nil` if it reported nothing.
    public let identity: MIDIDeviceIdentity?

    /// The model of the device, or `nil` if no model is known.
    public let model: MIDIDeviceModel?

    /// The codec for the device’s tuning messages, or `nil` if it has no known
    /// tuning support.
    public let tuningCodec: (any MIDITuningCodec)?
}

// MARK: - Sendable

extension MIDIDevice: Sendable {
}
