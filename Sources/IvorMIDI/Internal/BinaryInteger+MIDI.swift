// © 2026 John Gary Pusey (see LICENSE.md)

extension BinaryInteger {

    // MARK: Internal Instance Methods

    internal func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(Int(clamping: self),
                            range.lowerBound),
                  range.upperBound)
    }
}
