import Foundation
import IntlWireFormat
import SafeEnum

/// One frame from `secure/ws/states/`. `x` and `y` are ignored.
public struct StateMessage: Decodable, Sendable, Equatable {
    public let objectId: AccessPoint
    public let action: String
    public let state: SafeEnum<EntityStateID>?
    public let ts: String?
}
