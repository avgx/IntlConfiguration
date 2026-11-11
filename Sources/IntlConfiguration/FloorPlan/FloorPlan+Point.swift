import Foundation
import IntlWireFormat
import SafeEnum

extension FloorPlan {
    public struct Point: Codable, Sendable {
        /// Intellect access point on the plan, e.g. `CAM:2`, `TITLE:1`, `LINK:5:LINK_1`.
        /// The whole string is the id: links with a repeated number carry the full uid.
        public let id: AccessPoint
        public let layerId: ObjectID
        public let mapId: ObjectID
        public let x: Double
        public let y: Double
        /// Rotation around the object center, clockwise, in degrees.
        public let angle: Double
        /// Absent on servers without view types. Unknown names keep `rawValue` and have `value == nil`.
        public let viewType: SafeEnum<ViewType>?
        /// `true` means the thick client shows the object only while in alarm; we do not draw it otherwise.
        public let hidden: Bool?
        /// Object size in layer coordinates; absent or not positive means the default marker size.
        public let width: Double?
        public let height: Double?
        /// Area of an object drawn as a polygon (`viewType` POLYGON or POLYGON_LINK). Only with at least 3 vertices.
        public let polygon: Polygon?
        /// Caption text or object name on the map.
        public let title: String?
        /// Comment shown in the hint popup.
        public let comment: String?
        /// Initial text of a TEXT object.
        public let info: String?
        /// Target of a link. Present for links with a destination.
        public let link: Link?

        private enum CodingKeys: String, CodingKey {
            case id, layerId, mapId, x, y, angle, viewType, hidden, width, height, polygon
            case title, comment, info, link
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
            viewType = Self.decodeViewType(from: container)
            hidden = try? container.decodeIfPresent(Bool.self, forKey: .hidden)
            width = try? container.decodeIfPresent(Double.self, forKey: .width)
            height = try? container.decodeIfPresent(Double.self, forKey: .height)
            let decodedPolygon = try? container.decodeIfPresent(Polygon.self, forKey: .polygon)
            polygon = (decodedPolygon?.vertices.count ?? 0) >= 3 ? decodedPolygon : nil
            title = try? container.decodeIfPresent(String.self, forKey: .title)
            comment = try? container.decodeIfPresent(String.self, forKey: .comment)
            info = try? container.decodeIfPresent(String.self, forKey: .info)
            link = try? container.decodeIfPresent(Link.self, forKey: .link)
        }

        /// Reads the current string names. Falls back to the numeric codes of the previous format.
        private static func decodeViewType(from container: KeyedDecodingContainer<CodingKeys>) -> SafeEnum<ViewType>? {
            if let name = try? container.decodeIfPresent(String.self, forKey: .viewType) {
                return SafeEnum(rawValue: name)
            }
            if let code = try? container.decodeIfPresent(Int.self, forKey: .viewType) {
                if let known = ViewType.legacy(code: code) {
                    return SafeEnum(known)
                }
                return SafeEnum(rawValue: String(code))
            }
            return nil
        }
    }
}

extension FloorPlan.Point {
    /// Destination of a link object.
    public struct Link: Codable, Sendable, Equatable {
        /// Destination map. For a link inside the same map, the map of the object itself.
        public let mapId: ObjectID?
        /// Destination layer.
        public let layerId: ObjectID?
        /// `true` means a "back" link; `mapId` and `layerId` are absent.
        public let previous: Bool?
    }
}
