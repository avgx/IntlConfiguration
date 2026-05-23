import Foundation
import IntlWireFormat
import RequestResponse

public enum ObjectClassApi {
    /// Lists available state ids for an object class, e.g. `GET secure/objectClasses/CAM/states/`.
    public static func states(objectClass: ObjectClass) -> Request<[ObjectClassState]> {
        Request(path: "secure/objectClasses/\(objectClass)/states/")
    }
}

public struct ObjectClassState: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String?
}
