import Foundation

/// One token of `EntityState.fullState` (`image_state_str` on the server, `|` already replaced by `,`).
public enum EntityStateFlag: String, Codable, Hashable, Sendable, CaseIterable {
    case alarmed = "ALARMED"
    case armed = "ARMED"
    case disarmed = "DISARMED"
    case recording = "RECORDING"
    case recorderOn = "RECORDER_ON"
    case detached = "DETACHED"
    case on = "ON"
    case off = "OFF"
    case confirmed = "CONFIRMED"
    case confirmedAlarm = "CONFIRMED_ALARM"
    case normal = "NORMAL"
    case disable = "DISABLE"
    case failed = "FAILED"
    case crack = "CRACK"
}
