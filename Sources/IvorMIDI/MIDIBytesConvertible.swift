// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A type that can be converted to and from an array of bytes.
///
/// For MIDI data values, the bytes are the value’s MIDI wire encoding.
/// Other packages, such as IvorSMF, adopt this protocol for their own binary
/// encodings.
public protocol MIDIBytesConvertible {

    // MARK: Public Initializers

    /// Creates an instance from its byte encoding, or `nil` if the bytes do not
    /// encode a valid instance.
    ///
    /// - Parameter bytesValue: The byte encoding of the instance.
    init?(bytesValue: [UInt8])

    // MARK: Public Instance Properties

    /// The byte encoding of this instance, or `nil` if it cannot be encoded.
    var bytesValue: [UInt8]? { get }
}
