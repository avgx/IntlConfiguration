import Foundation
import IntlWireFormat

public struct Camera: Identifiable, Equatable, Hashable, Codable, Sendable {
    public let id: AccessPoint
    public let objectID: ObjectID
    public let name: String
    public let mic: AccessPoint?
    public let speaker: AccessPoint?
    public let rtspPort: Int?
    public let telemetryId: ObjectID?
}

extension Camera {
    static func from(_ entity: Entity, rtspPorts: [AccessPoint: Int]) -> Camera {
        Camera(
            id: entity.id,
            objectID: entity.extId,
            name: Location.Parser.cleanName(entity.name ?? entity.extId)
                .trimmingCharacters(in: .whitespacesAndNewlines),
            mic: entity.micId,
            speaker: entity.speakerId,
            rtspPort: rtspPorts[entity.id],
            telemetryId: entity.telemetryId
        )
    }
}
