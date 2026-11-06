// © 2026 John Gary Pusey (see LICENSE.md)

/// How to reach a device with a system exclusive message.
///
/// Universal messages use a device ID. Some manufacturer-specific formats use a
/// MIDI channel instead.
public enum MIDIDeviceAddress {

    /// A MIDI channel.
    case channel(MIDIChannel)

    /// A device ID, where 127 means all devices.
    case deviceID(MIDIData1Value)
}

// MARK: - Hashable

extension MIDIDeviceAddress: Hashable {
}

// MARK: - Sendable

extension MIDIDeviceAddress: Sendable {
}
