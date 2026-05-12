// © 2026 John Gary Pusey (see LICENSE.md)

internal import Foundation

private import XestiTools

extension SMFFormatter {

    // MARK: Internal Nested Types

    internal struct Writer {

        // MARK: Internal Initializers

        internal init(sequence: SMFSequence) {
            self.chunkMode = false
            self.currentTime = 0
            self.outChunkData = Data()
            self.outData = Data()
            self.runningStatus = 0
            self.sequence = sequence
        }

        // MARK: Private Instance Properties

        private let sequence: SMFSequence

        private var chunkMode: Bool
        private var currentTime: UInt
        private var outChunkData: Data
        private var outData: Data
        private var runningStatus: UInt8
    }
}

// MARK: -

extension SMFFormatter.Writer {

    // MARK: Internal Instance Methods

    internal mutating func writeSequence() throws -> Data {
        try _writeHeader(sequence.format,
                         UInt(sequence.tracks.count),
                         sequence.division)

        try sequence.tracks.forEach { try _writeTrack($0) }

        let data = outData

        outData.removeAll()

        return data
    }

    // MARK: Private Instance Methods

    private mutating func _writeAsByte(_ value: UInt) throws {
        guard let byte = UInt8(exactly: value)
        else { throw SMFFormatError.badByte(value) }

        try _writeByte(byte)
    }

    private mutating func _writeAsWord(_ value: UInt) throws {
        guard (0...0x7fff).contains(value)
        else { throw SMFFormatError.badWord(value) }

        try _writeAsByte(value >> 8)
        try _writeAsByte(value & 0xff)
    }

    private mutating func _writeByte(_ byte: UInt8) throws {
        if chunkMode {
            outChunkData.append(byte)
        } else {
            outData.append(byte)
        }
    }

    private mutating func _writeBytes(_ bytes: [UInt8]) throws {
        try bytes.forEach { try _writeByte($0) }
    }

    private mutating func _writeChunk(_ chunkType: SMFChunkType) throws {
        chunkMode = false

        try _writeChunkType(chunkType)
        try _writeChunkLength(UInt(outChunkData.count))

        outData.append(outChunkData)

        outChunkData.removeAll(keepingCapacity: true)
    }

    private mutating func _writeChunkLength(_ chunkLength: UInt) throws {
        guard (0...0x7fffffff).contains(chunkLength)
        else { throw SMFFormatError.badChunkLength(chunkLength) }

        try _writeAsByte(chunkLength >> 24)
        try _writeAsByte((chunkLength >> 16) & 0xff)
        try _writeAsByte((chunkLength >> 8) & 0xff)
        try _writeAsByte(chunkLength & 0xff)
    }

    private mutating func _writeChunkType(_ chunkType: SMFChunkType) throws {
        for char in chunkType.stringValue {
            guard let byte = char.asciiValue
            else { throw SMFFormatError.badChunkType(chunkType) }

            try _writeByte(byte)
        }
    }

    private mutating func _writeEvent(_ event: SMFEvent) throws {
        try _writeEventTime(event.eventTime)

        switch event {
        case let .meta(_, message):
            guard let statusByte = message.statusByte,
                  let typeByte = message.typeByte,
                  let dataBytes = message.dataBytes
            else { throw SMFFormatError.badEvent(event) }

            runningStatus = 0

            try _writeByte(statusByte)
            try _writeByte(typeByte)
            try _writeVarlen(UInt(dataBytes.count))
            try _writeBytes(dataBytes)

        case let .midi(_, message):
            guard let statusByte = message.statusByte,
                  let dataBytes = message.dataBytes
            else { throw SMFFormatError.badEvent(event) }

            if runningStatus != statusByte {
                runningStatus = statusByte

                try _writeByte(statusByte)
            }

            try _writeBytes(dataBytes)

        case let .sysEx(_, message):
            guard let statusByte = message.statusByte,
                  let dataBytes = message.dataBytes
            else { throw SMFFormatError.badEvent(event) }

            runningStatus = 0

            try _writeByte(statusByte)
            try _writeVarlen(UInt(dataBytes.count))
            try _writeBytes(dataBytes)
        }
    }

    private mutating func _writeEventTime(_ eventTime: SMFEventTime) throws {
        let deltaTime = eventTime.uintValue - currentTime

        currentTime = eventTime.uintValue

        try _writeVarlen(deltaTime)
    }

    private mutating func _writeHeader(_ format: SMFFormat,
                                       _ trackCount: UInt,
                                       _ division: SMFDivision) throws {
        guard let fmtBytes = format.bytesValue
        else { throw SMFFormatError.badFormat(format) }

        guard (format == .format0 && trackCount == 1) ||
              (format != .format0 && (1...0x7fff).contains(trackCount))
        else { throw SMFFormatError.badTrackCount(trackCount) }

        guard let divBytes = division.bytesValue
        else { throw SMFFormatError.badDivision(division) }

        chunkMode = true

        try _writeBytes(fmtBytes)
        try _writeAsWord(trackCount)
        try _writeBytes(divBytes)

        try _writeChunk(.header)
    }

    private mutating func _writeTrack(_ track: SMFTrack) throws {
        chunkMode = true
        currentTime = 0
        runningStatus = 0

        try track.events.forEach { try _writeEvent($0) }

        try _writeChunk(.track)
    }

    private mutating func _writeVarlen(_ varlen: UInt) throws {
        guard (0...0x0fffffff).contains(varlen)
        else { throw SMFFormatError.badVarlen(varlen) }

        var stack: [UInt] = []
        var varlen = varlen

        stack.push(varlen & 0x7f)

        for _ in 1..<4 {
            varlen >>= 7

            guard varlen > 0
            else { break }

            stack.push((varlen & 0x7f) | 0x80)
        }

        while let value = stack.pop() {
            try _writeAsByte(value)
        }
    }
}
