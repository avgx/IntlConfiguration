import Foundation
import RequestResponse

private let acceptImage: [String: String] = ["Accept": "image/*"]

public enum FloorPlanApi {
    public static func list() -> Request<[FloorPlan]> {
        Request(path: "secure/kartas/")
    }

    public static func layerImage(layerId: ObjectID, mapId: ObjectID) -> Request<Data> {
        Request(
            path: "secure/kartas/\(mapId)/layers/\(layerId)/image.png",
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
