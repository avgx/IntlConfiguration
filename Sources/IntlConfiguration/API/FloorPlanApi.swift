import Foundation
import IntlWireFormat
import RequestResponse
import SafeEnum

private let acceptImage: [String: String] = ["Accept": "image/*"]

public enum FloorPlanApi {
    public static func list() -> Request<[FloorPlan]> {
        Request(path: "secure/kartas/")
    }

    /// Background only: polygons come from `FloorPlan.Point.polygon`, so they can follow alarm state.
    /// Servers without the `polygons` parameter ignore it.
    /// The address depends only on whether the background is SVG: `image.svg` for SVG, `image.png` for everything else
    /// (including a missing or unknown format).
    public static func layerImage(
        layerId: ObjectID,
        mapId: ObjectID,
        backgroundFormat: SafeEnum<FloorPlan.BackgroundFormat>? = nil
    ) -> Request<Data> {
        if backgroundFormat?.value == .svg {
            return Request(
                path: "secure/kartas/\(mapId)/layers/\(layerId)/image.svg",
                headers: acceptImage
            )
        }
        return Request(
            path: "secure/kartas/\(mapId)/layers/\(layerId)/image.png",
            query: [("polygons", "false")],
            headers: acceptImage
        )
    }

    public static func objectActions(id: AccessPoint) -> Request<[Macro]> {
        Request(path: "secure/configuration/\(id)/state/actions")
    }

    @available(*, deprecated)
    public static func stateImageUrl(objectClass: String, state: String) -> Request<Data> {
        Request(
            path: "secure/objectClasses/\(objectClass)/states/\(state)/image.png",
            headers: acceptImage
        )
    }
}
