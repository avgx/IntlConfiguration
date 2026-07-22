import Foundation
import Testing
@testable import IntlConfiguration

@Test func versionTimeProbeWeb1FromServerHeader() {
    let url = URL(string: "https://example.test/secure/video/config.properties")!
    let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: [
            "Server": "MyApp-webserver",
            "Date": "Wed, 22 Jul 2026 14:00:00 GMT",
        ]
    )
    let probe = VersionTimeProbe.from(httpResponse: response)
    #expect(probe.web2Reachable)
    #expect(probe.web1Connected)
    #expect(probe.serverDate != nil)
}

@Test func versionTimeProbeWeb2OnlyWithoutWebserverToken() {
    let url = URL(string: "https://example.test/secure/video/config.properties")!
    let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: [
            "Server": "nginx",
            "Date": "Wed, 22 Jul 2026 14:00:00 GMT",
        ]
    )
    let probe = VersionTimeProbe.from(httpResponse: response)
    #expect(probe.web2Reachable)
    #expect(!probe.web1Connected)
}

@Test func versionTimeProbeNilResponse() {
    let probe = VersionTimeProbe.from(httpResponse: nil)
    #expect(!probe.web2Reachable)
    #expect(!probe.web1Connected)
    #expect(probe.serverDate == nil)
}
