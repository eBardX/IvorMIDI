// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI

struct StubSysExMessage {
    let payload: [UInt8]
}

// MARK: - Equatable

extension StubSysExMessage: Equatable {
}

// MARK: - MIDISysExRepresentable

extension StubSysExMessage: MIDISysExRepresentable {
    init?(_ envelope: MIDISysExEnvelope) {
        guard case let .nonCommercial(payload) = envelope
        else { return nil }

        self.payload = payload
    }

    var envelope: MIDISysExEnvelope? {
        payload.isEmpty ? nil : .nonCommercial(payload: payload)
    }
}
