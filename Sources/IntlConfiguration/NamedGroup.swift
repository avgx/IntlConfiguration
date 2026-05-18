import Foundation

public struct NamedGroup<ID: Hashable & Sendable, Element: Sendable>: Sendable {
    public let id: ID
    public let name: String
    public let list: [Element]

    public init(id: ID, name: String, list: [Element]) {
        self.id = id
        self.name = name
        self.list = list
    }
}
