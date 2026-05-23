import Foundation
import RequestResponse

public enum WebserverApi {
    /// Proxied to webserver via web2 (`secure/video/*`).
    public static func versionTime() -> Request<Void> {
        Request(path: "secure/video/config.properties", method: .get)
    }
}
