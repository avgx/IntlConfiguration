import Foundation

extension FloorPlan {
    /// Polygon of a plan object, drawn by the thick client in layer coordinates.
    public struct Polygon: Codable, Sendable, Equatable {
        /// `#AARRGGBB`, the fill color.
        public let color: String?
        /// `#AARRGGBB`, the fill and frame color while the object is alarmed.
        public let alarmColor: String?
        /// `true` means fill only, without a frame.
        public let hideFrame: Bool?
        public let vertices: [Vertex]
    }
}
