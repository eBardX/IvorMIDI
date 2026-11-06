// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

// Registered parameters (RPNs) and non-registered parameters (NRPNs) share the
// data entry, data increment, and data decrement controllers. Whichever kind of
// parameter was selected most recently on a channel receives them.
extension MIDIChannelMessage {

    // MARK: Public Type Methods

    /// Returns the control change message that decrements the selected
    /// parameter on a channel by one step.
    ///
    /// Receivers ignore the message’s value, which is sent as 0.
    ///
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  A data decrement control change message.
    public static func dataDecrement(on channel: MIDIChannel) -> Self {
        .controlChange(channel, .dataDecrement, 0)
    }

    /// Returns the control change messages that set the selected parameter
    /// on a channel to a 14-bit value.
    ///
    /// - Parameter value:      The value.
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  The data entry MSB and LSB control change messages, in the
    ///             order to send them.
    public static func dataEntry(_ value: MIDIData2Value,
                                 on channel: MIDIChannel) -> [Self] {
        [.controlChange(channel, .dataEntryMSB, value.msb),
         .controlChange(channel, .dataEntryLSB, value.lsb)]
    }

    /// Returns the control change message that sets the selected parameter
    /// on a channel to a 7-bit value, sending no LSB.
    ///
    /// Use this for parameters that only take a 7-bit value, or for receivers
    /// that act on the data entry MSB alone.
    ///
    /// - Parameter value:      The value.
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  A data entry MSB control change message.
    public static func dataEntryMSB(_ value: MIDIData1Value,
                                    on channel: MIDIChannel) -> Self {
        .controlChange(channel, .dataEntryMSB, value)
    }

    /// Returns the control change message that increments the selected
    /// parameter on a channel by one step.
    ///
    /// Receivers ignore the message’s value, which is sent as 0.
    ///
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  A data increment control change message.
    public static func dataIncrement(on channel: MIDIChannel) -> Self {
        .controlChange(channel, .dataIncrement, 0)
    }

    /// Returns the control change messages that set a non-registered
    /// parameter on a channel to a 7-bit value, sending no LSB.
    ///
    /// The messages select the parameter, send the value with
    /// ``dataEntryMSB(_:on:)``, and finally deselect the parameter with
    /// ``parameterDeselect(on:)``.
    ///
    /// - Parameter parameter:  The non-registered parameter to set.
    /// - Parameter msb:        The value to set it to.
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  The five control change messages, in the order to send
    ///             them.
    public static func nonRegisteredParameterChange(_ parameter: MIDINonRegisteredParameter,
                                                    msb: MIDIData1Value,
                                                    on channel: MIDIChannel) -> [Self] {
        nonRegisteredParameterSelect(parameter, on: channel)
            + [dataEntryMSB(msb, on: channel)]
            + parameterDeselect(on: channel)
    }

    /// Returns the control change messages that set a non-registered
    /// parameter on a channel to a 14-bit value.
    ///
    /// The messages select the parameter, send the value with
    /// ``dataEntry(_:on:)``, and finally deselect the parameter with
    /// ``parameterDeselect(on:)``.
    ///
    /// - Parameter parameter:  The non-registered parameter to set.
    /// - Parameter value:      The value to set it to.
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  The six control change messages, in the order to send
    ///             them.
    public static func nonRegisteredParameterChange(_ parameter: MIDINonRegisteredParameter,
                                                    value: MIDIData2Value,
                                                    on channel: MIDIChannel) -> [Self] {
        nonRegisteredParameterSelect(parameter, on: channel)
            + dataEntry(value, on: channel)
            + parameterDeselect(on: channel)
    }

    /// Returns the control change messages that select a non-registered
    /// parameter on a channel, so that later data entry, data increment, and
    /// data decrement messages change it.
    ///
    /// - Parameter parameter:  The non-registered parameter to select.
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  The non-registered parameter number MSB and LSB control
    ///             change messages, in the order to send them.
    public static func nonRegisteredParameterSelect(_ parameter: MIDINonRegisteredParameter,
                                                    on channel: MIDIChannel) -> [Self] {
        [.controlChange(channel, .nonRegisteredParameterNumberMSB, parameter.msb),
         .controlChange(channel, .nonRegisteredParameterNumberLSB, parameter.lsb)]
    }

    /// Returns the control change messages that deselect any registered or
    /// non-registered parameter on a channel, so that later data entry does
    /// not change a parameter by accident.
    ///
    /// The messages select the null registered parameter
    /// (``MIDIRegisteredParameter/null``), which deselects both kinds of
    /// parameter.
    ///
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  The registered parameter number MSB and LSB control change
    ///             messages, in the order to send them.
    public static func parameterDeselect(on channel: MIDIChannel) -> [Self] {
        registeredParameterSelect(.null,
                                  on: channel)
    }

    /// Returns the control change messages that set a registered parameter
    /// on a channel to a 7-bit value, sending no LSB.
    ///
    /// The messages select the parameter, send the value with
    /// ``dataEntryMSB(_:on:)``, and finally deselect the parameter with
    /// ``parameterDeselect(on:)``.
    ///
    /// - Parameter parameter:  The registered parameter to set.
    /// - Parameter msb:        The value to set it to.
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  The five control change messages, in the order to send
    ///             them.
    public static func registeredParameterChange(_ parameter: MIDIRegisteredParameter,
                                                 msb: MIDIData1Value,
                                                 on channel: MIDIChannel) -> [Self] {
        registeredParameterSelect(parameter, on: channel)
            + [dataEntryMSB(msb, on: channel)]
            + parameterDeselect(on: channel)
    }

    /// Returns the control change messages that set a registered parameter
    /// on a channel to a 14-bit value.
    ///
    /// The messages select the parameter, send the value with
    /// ``dataEntry(_:on:)``, and finally deselect the parameter with
    /// ``parameterDeselect(on:)``.
    ///
    /// - Parameter parameter:  The registered parameter to set.
    /// - Parameter value:      The value to set it to.
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  The six control change messages, in the order to send
    ///             them.
    public static func registeredParameterChange(_ parameter: MIDIRegisteredParameter,
                                                 value: MIDIData2Value,
                                                 on channel: MIDIChannel) -> [Self] {
        registeredParameterSelect(parameter, on: channel)
            + dataEntry(value, on: channel)
            + parameterDeselect(on: channel)
    }

    /// Returns the control change messages that select a registered
    /// parameter on a channel, so that later data entry, data increment, and
    /// data decrement messages change it.
    ///
    /// - Parameter parameter:  The registered parameter to select.
    /// - Parameter channel:    The MIDI channel.
    ///
    /// - Returns:  The registered parameter number MSB and LSB control change
    ///             messages, in the order to send them.
    public static func registeredParameterSelect(_ parameter: MIDIRegisteredParameter,
                                                 on channel: MIDIChannel) -> [Self] {
        [.controlChange(channel, .registeredParameterNumberMSB, parameter.msb),
         .controlChange(channel, .registeredParameterNumberLSB, parameter.lsb)]
    }
}
