import Foundation

enum FixtureSupport {
    static func loadJSON(named name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw FixtureError.missing(name)
        }
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(_ name: String, as type: T.Type = T.self) throws -> T {
        let data = try loadJSON(named: name)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum FixtureError: Error, CustomStringConvertible {
    case missing(String)

    var description: String {
        switch self {
        case .missing(let name): "Missing fixture: \(name).json"
        }
    }
}
