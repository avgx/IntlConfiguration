import Foundation
import RequestResponse

public enum StateApi {
    /// WebSocket descriptor for live object states (`secure/ws/states/`).
    public static func feed() -> Request<Void> {
        Request(path: "secure/ws/states/", method: .get, query: nil)
    }
}
