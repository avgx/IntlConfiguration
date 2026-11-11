import Foundation

extension FloorPlan {
    /// Kind of a plan object, as in the thick client (`IDL_en_obj_type`).
    /// Values missing from this list decode with `SafeEnum.value == nil`.
    public enum ViewType: Int, Codable, Hashable, Sendable {
        case objectWithoutImage = 0   // Object without an image
        case icon = 1                 // Icon
        case linkIcon = 5             // Icon linking to another map
        case caption = 6              // Caption (name of the linked object)
        case programmaticIcon = 7     // Icon drawn programmatically
        case animatedIcon = 8         // Animated icon
        case textValue = 15           // Text value
        case line = 16                // Line
        case polygonObject = 17       // Polygon: system object
        case polygonLink = 18         // Polygon link (LINK); permissions are not checked
        case ellipse = 19             // Ellipse
        case geoAxes = 20             // Geo-referencing axes
        case freePicture = 21         // Free-form picture
    }
}
