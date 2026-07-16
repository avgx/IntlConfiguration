import Foundation
import Testing
@testable import IntlConfiguration

@Test func decodesFloorPlanGeoLinked() throws {
    let plans: [FloorPlan] = try FixtureSupport.decode("floor-plan-geo-linked")
    #expect(plans.count == 1)
    #expect(plans[0].layers.count == 2)
    let layer = plans[0].layers[0]
    #expect(layer.points.contains { $0.id == "CAM:1" })
    #expect(layer.points.contains { $0.id == "LINK:null" })
    #expect(layer.validPoints.contains { $0.id == "TITLE:1" })
    #expect(!layer.validPoints.contains { $0.id == "LINK:null" })
    #expect(layer.validPoints.count == 3)
}
