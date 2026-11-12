import Foundation
import SafeEnum

public struct EntityState: Codable, Sendable, Equatable {
    public let id: SafeEnum<EntityStateID>?
    public let type: SafeEnum<EntityStateType>?
    public let fullState: String?

    public init(
        id: SafeEnum<EntityStateID>?,
        type: SafeEnum<EntityStateType>?,
        fullState: String?
    ) {
        self.id = id
        self.type = type
        self.fullState = fullState
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case fullState
    }

    /// Tokens of ``fullState``. When it is missing, flags implied by ``id``.
    public var flags: [SafeEnum<EntityStateFlag>] {
        if let parsed = Self.parseFlags(fullState), !parsed.isEmpty {
            return parsed
        }
        return id?.value?.impliedFlags.map { SafeEnum($0) } ?? []
    }

    /// Armed when a flag or the state id says so. Nil when the object is offline or the id does not say.
    public var armState: ArmState? {
        let known = flags.compactMap(\.value)
        if known.contains(.armed) { return .arm }
        if known.contains(.disarmed) { return .disarm }
        switch id?.value {
        case .armed, .armed_recording, .alarmed, .alarmed_recording:
            return .arm
        case .connected, .connected_recording, .disarmed, .connectedAlarmed:
            return .disarm
        case .disconnected, .disabled, .detached, .disconnectes:
            return nil
        default:
            return Self.armState(fromRawID: id?.rawValue)
        }
    }

    public var isAlarmed: Bool {
        switch id?.value {
        case .alarmed, .alarmed_recording, .cracked, .failed, .connectedAlarmed, .confirmedAlarmed:
            return true
        default:
            let raw = id?.rawValue.lowercased() ?? ""
            return raw.contains("alarmed") || raw.contains("cracked") || raw.contains("failed")
        }
    }

    public var isDisconnected: Bool {
        switch id?.value {
        case .disconnected, .disabled, .detached, .disconnectes:
            return true
        default:
            let raw = id?.rawValue.lowercased() ?? ""
            return raw.contains("disconnected")
                || raw.contains("disabled")
                || raw.contains("detached")
                || raw.contains("disconnectes")
        }
    }

    public var isRecording: Bool {
        if flags.contains(where: { $0.value == .recording }) { return true }
        switch id?.value {
        case .armed_recording, .alarmed_recording, .connected_recording:
            return true
        default:
            return false
        }
    }

    private static func parseFlags(_ fullState: String?) -> [SafeEnum<EntityStateFlag>]? {
        guard let fullState else { return nil }
        let parts = fullState
            .split { $0 == "," || $0 == "|" }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !parts.isEmpty else { return nil }
        return parts.map { SafeEnum(rawValue: $0) }
    }

    private static func armState(fromRawID raw: String?) -> ArmState? {
        guard let raw = raw?.lowercased(), !raw.isEmpty else { return nil }
        if raw.hasPrefix("alarmed") || raw.hasPrefix("armed") { return .arm }
        if raw.hasPrefix("connected") || raw == "disarmed" { return .disarm }
        return nil
    }
}
