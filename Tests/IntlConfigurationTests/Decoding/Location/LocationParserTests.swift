import Foundation
import Testing
@testable import IntlConfiguration

@Test func parseCoordinatesFromName() {
    let loc = Location.Parser.parse("[55.7558, 37.6173] Moscow")
    #expect(loc?.latitude == 55.7558)
    #expect(loc?.longitude == 37.6173)
    #expect(loc?.heading == nil)
}

@Test func parseCoordinatesWithHeading() {
    let loc = Location.Parser.parse("Cam [51.5056751, -0.1376643, 180]")
    #expect(loc?.latitude == 51.5056751)
    #expect(loc?.longitude == -0.1376643)
    #expect(loc?.heading == 180)
}

@Test func parseRejectsInvalidLatitude() {
    #expect(Location.Parser.parse("[95.0, 10.0]") == nil)
}

@Test func cleanNameRemovesCoordinates() {
    #expect(Location.Parser.cleanName("Camera 3 [0.0, 0.0, 0]") == "Camera 3")
}

@Test func locationsFromStreamingConfiguration() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-streaming")
    let locations = entities.locations()
    let cam3 = try #require(locations["CAM:3"])
    #expect(cam3.latitude == 0.0)
    #expect(cam3.longitude == 0.0)
    #expect(cam3.heading == 0)
}

@Test func createFromFloorPlanStrings() {
    let loc = Location(latitude: "55,7558", longitude: "37,6173", azimuth: "0,000000")
    #expect(loc?.latitude == 55.7558)
    #expect(loc?.longitude == 37.6173)
    #expect(loc?.heading == 0)
    let loc2 = Location(latitude: "55,7558", longitude: "37,6173", azimuth: "90,5")
    #expect(loc2?.latitude == 55.7558)
    #expect(loc2?.longitude == 37.6173)
    #expect(loc2?.heading == 90.5)
}
