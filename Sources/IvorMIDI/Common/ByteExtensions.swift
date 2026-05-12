// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension UInt8 {

    /// The two-digit uppercase hexadecimal string representation of this
    /// byte.
    public var hex: String {
        let hexString = String(self,
                               radix: 16,
                               uppercase: true)

        if hexString.count < 2 {
            return "0" + hexString
        }

        return hexString
    }
}

extension Sequence<UInt8> {

    /// The uppercase hexadecimal string representation of this byte
    /// sequence, with individual bytes separated by spaces.
    public var hex: String {
        map { $0.hex }.joined(separator: " ")
    }
}
