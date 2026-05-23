import Foundation
import Testing
@testable import IntlConfiguration

@Test func camerasFromMicConfiguration() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-mic")
    let cameras = entities.cameras()
    #expect(cameras.count == 3)

    let cam1 = try #require(cameras.first { $0.id == "CAM:1" })
    #expect(cam1.objectID == "1")
    #expect(cam1.name == "Camera 1")
    #expect(cam1.mic == "MIC:1")
    #expect(cam1.speaker == "SPEAKER:1")
    #expect(cam1.telemetryId == "1.1")
    #expect(cam1.rtspPort == 555)

    let cam2 = try #require(cameras.first { $0.id == "CAM:2" })
    #expect(cam2.mic == nil)
    #expect(cam2.speaker == nil)
    #expect(cam2.telemetryId == nil)
    #expect(cam2.rtspPort == 555)
}

@Test func camerasStripCoordinatesFromName() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-streaming")
    let cam3 = try #require(entities.cameras().first { $0.id == "CAM:3" })
    #expect(cam3.name == "Camera 3")
}

@Test func faceRecognitionServersFilter() throws {
    let entities: [Entity] = try FixtureSupport.decode("configuration-sample")
    #expect(entities.faceRecognitionServers().isEmpty)
}
