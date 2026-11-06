// © 2026 John Gary Pusey (see LICENSE.md)

/// What a device reports about itself in an Identity Reply.
public struct MIDIDeviceIdentity {

    // MARK: Public Initializers

    /// Creates a `MIDIDeviceIdentity` instance with the provided values.
    ///
    /// - Parameter manufacturer:       The manufacturer of the device.
    /// - Parameter family:             The device family code.
    /// - Parameter member:             The device family member code.
    /// - Parameter softwareRevision:   The software revision. A valid revision
    ///                                 has 4 data bytes.
    public init(manufacturer: MIDIManufacturerID,
                family: MIDIDeviceFamily,
                member: MIDIDeviceMember,
                softwareRevision: [UInt8]) {
        self.family = family
        self.manufacturer = manufacturer
        self.member = member
        self.softwareRevision = softwareRevision
    }

    // MARK: Public Instance Properties

    /// The device family code.
    public let family: MIDIDeviceFamily

    /// The manufacturer of the device.
    public let manufacturer: MIDIManufacturerID

    /// The device family member code.
    public let member: MIDIDeviceMember

    /// The software revision, in a device-specific format.
    public let softwareRevision: [UInt8]
}

// MARK: - Hashable

extension MIDIDeviceIdentity: Hashable {
}

// MARK: - Sendable

extension MIDIDeviceIdentity: Sendable {
}
