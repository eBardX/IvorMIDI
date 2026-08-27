// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI controller number (0–127).
public struct MIDIController: UIntRepresentable {

    // MARK: Public Initializers

    /// Creates a `MIDIController` instance with the provided controller
    /// number, or `nil` if the value is not a valid controller number.
    ///
    /// - Parameter uintValue:  The controller number. Must be in the range
    ///                         0–127.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The controller number.
    public let uintValue: UInt
}

// MARK: -

extension MIDIController {

    // MARK: Public Type Properties

    /// The all notes off controller (123).
    public static let allNotesOff = Self(123)

    /// The all sound off controller (120).
    public static let allSoundOff = Self(120)

    /// The attack time controller (73).
    public static let attackTime = Self(73)

    /// The balance LSB controller (40).
    public static let balanceLSB = Self(40)

    /// The balance MSB controller (8).
    public static let balanceMSB = Self(8)

    /// The bank select LSB controller (32).
    public static let bankSelectLSB = Self(32)

    /// The bank select MSB controller (0).
    public static let bankSelectMSB = Self(0)

    /// The breath controller LSB (34).
    public static let breathControllerLSB = Self(34)

    /// The breath controller MSB (2).
    public static let breathControllerMSB = Self(2)

    /// The brightness controller (74).
    public static let brightness = Self(74)

    /// The celeste (chorus detune) depth controller (94).
    public static let celesteDepth = Self(94)

    /// The channel volume LSB controller (39).
    public static let channelVolumeLSB = Self(39)

    /// The channel volume MSB controller (7).
    public static let channelVolumeMSB = Self(7)

    /// The chorus send level controller (93).
    public static let chorusSendLevel = Self(93)

    /// The data decrement controller (97).
    public static let dataDecrement = Self(97)

    /// The data entry LSB controller (38).
    public static let dataEntryLSB = Self(38)

    /// The data entry MSB controller (6).
    public static let dataEntryMSB = Self(6)

    /// The data increment controller (96).
    public static let dataIncrement = Self(96)

    /// The decay time controller (75).
    public static let decayTime = Self(75)

    /// The effect control 1 LSB controller (44).
    public static let effectControl1LSB = Self(44)

    /// The effect control 1 MSB controller (12).
    public static let effectControl1MSB = Self(12)

    /// The effect control 2 LSB controller (45).
    public static let effectControl2LSB = Self(45)

    /// The effect control 2 MSB controller (13).
    public static let effectControl2MSB = Self(13)

    /// The expression controller LSB (43).
    public static let expressionControllerLSB = Self(43)

    /// The expression controller MSB (11).
    public static let expressionControllerMSB = Self(11)

    /// The foot controller LSB (36).
    public static let footControllerLSB = Self(36)

    /// The foot controller MSB (4).
    public static let footControllerMSB = Self(4)

    /// The general purpose controller 1 LSB (48).
    public static let generalPurposeController1LSB = Self(48)

    /// The general purpose controller 1 MSB (16).
    public static let generalPurposeController1MSB = Self(16)

    /// The general purpose controller 2 LSB (49).
    public static let generalPurposeController2LSB = Self(49)

    /// The general purpose controller 2 MSB (17).
    public static let generalPurposeController2MSB = Self(17)

    /// The general purpose controller 3 LSB (50).
    public static let generalPurposeController3LSB = Self(50)

    /// The general purpose controller 3 MSB (18).
    public static let generalPurposeController3MSB = Self(18)

    /// The general purpose controller 4 LSB (51).
    public static let generalPurposeController4LSB = Self(51)

    /// The general purpose controller 4 MSB (19).
    public static let generalPurposeController4MSB = Self(19)

    /// The general purpose controller 5 (80).
    public static let generalPurposeController5 = Self(80)

    /// The general purpose controller 6 (81).
    public static let generalPurposeController6 = Self(81)

    /// The general purpose controller 7 (82).
    public static let generalPurposeController7 = Self(82)

    /// The general purpose controller 8 (83).
    public static let generalPurposeController8 = Self(83)

    /// The harmonic content (resonance) controller (71).
    public static let harmonicContent = Self(71)

    /// The high-resolution velocity prefix controller (88).
    public static let highResolutionVelocityPrefix = Self(88)

    /// The hold 2 controller (69).
    public static let hold2 = Self(69)

    /// The legato footswitch controller (68).
    public static let legato = Self(68)

    /// The local control on/off controller (122).
    public static let localControl = Self(122)

    /// The modulation wheel LSB controller (33).
    public static let modulationWheelLSB = Self(33)

    /// The modulation wheel MSB controller (1).
    public static let modulationWheelMSB = Self(1)

    /// The mono mode on controller (126).
    public static let monoModeOn = Self(126)

    /// The non-registered parameter number LSB controller (98).
    public static let nonRegisteredParameterNumberLSB = Self(98)

    /// The non-registered parameter number MSB controller (99).
    public static let nonRegisteredParameterNumberMSB = Self(99)

    /// The omni mode off controller (124).
    public static let omniModeOff = Self(124)

    /// The omni mode on controller (125).
    public static let omniModeOn = Self(125)

    /// The pan LSB controller (42).
    public static let panLSB = Self(42)

    /// The pan MSB controller (10).
    public static let panMSB = Self(10)

    /// The phaser depth controller (95).
    public static let phaserDepth = Self(95)

    /// The poly mode on controller (127).
    public static let polyModeOn = Self(127)

    /// The portamento on/off controller (65).
    public static let portamento = Self(65)

    /// The portamento control controller (84).
    public static let portamentoControl = Self(84)

    /// The portamento time LSB controller (37).
    public static let portamentoTimeLSB = Self(37)

    /// The portamento time MSB controller (5).
    public static let portamentoTimeMSB = Self(5)

    /// The registered parameter number LSB controller (100).
    public static let registeredParameterNumberLSB = Self(100)

    /// The registered parameter number MSB controller (101).
    public static let registeredParameterNumberMSB = Self(101)

    /// The release time controller (72).
    public static let releaseTime = Self(72)

    /// The reset all controllers controller (121).
    public static let resetAllControllers = Self(121)

    /// The reverb send level controller (91).
    public static let reverbSendLevel = Self(91)

    /// The soft pedal controller (67).
    public static let softPedal = Self(67)

    /// The sostenuto pedal controller (66).
    public static let sostenuto = Self(66)

    /// The sound variation controller (70).
    public static let soundVariation = Self(70)

    /// The sustain pedal controller (64).
    public static let sustain = Self(64)

    /// The tremolo depth controller (92).
    public static let tremoloDepth = Self(92)

    /// The vibrato delay controller (78).
    public static let vibratoDelay = Self(78)

    /// The vibrato depth controller (77).
    public static let vibratoDepth = Self(77)

    /// The vibrato rate controller (76).
    public static let vibratoRate = Self(76)

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid MIDI controller number.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 0–127; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...127).contains(uintValue)
    }
}

// MARK: - BytesValueConvertible

extension MIDIController: BytesValueConvertible {

    // MARK: Internal Initializers

    internal init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 1
        else { return nil }

        self.init(uintValue: UInt(bytesValue[0]))
    }

    // MARK: Internal Instance Properties

    internal var bytesValue: [UInt8]? {
        guard let byte0Value = UInt8(exactly: uintValue)
        else { return nil }

        return [byte0Value]
    }
}
