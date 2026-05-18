import Foundation
import Testing
@testable import IntlConfiguration

@Test func decodesConfigurationWithZones() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-with-zones")
    #expect(entities.count == 3)
    #expect(entities.allSatisfy { $0.isCamera })
    #expect(entities[0].zoneIds == ["1"])
    #expect(entities[0].state?.fullState == "ALARMED|ARMED")
    #expect(entities[0].state?.armState == .arm)
}

@Test func decodesConfigurationStreaming() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-streaming")
    #expect(entities.contains { $0.isStreamingServer })
    #expect(entities.contains { $0.type.value == .MACRO })
    #expect(entities.first { $0.id == "CAM:7" }?.state?.isAlarmed == true)
}

@Test func decodesConfigurationInvalidLinked() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-invalid-linked")
    let withLinked = entities.filter { $0.linkedObjects != nil }
    #expect(withLinked.count >= 2)
    #expect(withLinked.flatMap { $0.linkedIds() }.contains("GRAY:"))
    #expect(entities.contains { $0.type.value == .FIRSERVER })
}

@Test func decodesConfigurationMic() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-mic")
    let withMic = entities.first { $0.micId != nil }
    #expect(withMic?.micId == "MIC:1")
    #expect(withMic?.speakerId == "SPEAKER:1")
}

@Test func decodesConfigurationSample() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-sample")
    #expect(entities.count >= 3)
}

@Test func decodesEntityStateWithPresetsInJSON() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-with-zones")
    #expect(entities.allSatisfy { $0.state != nil })
    #expect(entities[0].state?.type?.value == .alarm)
}

@Test func decodesSemicolonSeparatedMonitorAndDisplayIds() throws {
    let json = """
    [{"type":"CAM","id":"CAM:1","extId":"1","monitorId":"2;3","displayId":"4;5","zoneId":"1;2"}]
    """.data(using: .utf8)!
    let entities = try JSONDecoder().decode([Entity].self, from: json)
    #expect(entities[0].monitorIds == ["2", "3"])
    #expect(entities[0].displayIds == ["4", "5"])
    #expect(entities[0].zoneIds == ["1", "2"])
}

@Test func decodesUnknownEntityTypeWithoutFailing() throws {
    let json = """
    [{"type":"FUTURE_THING","id":"FUTURE_THING:1","extId":"1"}]
    """.data(using: .utf8)!
    let entities = try JSONDecoder().decode([Entity].self, from: json)
    #expect(entities[0].type.value == nil)
    #expect(entities[0].type.rawValue == "FUTURE_THING")
}
