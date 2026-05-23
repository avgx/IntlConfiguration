import Foundation
import IntlWireFormat
import RequestResponse

public enum EntityApi {
    public static func configuration() -> Request<[Entity]> {
        let q = [("pageItems", "1000000")]
        return Request(path: "secure/configuration", method: .get, query: q)
    }

    /// Test that answer for `secure/configuration` is 200; used to check auth.
    public static func test() -> Request<Void> {
        Request(path: "secure/configuration", method: .get, query: [("pageItems", "0")])
    }

    public static func objectState(id: AccessPoint) -> Request<EntityState> {
        Request(path: "secure/configuration/\(id)/state/")
    }

    /// Single configuration object, e.g. `GET secure/configuration/CAM:1/`.
    public static func entity(id: AccessPoint) -> Request<Entity> {
        Request(path: "secure/configuration/\(id)/")
    }

    /// Current state icon for an object instance.
    public static func objectStateImage(id: AccessPoint) -> Request<Data> {
        Request(
            path: "secure/configuration/\(id)/state/image.png",
            headers: ["Accept": "image/*"]
        )
    }
}
