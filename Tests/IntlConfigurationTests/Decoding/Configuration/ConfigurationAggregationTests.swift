import Foundation
import Testing
@testable import IntlConfiguration

@Test func namedStripsCoordinatesFromCameraName() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-streaming")
    let names = entities.named()
    let cam3 = names["CAM:3"]
    #expect(cam3 == "Camera 3")
}

@Test func zonesAndRegionsFromConfigurationWithZones() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-with-zones")
    #expect(entities.zones().count == 1)
    #expect(entities.regions().count == 2)
    let zone = entities.zones().first!
    #expect(zone.id == "ZONE:1")
    #expect(zone.list.count == 3)
}

@Test func rtspFromStreamingConfiguration() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-streaming")
    let rtsp = entities.rtsp()
    #expect(rtsp["CAM:1"] == 555)
    #expect(entities.rtspStream().count == 1)
}

@Test func monitorsFromInvalidLinkedConfiguration() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-invalid-linked")
    let monitors = entities.monitors()
    #expect(monitors.count == 1)
    #expect(monitors[0].list.count == 9)
}

@Test func linkedObjectsMap() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-invalid-linked")
    let linked = entities.linkedObjects()
    #expect(linked["CAM_VMDA_DETECTOR:1"] == "CAM:2")
}

@Test func zonesMatchCamerasWithSemicolonZoneList() throws {
    let json = """
    [
      {"type":"CAM","id":"CAM:1","extId":"1","zoneId":"1","zoneName":"Z1"},
      {"type":"CAM","id":"CAM:2","extId":"2","zoneId":"1;2","zoneName":"Z2"}
    ]
    """.data(using: .utf8)!
    let entities = try JSONDecoder().decode([Entity].self, from: json)
    let zones = entities.zones()
    #expect(zones.count == 2)
    #expect(zones.first { $0.id == "ZONE:1" }?.list.count == 2)
    #expect(zones.first { $0.id == "ZONE:2" }?.list.count == 1)
}
