import Foundation
import IntlWireFormat
import SafeEnum

extension FloorPlan {
    public struct Layer: Codable, Sendable {
        public let id: String
        public let mapId: String
        public let name: String
        public let width: Int
        public let height: Int
        public let zoomMin: Double
        public let zoomMax: Double
        public let zoomDef: Double
        public let zoomStep: Double
        /// File format of the background. Absent on servers that do not send it.
        /// Only `svg` changes the image address; see `FloorPlanApi.layerImage`.
        public let backgroundFormat: SafeEnum<BackgroundFormat>?
        public let points: [Point]

        private enum CodingKeys: String, CodingKey {
            case id, mapId, name, width, height, zoomMin, zoomMax, zoomDef, zoomStep, backgroundFormat, points
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            mapId = try container.decode(String.self, forKey: .mapId)
            name = try container.decode(String.self, forKey: .name)
            width = try container.decode(Int.self, forKey: .width)
            height = try container.decode(Int.self, forKey: .height)
            zoomMin = try container.decode(Double.self, forKey: .zoomMin)
            zoomMax = try container.decode(Double.self, forKey: .zoomMax)
            zoomDef = try container.decode(Double.self, forKey: .zoomDef)
            zoomStep = try container.decode(Double.self, forKey: .zoomStep)
            // A malformed optional field must not fail the whole plan list.
            backgroundFormat = try? container.decodeIfPresent(SafeEnum<BackgroundFormat>.self, forKey: .backgroundFormat)
            points = try container.decode([Point].self, forKey: .points)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(mapId, forKey: .mapId)
            try container.encode(name, forKey: .name)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
            try container.encode(zoomMin, forKey: .zoomMin)
            try container.encode(zoomMax, forKey: .zoomMax)
            try container.encode(zoomDef, forKey: .zoomDef)
            try container.encode(zoomStep, forKey: .zoomStep)
            try container.encodeIfPresent(backgroundFormat, forKey: .backgroundFormat)
            try container.encode(points, forKey: .points)
        }

        /// Pins with a usable access point (drops e.g. `LINK:null`).
        public var validPoints: [Point] {
            points.filter { $0.id.isValidAccessPoint }
        }
    }
}
