import Foundation

/// Intellect object id field: one value (`"3"`) or several separated by `;` (`"38;45;18"`).
public struct ObjectIDList: Equatable, Sendable, ExpressibleByStringLiteral {
    public let raw: String?

    public init(raw: String?) {
        self.raw = raw
    }

    public init(stringLiteral value: String) {
        self.raw = value
    }

    public var values: [ObjectID] {
        guard let raw, !raw.isEmpty else { return [] }
        return raw
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    public var first: ObjectID? {
        values.first
    }

    public func contains(_ id: ObjectID) -> Bool {
        values.contains(id)
    }
}

extension ObjectIDList: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            raw = nil
        } else {
            raw = try container.decode(String.self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let raw {
            try container.encode(raw)
        } else {
            try container.encodeNil()
        }
    }
}
