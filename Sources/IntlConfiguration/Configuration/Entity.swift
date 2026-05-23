import Foundation
import IntlWireFormat
import SafeEnum

public struct Entity: Codable, Identifiable, Equatable, Sendable {
    public let type: SafeEnum<EntityType>
    public let extId: ObjectID
    public let id: AccessPoint
    public let regionId: ObjectID?
    public let telemetryId: ObjectID?
    public let name: String?
    public let state: EntityState?
    public let cams: ObjectIDList?
    public let port: String?

    public let regionName: String?
    /// One display id or list separated by `;`, e.g. `"38;45;18"`.
    public let displayId: ObjectIDList?
    public let displayName: String?
    /// One zone id or list separated by `;`.
    public let zoneId: ObjectIDList?
    public let zoneName: String?
    /// One monitor id or list separated by `;`, e.g. `"47;21;24"`.
    public let monitorId: ObjectIDList?
    public let monitorName: String?
    public let camList: [ObjectID]?

    public let micId: AccessPoint?
    public let speakerId: AccessPoint?

    public let linkedObjects: String?

    private enum CodingKeys: String, CodingKey {
        case type
        case extId
        case id
        case regionId
        case telemetryId
        case name
        case state
        case cams
        case port
        case regionName
        case displayId
        case displayName
        case zoneId
        case zoneName
        case monitorId
        case monitorName
        case camList
        case micId
        case speakerId
        case linkedObjects
    }
}

extension Entity: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(id) \(name ?? "<null>")"
    }
}

extension Entity {
    public var monitorIds: [ObjectID] { monitorId?.values ?? [] }
    public var displayIds: [ObjectID] { displayId?.values ?? [] }
    public var zoneIds: [ObjectID] { zoneId?.values ?? [] }

    public func linkedIds() -> [AccessPoint] {
        linkedObjects?.split(separator: ",").map { String($0) } ?? []
    }

    public var isCamera: Bool { type.value == .CAM }
    public var isStreamingServer: Bool { type.value == .STREAMING_SERVER }
    public var isFaceRecognitionServer: Bool { type.value == .FIRSERVER }
    public var isMonitor: Bool { type.value == .MONITOR }
    public var isDisplay: Bool { type.value == .DISPLAY }
    public var isMacro: Bool { type.value == .MACRO }
}
