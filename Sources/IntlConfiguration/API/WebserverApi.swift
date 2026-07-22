import Foundation
import RequestResponse

public enum WebserverApi {
    /// Proxied to webserver via web2 (`secure/video/*`).
    ///
    /// Used to probe **Web1** viability: callers should inspect `Server` / `Date`
    /// on the HTTP response via ``VersionTimeProbe``.
    public static func versionTime() -> Request<Void> {
        Request(path: "secure/video/config.properties", method: .get)
    }
}
