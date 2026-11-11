import Foundation
import IntlWireFormat

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
        public let points: [Point]

        /// Pins with a usable access point (drops e.g. `LINK:null`).
        public var validPoints: [Point] {
            points.filter { $0.id.isValidAccessPoint }
        }
    }
}
