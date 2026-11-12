import Foundation
import SafeEnum
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

@Test func decodesStateFlagsArmAndRecording() {
    let recording = EntityState(
        id: SafeEnum(.armed_recording),
        type: SafeEnum(.normal),
        fullState: nil
    )
    #expect(recording.armState == .arm)
    #expect(recording.isRecording)
    #expect(recording.flags.compactMap(\.value) == [.armed, .recording])

    let alarmed = EntityState(
        id: SafeEnum(.alarmed),
        type: SafeEnum(.alarm),
        fullState: "ALARMED|ARMED"
    )
    #expect(alarmed.armState == .arm)
    #expect(alarmed.isAlarmed)
    #expect(alarmed.flags.compactMap(\.value) == [.alarmed, .armed])

    let comma = EntityState(
        id: SafeEnum(.alarmed_recording),
        type: SafeEnum(.alarm),
        fullState: "ALARMED,ARMED,RECORDER_ON,RECORDING"
    )
    #expect(comma.isRecording)
    #expect(comma.flags.compactMap(\.value) == [.alarmed, .armed, .recorderOn, .recording])

    let disarmed = EntityState(id: SafeEnum(.connected), type: nil, fullState: "DISARMED")
    #expect(disarmed.armState == .disarm)
    #expect(!disarmed.isRecording)

    let offline = EntityState(id: SafeEnum(.disconnected), type: SafeEnum(.alarm), fullState: nil)
    #expect(offline.isDisconnected)
    #expect(offline.armState == nil)
    #expect(!offline.isAlarmed)

    let unknown = EntityState(id: SafeEnum(rawValue: "widget_alarmed"), type: nil, fullState: nil)
    #expect(unknown.id?.value == nil)
    #expect(unknown.isAlarmed)
}

@Test func decodesStateWebSocketFrame() throws {
    let json = """
    {"objectId":"CAM:1","action":"state","state":"armed_recording","x":null,"y":null,"ts":"2026-11-10T12:02:21.634+03:00"}
    """.data(using: .utf8)!
    let message = try JSONDecoder().decode(StateMessage.self, from: json)
    #expect(message.objectId == "CAM:1")
    #expect(message.action == "state")
    #expect(message.state?.value == .armed_recording)
    #expect(message.ts == "2026-11-10T12:02:21.634+03:00")
    #expect(StateApi.feed().path == "secure/ws/states/")
}

@Test func decodesUnknownEntityTypeWithoutFailing() throws {
    let json = """
    [{"type":"FUTURE_THING","id":"FUTURE_THING:1","extId":"1"}]
    """.data(using: .utf8)!
    let entities = try JSONDecoder().decode([Entity].self, from: json)
    #expect(entities[0].type.value == nil)
    #expect(entities[0].type.rawValue == "FUTURE_THING")
}
