import Foundation
import IntlWireFormat
import SafeEnum

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

/// Kind of a plan object, as in the thick client (`IDL_en_obj_type`).
/// Values missing from this list decode with `SafeEnum.value == nil`.
public enum FloorPlanViewType: Int, Codable, Hashable, Sendable {
    case objectWithoutImage = 0   // Object without an image
    case icon = 1                 // Icon
    case linkIcon = 5             // Icon linking to another map
    case caption = 6              // Caption (name of the linked object)
    case programmaticIcon = 7     // Icon drawn programmatically
    case animatedIcon = 8         // Animated icon
    case textValue = 15           // Text value
    case line = 16                // Line
    case polygonObject = 17       // Polygon: system object
    case polygonLink = 18         // Polygon link (LINK); permissions are not checked
    case ellipse = 19             // Ellipse
    case geoAxes = 20             // Geo-referencing axes
    case freePicture = 21         // Free-form picture
}

public struct FloorPlanPoint: Codable, Sendable {
    /// Intellect access point on the plan, e.g. `CAM:2`, `TITLE:1`.
    public let id: AccessPoint
    public let layerId: ObjectID
    public let mapId: ObjectID
    public let x: Double
    public let y: Double
    public let angle: Double
    /// Absent on servers without view types. Unknown codes keep `rawValue` and have `value == nil`.
    public let viewType: SafeEnum<FloorPlanViewType>?
    /// `true` means the thick client shows the object only while blinking; we do not draw it.
    public let hidden: Bool?
    /// Object size in layer coordinates; absent or not positive means the default marker size.
    public let width: Double?
    public let height: Double?
    /// Area of an object drawn as a polygon (`viewType` 17 or 18). Only with at least 3 vertices.
    public let polygon: FloorPlanPolygon?

    private enum CodingKeys: String, CodingKey {
        case id, layerId, mapId, x, y, angle, viewType, hidden, width, height, polygon
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(AccessPoint.self, forKey: .id)
        layerId = try container.decode(ObjectID.self, forKey: .layerId)
        mapId = try container.decode(ObjectID.self, forKey: .mapId)
        x = try container.decode(Double.self, forKey: .x)
        y = try container.decode(Double.self, forKey: .y)
        angle = try container.decode(Double.self, forKey: .angle)
        // A malformed optional field must not fail the whole plan list.
        viewType = try? container.decodeIfPresent(SafeEnum<FloorPlanViewType>.self, forKey: .viewType)
        hidden = try? container.decodeIfPresent(Bool.self, forKey: .hidden)
        width = try? container.decodeIfPresent(Double.self, forKey: .width)
        height = try? container.decodeIfPresent(Double.self, forKey: .height)
        let decodedPolygon = try? container.decodeIfPresent(FloorPlanPolygon.self, forKey: .polygon)
        polygon = (decodedPolygon?.vertices.count ?? 0) >= 3 ? decodedPolygon : nil
    }
}

/// Polygon of a plan object, drawn by the thick client in layer coordinates.
public struct FloorPlanPolygon: Codable, Sendable, Equatable {
    /// `#AARRGGBB`, the fill color.
    public let color: String?
    /// `#AARRGGBB`, the fill and frame color while the object is alarmed.
    public let alarmColor: String?
    /// `true` means fill only, without a frame.
    public let hideFrame: Bool?
    public let vertices: [FloorPlanVertex]
}

public struct FloorPlanVertex: Codable, Sendable, Equatable {
    public let x: Double
    public let y: Double
}
