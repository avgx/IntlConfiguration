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
}
