import Foundation

/// Server state id (`State.id` / websocket `state`). Unknown ids stay available through `SafeEnum.rawValue`.
public enum EntityStateID: String, Codable, Hashable, Sendable, CaseIterable {
    case disabled
    case disconnected
    case detached
    case alarmed
    case alarmed_recording
    case connected
    case connected_recording
    case armed
    case armed_recording
    case disarmed
    case on
    case off
    case normal
    case failed
    case cracked
    case connectedAlarmed
    case confirmed
    case confirmedAlarmed
    /// Slave class id, spelled this way on the server.
    case disconnectes

    /// Flags implied by a camera (and a few other) state ids when `fullState` has not been read yet.
    public var impliedFlags: [EntityStateFlag] {
        switch self {
        case .disconnected, .detached:
            return [.detached]
        case .disabled:
            return [.disable]
        case .alarmed:
            return [.alarmed]
        case .alarmed_recording:
            return [.alarmed, .recording]
        case .connected, .disarmed, .connectedAlarmed:
            return self == .connectedAlarmed ? [.disarmed, .on] : [.disarmed]
        case .connected_recording:
            return [.disarmed, .recording]
        case .armed:
            return [.armed]
        case .armed_recording:
            return [.armed, .recording]
        case .on:
            return [.on]
        case .off:
            return [.off]
        case .normal:
            return [.normal]
        case .failed:
            return [.failed]
        case .cracked:
            return [.crack]
        case .confirmed:
            return [.confirmed]
        case .confirmedAlarmed:
            return [.confirmedAlarm]
        case .disconnectes:
            return []
        }
    }

    /// Comma-joined ``impliedFlags``, or nil when this id implies nothing.
    public var impliedFullState: String? {
        let flags = impliedFlags
        guard !flags.isEmpty else { return nil }
        return flags.map(\.rawValue).joined(separator: ",")
    }
}
