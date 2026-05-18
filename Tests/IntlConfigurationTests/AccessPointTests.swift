import Foundation
import Testing
@testable import IntlConfiguration

@Test func accessPointSplitsClassAndId() {
    let ap: AccessPoint = "CAM:34"
  #expect(ap.objectClass == "CAM")
  #expect(ap.accessPointObjectId == "34")
  #expect(ap.components == AccessPointComponents(objectClass: "CAM", objectId: "34"))
}

@Test func accessPointSupportsDottedObjectId() {
    let ap: AccessPoint = "REGION:1.1"
  #expect(ap.objectClass == "REGION")
  #expect(ap.accessPointObjectId == "1.1")
}

@Test func accessPointBuildsFromComponents() {
    let ap = AccessPoint(objectClass: "STREAMING_SERVER", objectId: "1")
  #expect(ap == "STREAMING_SERVER:1")
  #expect(ap.components?.objectClass == "STREAMING_SERVER")
}

@Test func accessPointWithoutObjectId() {
  #expect(AccessPoint("GRAY:").objectClass == "GRAY")
  #expect(AccessPoint("GRAY:").accessPointObjectId == "")
  #expect(AccessPoint("no-colon").components == nil)
}
