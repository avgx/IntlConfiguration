import Foundation
import Testing
@testable import IntlConfiguration

@Test func decodesFloorPlanGeoLinked() throws {
    let plans: [FloorPlan] = try FixtureSupport.decode("floor-plan-geo-linked")
    #expect(plans.count == 1)
    #expect(plans[0].layers.count == 2)
    #expect(plans[0].layers[0].points.contains { $0.id == "CAM:1" })
}
