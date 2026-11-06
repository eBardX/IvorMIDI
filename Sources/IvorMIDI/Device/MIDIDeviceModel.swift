// © 2026 John Gary Pusey (see LICENSE.md)

/// What is known about a model of device.
///
/// This is separate from ``MIDIDeviceIdentity``, which is what a device reports
/// about itself. Some devices report nothing, so a model’s family and member
/// codes are optional.
public struct MIDIDeviceModel {

    // MARK: Public Initializers

    /// Creates a `MIDIDeviceModel` instance with the provided values.
    ///
    /// - Parameter manufacturer:   The manufacturer of the model.
    /// - Parameter name:           The name of the model.
    /// - Parameter family:         The device family code, or `nil` if the
    ///                             model has no identity.
    /// - Parameter member:         The device family member code, or `nil` if
    ///                             the model has no identity.
    /// - Parameter tuningCodec:    The codec for the model’s tuning messages,
    ///                             or `nil` if it has no known tuning support.
    public init(manufacturer: MIDIManufacturerID,
                name: String,
                family: MIDIDeviceFamily? = nil,
                member: MIDIDeviceMember? = nil,
                tuningCodec: (any MIDITuningCodec)? = nil) {
        self.family = family
        self.manufacturer = manufacturer
        self.member = member
        self.name = name
        self.tuningCodec = tuningCodec
    }

    /// Creates a `MIDIDeviceModel` instance from the entry in IvorMIDI’s
    /// catalog that matches the provided identity, or `nil` if there is none.
    ///
    /// A model matches on its manufacturer, family, and member. The software
    /// revision doesn’t affect matching, and a model with no family or member
    /// never matches. A model defined in another package isn’t in the catalog,
    /// so it can’t be found this way.
    ///
    /// - Parameter identity:   The identity that a device reported.
    public init?(matching identity: MIDIDeviceIdentity) {
        self.init(matching: identity,
                  in: Self.catalog)
    }

    // MARK: Public Instance Properties

    /// The device family code, or `nil` if the model has no identity.
    public let family: MIDIDeviceFamily?

    /// The manufacturer of the model.
    public let manufacturer: MIDIManufacturerID

    /// The device family member code, or `nil` if the model has no identity.
    public let member: MIDIDeviceMember?

    /// The name of the model.
    public let name: String

    /// The codec for the model’s tuning messages, or `nil` if it has no known
    /// tuning support.
    public let tuningCodec: (any MIDITuningCodec)?

    // MARK: Internal Initializers

    internal init?(matching identity: MIDIDeviceIdentity,
                   in catalog: [Self]) {
        guard let model = catalog.first(where: { $0._matches(identity) })
        else { return nil }

        self = model
    }
}

// MARK: -

extension MIDIDeviceModel {

    // MARK: Internal Type Properties

    internal static let catalog: [Self] = [.yamahaDX11,
                                           .yamahaTX81Z]

    // MARK: Private Instance Methods

    private func _matches(_ identity: MIDIDeviceIdentity) -> Bool {
        manufacturer == identity.manufacturer
            && family == identity.family
            && member == identity.member
    }
}

// MARK: - Sendable

extension MIDIDeviceModel: Sendable {
}
