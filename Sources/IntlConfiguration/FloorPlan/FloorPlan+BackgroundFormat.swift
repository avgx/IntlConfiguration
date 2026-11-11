import Foundation

extension FloorPlan {
    /// File format of a layer background, from `backgroundFormat`.
    /// Only `svg` changes the image address (`image.svg`); every other format uses `image.png`.
    /// Unknown strings keep `SafeEnum.rawValue` and have `value == nil`.
    public enum BackgroundFormat: String, Codable, Hashable, Sendable {
        case png
        case jpeg
        case bmp
        case svg
    }
}
