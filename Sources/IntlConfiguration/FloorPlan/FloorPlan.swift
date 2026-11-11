import Foundation

public struct FloorPlan: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let layers: [Layer]

    public static func == (lhs: FloorPlan, rhs: FloorPlan) -> Bool {
        lhs.id == rhs.id
    }
}
