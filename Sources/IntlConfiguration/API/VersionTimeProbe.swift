import Foundation

/// Result of probing Web1 via `GET secure/video/config.properties` (proxied through web2).
public struct VersionTimeProbe: Equatable, Sendable {
    /// HTTP response from web2 was usable (headers readable).
    public let web2Reachable: Bool
    /// `Server` header contains `-webserver` (Web1 up behind web2).
    public let web1Connected: Bool
    /// Parsed HTTP `Date` header (GMT), if present and valid.
    public let serverDate: Date?

    public init(web2Reachable: Bool, web1Connected: Bool, serverDate: Date?) {
        self.web2Reachable = web2Reachable
        self.web1Connected = web1Connected
        self.serverDate = serverDate
    }

    /// Parses `Server` / `Date` from an HTTP response.
    ///
    /// - Web1 up ⇔ `Server` (case-insensitive) contains `-webserver`.
    /// - `Date` is RFC 1123 / GMT (`EEE, dd MMM yyyy HH:mm:ss zzz`).
    public static func from(httpResponse: HTTPURLResponse?) -> VersionTimeProbe {
        guard let httpResponse else {
            return VersionTimeProbe(web2Reachable: false, web1Connected: false, serverDate: nil)
        }
        let server = httpResponse.value(forHTTPHeaderField: "Server") ?? ""
        let web1 = server.lowercased().contains("-webserver")
        let dateHeader = httpResponse.value(forHTTPHeaderField: "Date")
        return VersionTimeProbe(
            web2Reachable: true,
            web1Connected: web1,
            serverDate: dateHeader.flatMap(Self.parseHTTPDate)
        )
    }

    /// Also accepts a generic `URLResponse`.
    public static func from(response: URLResponse?) -> VersionTimeProbe {
        from(httpResponse: response as? HTTPURLResponse)
    }

    private static let httpDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }()

    public static func parseHTTPDate(_ string: String) -> Date? {
        httpDateFormatter.date(from: string)
    }
}
