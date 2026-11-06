// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDIIdentityMessage {

    /// The content of an identity message.
    public enum Content {

        /// An Identity Reply
        /// (`F0 7E id 06 02 <mfr> ff ff dd dd ss ss ss ss F7`).
        case reply(MIDIDeviceIdentity)

        /// An Identity Request (`F0 7E id 06 01 F7`).
        case request
    }
}

// MARK: - Hashable

extension MIDIIdentityMessage.Content: Hashable {
}

// MARK: - Sendable

extension MIDIIdentityMessage.Content: Sendable {
}
