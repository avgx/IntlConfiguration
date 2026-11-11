import Foundation
import SafeEnum
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
        #expect(point.title == nil)
        #expect(point.link == nil)
    }
}

@Test func decodesPolygonObjectPoint() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:1" })
    #expect(point.viewType?.value == .polygon)
    #expect(point.hidden == false)
    #expect(point.title == "Camera 1")
    let polygon = try #require(point.polygon)
    #expect(polygon.vertices.count == 6)
    #expect(polygon.vertices[0] == FloorPlan.Vertex(x: 99, y: 158))
    #expect(polygon.color == "#46009600")
    #expect(polygon.alarmColor == "#46C80000")
    #expect(polygon.hideFrame == false)
}

@Test func decodesPolygonLinkWithFullUidAndTarget() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "LINK:5:LINK_1" })
    #expect(point.viewType?.value == .polygonLink)
    #expect(point.polygon?.hideFrame == true)
    #expect(point.polygon?.vertices.count == 3)
    #expect(point.link == FloorPlan.Point.Link(mapId: "1", layerId: "2", previous: nil))
}

@Test func decodesIconWithSizeAndAngle() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:2" })
    #expect(point.viewType?.value == .image)
    #expect(point.angle == 90)
    #expect(point.width == 28)
    #expect(point.height == 25)
    #expect(point.title == "Camera 2")
    #expect(point.polygon == nil)
}

@Test func decodesCaptionWithoutPolygon() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "TITLE:1" })
    #expect(point.viewType?.value == .title)
    #expect(point.title == "Caption")
    #expect(point.polygon == nil)
}

@Test func decodesTextInfo() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "TEXT:1" })
    #expect(point.viewType?.value == .text)
    #expect(point.info == "Start text")
}

@Test func unknownViewTypeKeepsRawValue() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "CAM:3" })
    #expect(point.viewType?.rawValue == "SOMETHING_NEW")
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
    #expect(point.viewType?.value == .polygon)
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

@Test func previousLinkHasNoTargetMap() throws {
    let layer = try polygonFixtureLayer()
    let point = try #require(layer.points.first { $0.id == "LINK:null" })
    #expect(point.link?.previous == true)
    #expect(point.link?.mapId == nil)
    #expect(point.link?.layerId == nil)
}

@Test func backgroundFormatPngFromFixture() throws {
    let layer = try polygonFixtureLayer()
    #expect(layer.backgroundFormat?.value == .png)
}

@Test func knownViewTypeNamesMapToCases() {
    let names = [
        "BASE", "IMAGE", "IMAGE_LINK", "TITLE", "IMAGE_AND_INDICATOR", "IMAGE_ANIM",
        "TEXT", "LINE", "POLYGON", "POLYGON_LINK", "ELLIPSE", "AXES", "FREE_IMAGE",
    ]
    for name in names {
        #expect(FloorPlan.ViewType(rawValue: name)?.rawValue == name)
    }
}

@Test func legacyNumericViewTypesStillDecode() throws {
    let json = """
    [{"id":"1","name":"Map","layers":[{"id":"1","mapId":"1","name":"L","width":10,"height":10,
    "zoomMin":0.25,"zoomMax":4,"zoomDef":1,"zoomStep":0.25,"points":[
      {"id":"CAM:1","layerId":"1","mapId":"1","x":1,"y":1,"angle":0,"viewType":17,
       "polygon":{"color":"#46009600","vertices":[{"x":1,"y":1},{"x":2,"y":1},{"x":2,"y":2}]}},
      {"id":"CAM:2","layerId":"1","mapId":"1","x":1,"y":1,"angle":0,"viewType":99},
      {"id":"TITLE:1","layerId":"1","mapId":"1","x":1,"y":1,"angle":0,"viewType":6}
    ]}]}]
    """
    let plans = try JSONDecoder().decode([FloorPlan].self, from: Data(json.utf8))
    let points = plans[0].layers[0].points
    #expect(points[0].viewType?.value == .polygon)
    #expect(points[1].viewType?.rawValue == "99")
    #expect(points[1].viewType?.value == nil)
    #expect(points[2].viewType?.value == .title)
}

@Test func backgroundFormatValuesAreSafe() throws {
    let json = """
    [{"id":"1","name":"Map","layers":[
      {"id":"1","mapId":"1","name":"svg","width":10,"height":10,"zoomMin":0.25,"zoomMax":4,"zoomDef":1,"zoomStep":0.25,"backgroundFormat":"svg","points":[]},
      {"id":"2","mapId":"1","name":"tiff","width":10,"height":10,"zoomMin":0.25,"zoomMax":4,"zoomDef":1,"zoomStep":0.25,"backgroundFormat":"tiff","points":[]},
      {"id":"3","mapId":"1","name":"none","width":10,"height":10,"zoomMin":0.25,"zoomMax":4,"zoomDef":1,"zoomStep":0.25,"points":[]},
      {"id":"4","mapId":"1","name":"broken","width":10,"height":10,"zoomMin":0.25,"zoomMax":4,"zoomDef":1,"zoomStep":0.25,"backgroundFormat":12,"points":[]}
    ]}]
    """
    let layers = try JSONDecoder().decode([FloorPlan].self, from: Data(json.utf8))[0].layers
    #expect(layers[0].backgroundFormat?.value == .svg)
    #expect(layers[1].backgroundFormat?.rawValue == "tiff")
    #expect(layers[1].backgroundFormat?.value == nil)
    #expect(layers[2].backgroundFormat == nil)
    #expect(layers[3].backgroundFormat == nil)
}

@Test func layerImageRequestAsksForPngWithoutPolygons() {
    let request = FloorPlanApi.layerImage(layerId: "1", mapId: "1")
    #expect(request.path == "secure/kartas/1/layers/1/image.png")
    let polygons = request.query?.first { $0.0 == "polygons" }
    #expect(polygons?.1 == "false")
}

@Test func layerImageRequestForNonSvgBackgroundUsesPng() {
    for format in ["png", "jpeg", "bmp", "tiff"] {
        let request = FloorPlanApi.layerImage(
            layerId: "1",
            mapId: "1",
            backgroundFormat: SafeEnum<FloorPlan.BackgroundFormat>(rawValue: format)
        )
        #expect(request.path == "secure/kartas/1/layers/1/image.png")
    }
}

@Test func layerImageRequestForSvgBackgroundUsesSvgAddress() {
    let request = FloorPlanApi.layerImage(
        layerId: "1",
        mapId: "1",
        backgroundFormat: SafeEnum<FloorPlan.BackgroundFormat>(rawValue: "svg")
    )
    #expect(request.path == "secure/kartas/1/layers/1/image.svg")
    #expect(request.query == nil)
}

private func polygonFixtureLayer() throws -> FloorPlan.Layer {
    let plans: [FloorPlan] = try FixtureSupport.decode("floor-plan-polygons")
    return try #require(plans.first?.layers.first)
}
