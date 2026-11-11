import Foundation

extension FloorPlan {
    /// Kind of a plan object. The server sends the case name as a string (`"IMAGE"`, `"POLYGON"`, ...).
    /// Values missing from this list decode with `SafeEnum.value == nil`.
    public enum ViewType: String, Codable, Hashable, Sendable {
        case base = "BASE"                                   // Object without an image
        case image = "IMAGE"                                 // Icon: angle, title
        case imageLink = "IMAGE_LINK"                        // Icon linking to a layer: link, title
        case title = "TITLE"                                 // Caption: title
        case imageAndIndicator = "IMAGE_AND_INDICATOR"       // Icon with an indicator
        case imageAnim = "IMAGE_ANIM"                        // Animated icon
        case text = "TEXT"                                   // Text value: info
        case line = "LINE"                                   // Line: geometry is not sent
        case polygon = "POLYGON"                             // System object as a polygon: polygon
        case polygonLink = "POLYGON_LINK"                    // Polygon link (LINK object): polygon, link
        case ellipse = "ELLIPSE"                             // Ellipse: geometry is not sent
        case axes = "AXES"                                   // Geo-referencing axes
        case freeImage = "FREE_IMAGE"                        // Free-form picture

        /// Numeric codes of the previous wire format. Only used to read old responses.
        static func legacy(code: Int) -> ViewType? {
            switch code {
            case 0: return .base
            case 1: return .image
            case 5: return .imageLink
            case 6: return .title
            case 7: return .imageAndIndicator
            case 8: return .imageAnim
            case 15: return .text
            case 16: return .line
            case 17: return .polygon
            case 18: return .polygonLink
            case 19: return .ellipse
            case 20: return .axes
            case 21: return .freeImage
            default: return nil
            }
        }
    }
}
