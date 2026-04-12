// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A type that can be converted to and from an array of bytes.
public protocol BytesValueConvertible {

    /// Creates an instance from the provided array of bytes, or `nil` if
    /// the bytes do not represent a valid value.
    ///
    /// - Parameter bytesValue: The array of bytes.
    init?(bytesValue: [UInt8])

    /// The array of bytes representing this value, or `nil` if this value
    /// cannot be represented as an array of bytes.
    var bytesValue: [UInt8]? { get }
}
