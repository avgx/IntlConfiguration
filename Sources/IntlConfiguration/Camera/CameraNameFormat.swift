import Foundation

public enum CameraNameFormat: String, CaseIterable, Sendable {
    case id
    case name
    case extended
}

extension Camera {
    public func formattedName(format: CameraNameFormat) -> String {
        switch format {
        case .id:
            return id
        case .name:
            return name
        case .extended:
            return "\(objectID). \(name)"
        }
    }
}
