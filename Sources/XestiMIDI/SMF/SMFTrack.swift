// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An SMF track containing a sequence of events.
public struct SMFTrack {

    // MARK: Public Instance Properties

    /// The events in this track, in time order.
    public let events: [SMFEvent]
}

// MARK: - Sendable

extension SMFTrack: Sendable {
}
