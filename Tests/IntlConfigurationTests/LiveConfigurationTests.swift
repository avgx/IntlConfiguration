import Foundation
import Testing
@testable import IntlConfiguration

private enum LiveTest {
    /// Opt-in: set `INTL_LIVE=1` plus `INTL_URL` / `INTL_USER` / `INTL_PASSWORD` in `.env`.
    static var isConfigured: Bool {
        let env = DotEnv.merged
        guard env["INTL_LIVE"] == "1",
              let url = env["INTL_URL"], !url.isEmpty,
              let user = env["INTL_USER"], !user.isEmpty,
              let password = env["INTL_PASSWORD"], !password.isEmpty,
              URL(string: url) != nil
        else { return false }
        return true
    }
}

/// Requires: `INTL_URL`, `INTL_USER`, `INTL_PASSWORD` in `.env` or environment.
/// `INTL_URL` should point at web2 base (e.g. `https://host/web2`).
@Test(.enabled(if: LiveTest.isConfigured))
func liveConfigurationDecodes() async throws {
    let env = DotEnv.merged
    let urlString = env["INTL_URL"]!
    let baseURL = URL(string: urlString)!
    let user = env["INTL_USER"]!
    let password = env["INTL_PASSWORD"]!

    var requestURL = baseURL
    if requestURL.path.isEmpty || requestURL.path == "/" {
        requestURL.append(path: "web2")
    }
    requestURL.append(path: "secure/configuration")
    var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)!
    components.queryItems = [URLQueryItem(name: "pageItems", value: "1000000")]
    guard let finalURL = components.url else {
        Issue.record("Invalid configuration URL built from INTL_URL")
        return
    }

    var request = URLRequest(url: finalURL)
    request.httpMethod = "GET"
    let credentials = "\(user):\(password)"
    request.setValue("Basic \(Data(credentials.utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")

    let data: Data
    let statusCode: Int
    do {
        let (body, response) = try await URLSession.shared.data(for: request)
        data = body
        statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
    } catch {
        Issue.record("Request failed: \(error)")
        return
    }

    guard statusCode == 200 else {
        Issue.record("Expected HTTP 200, got \(statusCode) from \(finalURL)")
        return
    }

    let entities = try JSONDecoder().decode([Entity].self, from: data)
    #expect(!entities.isEmpty)
    #expect(entities.contains { $0.isCamera })
}
