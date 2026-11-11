import Foundation
import IntlWireFormat
import SafeEnum

extension FloorPlan {
    public struct Point: Codable, Sendable {
        /// Intellect access point on the plan, e.g. `CAM:2`, `TITLE:1`.
        public let id: AccessPoint
        public let layerId: ObjectID
        public let mapId: ObjectID
        public let x: Double
        public let y: Double
        public let angle: Double
        /// Absent on servers without view types. Unknown codes keep `rawValue` and have `value == nil`.
        public let viewType: SafeEnum<ViewType>?
        /// `true` means the thick client shows the object only while blinking; we do not draw it.
        public let hidden: Bool?
        /// Object size in layer coordinates; absent or not positive means the default marker size.
        public let width: Double?
        public let height: Double?
        /// Area of an object drawn as a polygon (`viewType` 17 or 18). Only with at least 3 vertices.
        public let polygon: Polygon?

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
            viewType = try? container.decodeIfPresent(SafeEnum<ViewType>.self, forKey: .viewType)
            hidden = try? container.decodeIfPresent(Bool.self, forKey: .hidden)
            width = try? container.decodeIfPresent(Double.self, forKey: .width)
            height = try? container.decodeIfPresent(Double.self, forKey: .height)
            let decodedPolygon = try? container.decodeIfPresent(Polygon.self, forKey: .polygon)
            polygon = (decodedPolygon?.vertices.count ?? 0) >= 3 ? decodedPolygon : nil
        }
    }
}
