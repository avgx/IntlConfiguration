import Foundation
import IntlWireFormat
import RequestResponse

public enum MacroApi {
    public static func list() -> Request<[Macro]> {
        Request(path: "secure/actions/")
    }

    public static func execute(id: String) -> Request<Void> {
        Request(path: "secure/actions/\(id)/execute", method: .put)
    }

    public static func execute(object: AccessPoint, id: String) -> Request<Void> {
        struct Empty: Codable {}
        return Request(
            path: "secure/configuration/\(object)/state/actions/\(id)/execute",
            method: .put,
            body: Empty()
        )
    }
}
