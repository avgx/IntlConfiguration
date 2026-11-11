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

@Test func oldServerPointsHaveNoViewTypeOrPolygon() throws {
    let plans: [FloorPlan] = try FixtureSupport.decode("floor-plan-geo-linked")
    for point in plans[0].layers[0].points {
        #expect(point.viewType == nil)
        #expect(point.polygon == nil)
        #expect(point.hidden == nil)
        #expect(point.width == nil)
        #expect(point.height == nil)
    }
}

@Test func decodesPolygonObjectPoint() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:1" })
    #expect(point.viewType?.value == .polygonObject)
    #expect(point.hidden == false)
    let polygon = try #require(point.polygon)
    #expect(polygon.vertices.count == 6)
    #expect(polygon.vertices[0] == FloorPlan.Vertex(x: 99, y: 158))
    #expect(polygon.color == "#46009600")
    #expect(polygon.alarmColor == "#46C80000")
    #expect(polygon.hideFrame == false)
}

@Test func decodesPolygonLinkPointWithoutFrame() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "LINK:5" })
    #expect(point.viewType?.value == .polygonLink)
    #expect(point.polygon?.hideFrame == true)
    #expect(point.polygon?.vertices.count == 3)
}

@Test func decodesIconWithSizeAndAngle() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:2" })
    #expect(point.viewType?.value == .icon)
    #expect(point.angle == 90)
    #expect(point.width == 28)
    #expect(point.height == 25)
    #expect(point.polygon == nil)
}

@Test func decodesCaptionWithoutPolygon() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "TITLE:1" })
    #expect(point.viewType?.value == .caption)
    #expect(point.polygon == nil)
}

@Test func unknownViewTypeKeepsRawValue() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:3" })
    #expect(point.viewType?.rawValue == 99)
    #expect(point.viewType?.value == nil)
}

@Test func hiddenPointIsDecoded() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:6" })
    #expect(point.hidden == true)
}

@Test func polygonWithTooFewVerticesIsDropped() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:4" })
    #expect(point.viewType?.value == .polygonObject)
    #expect(point.polygon == nil)
}

@Test func malformedPolygonDoesNotFailThePlan() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:5" })
    #expect(point.polygon == nil)
    // The rest of the plan is still there.
    #expect(layer.points.contains { $0.id == "CAM:1" })
}

@Test func linkNullStaysOutOfValidPoints() throws {
    let layer = try polygonFixtureLayer()
    #expect(layer.points.contains { $0.id == "LINK:null" })
    #expect(!layer.validPoints.contains { $0.id == "LINK:null" })
}

@Test func knownViewTypeCodesMapToCases() {
    let codes = [0, 1, 5, 6, 7, 8, 15, 16, 17, 18, 19, 20, 21]
    for code in codes {
        #expect(FloorPlan.ViewType(rawValue: code)?.rawValue == code)
    }
}

@Test func layerImageRequestAsksForBackgroundOnly() {
    let request = FloorPlanApi.layerImage(layerId: "1", mapId: "1")
    let polygons = request.query?.first { $0.0 == "polygons" }
    #expect(polygons?.1 == "false")
}

private func polygonFixtureLayer() throws -> FloorPlan.Layer {
    let plans: [FloorPlan] = try FixtureSupport.decode("floor-plan-polygons")
    return try #require(plans.first?.layers.first)
}
