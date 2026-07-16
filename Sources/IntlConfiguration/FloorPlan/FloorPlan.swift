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

    /// Pins with a usable access point (drops e.g. `LINK:null`).
    public var validPoints: [FloorPlanPoint] {
        points.filter { $0.id.isValidAccessPoint }
    }
}

public struct FloorPlanPoint: Codable, Sendable {
    /// Intellect access point on the plan, e.g. `CAM:2`, `TITLE:1`.
    public let id: AccessPoint
    public let layerId: ObjectID
    public let mapId: ObjectID
    public let x: Double
    public let y: Double
    public let angle: Double
}
