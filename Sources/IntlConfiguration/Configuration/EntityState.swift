import Foundation
import SafeEnum

public struct EntityState: Codable, Sendable, Equatable {
    public let id: String?
    public let type: SafeEnum<EntityStateType>?
    public let fullState: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case fullState
    }

    public var armState: ArmState {
        guard let fullState = fullState?.uppercased() else { return .disarm }
        let separator = fullState.contains("|") ? "|" : ","
        return fullState.components(separatedBy: separator).contains("ARMED") ? .arm : .disarm
    }

    public var isAlarmed: Bool {
        guard let id = id?.lowercased() else { return false }
        return id.contains("alarmed") || id.contains("cracked") || id.contains("failed")
    }

    public var isDisconnected: Bool {
        guard let id = id?.lowercased() else { return false }
        return id.contains("disconnected") || id.contains("disabled") || id.contains("detached")
    }
}
