// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import Foundation

extension SMFParser {

    // MARK: Internal Nested Types

    internal struct Reader {

        // MARK: Internal Initializers

        internal init(data: Data) {
            self.chunkBytesLeft = 0
            self.chunkMode = false
            self.currentIndex = 0
            self.currentTime = 0
            self.data = data
            self.runningStatus = 0
        }

        // MARK: Private Instance Properties

        private let data: Data

        private var chunkBytesLeft: UInt
        private var chunkMode: Bool
        private var currentIndex: Int
        private var currentTime: UInt
        private var runningStatus: UInt8
    }
}

// MARK: -

extension SMFParser.Reader {

    // MARK: Internal Instance Methods

    internal mutating func readSequence() throws -> SMFSequence {
        guard let chunkType = try _readChunk(),
              chunkType == .header
        else { throw SMFParseError.missingHeaderChunk }

        let (format, trackCount, division) = try _readHeader()

        var tracks: [SMFTrack] = []

        while let chunkType = try _readChunk() {
            switch chunkType {
            case .header:
                throw SMFParseError.tooManyHeaderChunks

            case .track:
                try tracks.append(_readTrack())

            default:
                break   // ignore unknown chunks
            }

            try _skipExtraChunkData()
        }

        if tracks.count < trackCount {
            throw SMFParseError.notEnoughTrackChunks
        }

        if tracks.count > trackCount {
            throw SMFParseError.tooManyTrackChunks
        }

        return SMFSequence(format: format,
                           division: division,
                           tracks: tracks)
    }

    // MARK: Private Instance Methods

    private mutating func _readByte() throws -> UInt8 {
        guard currentIndex < data.count,
              !chunkMode || chunkBytesLeft > 0
        else { throw SMFParseError.dataExhaustedPrematurely }

        let byte = data[currentIndex]

        currentIndex += 1

        if chunkMode {
            chunkBytesLeft -= 1
        }

        return byte
    }

    private mutating func _readBytes(_ count: UInt) throws -> [UInt8] {
        var dataBytes: [UInt8] = []

        for _ in 0..<count {
            try dataBytes.append(_readByte())
        }

        return dataBytes
    }

    private mutating func _readChunk() throws -> SMFChunkType? {
        try _skipExtraChunkData()

        guard currentIndex < data.count
        else { return nil }

        chunkMode = false

        let chunkType = try _readChunkType()

        chunkBytesLeft = try _readChunkLength()

        currentTime = 0
        runningStatus = 0

        return chunkType
    }

    private mutating func _readChunkLength() throws -> UInt {
        var chunkLength: UInt = 0

        for _ in 0..<4 {
            let byte = try _readByte()

            chunkLength = (chunkLength << 8) | UInt(byte)
        }

        return chunkLength
    }

    private mutating func _readChunkType() throws -> SMFChunkType {
        var rawChunkType = ""

        for _ in 0..<4 {
            let byte = try _readByte()

            rawChunkType.append(Character(Unicode.Scalar(byte)))
        }

        guard let chunkType = SMFChunkType(stringValue: rawChunkType)
        else { throw SMFParseError.invalidChunkType(rawChunkType) }

        return chunkType
    }

    private mutating func _readDivision() throws -> SMFDivision {
        let byte0Value = try _readByte()
        let byte1Value = try _readByte()

        guard let division = SMFDivision(bytesValue: [byte0Value, byte1Value])
        else { throw SMFParseError.invalidDivision([byte0Value, byte1Value]) }

        return division
    }

    private mutating func _readEvent() throws -> SMFEvent {
        let eventTime = try _readEventTime()

        let (statusByte, extraBytes) = try _readStatusByte()

        if statusByte.isMIDIEventStatusByte {
            return try _readMIDIEvent(at: eventTime,
                                      statusByte: statusByte,
                                      extraBytes: extraBytes)
        }

        if statusByte.isMetaEventStatusByte {
            return try _readMetaEvent(at: eventTime,
                                      statusByte: statusByte)
        }

        if statusByte.isSysExEventStatusByte {
            return try _readSysExEvent(at: eventTime,
                                       statusByte: statusByte)
        }

        throw SMFParseError.unknownEventStatus(statusByte)
    }

    private mutating func _readEventTime() throws -> SMFEventTime {
        currentTime += try _readVarlen()

        guard let eventTime = SMFEventTime(uintValue: currentTime)
        else { throw SMFParseError.invalidEventTime(currentTime) }

        return eventTime
    }

    private mutating func _readFormat() throws -> SMFFormat {
        let byte0Value = try _readByte()
        let byte1Value = try _readByte()

        guard let format = SMFFormat(bytesValue: [byte0Value, byte1Value])
        else { throw SMFParseError.invalidFormat([byte0Value, byte1Value]) }

        return format
    }

    private mutating func _readHeader() throws -> (SMFFormat, UInt, SMFDivision) {
        chunkMode = true

        let format = try _readFormat()
        let trackCount = try _readTrackCount(for: format)
        let division = try _readDivision()

        return (format, trackCount, division)
    }

    private mutating func _readMetaEvent(at eventTime: SMFEventTime,
                                         statusByte: UInt8) throws -> SMFEvent {
        let typeByte = try _readByte()
        let count = try _readVarlen()
        let dataBytes = try _readBytes(count)

        let message = SMFMetaMessage(statusByte: statusByte,
                                     typeByte: typeByte,
                                     dataBytes: dataBytes) ?? .unknown(typeByte, dataBytes)

        runningStatus = 0

        return .meta(eventTime, message)
    }

    private mutating func _readMIDIEvent(at eventTime: SMFEventTime,
                                         statusByte: UInt8,
                                         extraBytes: [UInt8]) throws -> SMFEvent {
        guard let edbCount = MIDIChannelMessage.expectedDataByteCount(for: statusByte)
        else { throw SMFParseError.unknownChannelMessageStatus(statusByte) }

        var dataBytes = extraBytes

        while dataBytes.count < edbCount {
            try dataBytes.append(_readByte())
        }

        guard let message = MIDIChannelMessage(statusByte: statusByte,
                                               dataBytes: dataBytes)
        else { throw SMFParseError.invalidChannelMessage(statusByte, dataBytes) }

        runningStatus = statusByte

        return .midi(eventTime, message)
    }

    private mutating func _readStatusByte() throws -> (UInt8, [UInt8]) {
        let tmpByte = try _readByte()

        if tmpByte.isMIDIStatusByte {
            return (tmpByte, [])
        }

        if runningStatus.isMIDIStatusByte {
            return (runningStatus, [tmpByte])
        }

        throw SMFParseError.unexpectedDataByte(tmpByte)
    }

    private mutating func _readSysExEvent(at eventTime: SMFEventTime,
                                          statusByte: UInt8) throws -> SMFEvent {
        let count = try _readVarlen()
        let dataBytes = try _readBytes(count)

        guard let message = SMFSysExMessage(statusByte: statusByte,
                                            dataBytes: dataBytes)
        else { throw SMFParseError.invalidSysExMessage(statusByte, dataBytes) }

        runningStatus = 0

        return .sysEx(eventTime, message)
    }

    private mutating func _readTrack() throws -> SMFTrack {
        chunkMode = true

        var events: [SMFEvent] = []

        while chunkBytesLeft > 0 {
            try events.append(_readEvent())
        }

        guard !events.isEmpty
        else { throw SMFParseError.emptyTrack }

        return SMFTrack(events: events)
    }

    private mutating func _readTrackCount(for format: SMFFormat) throws -> UInt {
        let byte0Value = try _readByte()
        let byte1Value = try _readByte()

        let trackCount = UInt(byte0Value) << 8 | UInt(byte1Value)

        guard (format == .format0 && trackCount == 1)
                || (format != .format0 && (1...0xffff).contains(trackCount))
        else { throw SMFParseError.invalidTrackCount(trackCount, format) }

        return trackCount
    }

    private mutating func _readVarlen() throws -> UInt {
        var varlen: UInt = 0

        while true {
            let byte = try _readByte()

            varlen = (varlen << 7) + UInt(byte & 0x7f)

            if byte & 0x80 == 0 {
                break
            }
        }

        return varlen
    }

    private mutating func _skipExtraChunkData() throws {
        guard chunkBytesLeft > 0
        else { return }

        guard currentIndex + Int(chunkBytesLeft) <= data.count
        else { throw SMFParseError.dataExhaustedPrematurely }

        currentIndex += Int(chunkBytesLeft)

        chunkBytesLeft = 0
    }
}
