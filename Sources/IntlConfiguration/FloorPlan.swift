import Foundation
import IntlWireFormat

public struct FloorPlan: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let layers: [FloorPlanLayer]

    public static func == (lhs: FloorPlan, rhs: FloorPlan) -> Bool {
        lhs.id == rhs.id
    }
}

public struct FloorPlanLayer: Codable, Sendable {
    public let id: String
    public let mapId: String
    public let name: String
    public let width: Int
    public let height: Int
    public let zoomMin: Double
    public let zoomMax: Double
    public let zoomDef: Double
    public let zoomStep: Double
    public let points: [FloorPlanPoint]
}

public struct FloorPlanPoint: Codable, Sendable {
    public let id: ObjectID
    public let layerId: ObjectID
    public let mapId: ObjectID
    public let x: Double
    public let y: Double
    public let angle: Double
}
