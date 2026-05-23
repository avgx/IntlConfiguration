import Foundation
import Testing
@testable import IntlConfiguration

@Test func decodesSingleEntity() throws {
    let entity: Entity = try FixtureSupport.decode("entity-single")
    #expect(entity.id == "CAM:1")
    #expect(entity.name == "Camera 1")
    #expect(entity.state?.id == "normal")
}

@Test func decodesObjectClassStates() throws {
    let states: [ObjectClassState] = try FixtureSupport.decode("object-class-states")
    #expect(states.count == 2)
    #expect(states[0].id == "normal")
    #expect(states[1].id == "alarmed_recording")
}

@Test func entityApiPaths() {
    let entity = EntityApi.entity(id: "CAM:1")
    #expect(entity.path == "secure/configuration/CAM:1/")

    let image = EntityApi.objectStateImage(id: "CAM:2")
    #expect(image.path == "secure/configuration/CAM:2/state/image.png")
    #expect(image.headers?["Accept"] == "image/*")

    let states = ObjectClassApi.states(objectClass: "CAM")
    #expect(states.path == "secure/objectClasses/CAM/states/")
}
