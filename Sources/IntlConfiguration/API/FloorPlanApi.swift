import Foundation
import IntlWireFormat
import RequestResponse

private let acceptImage: [String: String] = ["Accept": "image/*"]

public enum FloorPlanApi {
    public static func list() -> Request<[FloorPlan]> {
        Request(path: "secure/kartas/")
    }

    /// Background only: polygons come from `FloorPlanPoint.polygon`, so they can follow alarm state.
    /// Servers without the `polygons` parameter ignore it.
    public static func layerImage(layerId: ObjectID, mapId: ObjectID) -> Request<Data> {
        Request(
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
