# IntlConfiguration

Swift package for **Axxon Intellect** topology configuration: decode `secure/configuration`, aggregate cameras and groups, and describe HTTP endpoints for [RequestResponse](https://github.com/avgx/RequestResponse).

Intellect-only models live here. Account-scoped IDs, stream URLs, and One/Next types belong in upper layers.

## Requirements

- Swift 6.1+
- iOS 15+, macOS 13+, tvOS 17+, visionOS 1+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/avgx/IntlConfiguration", from: "1.0.0"),
],
targets: [
    .target(
        name: "MyApp",
        dependencies: ["IntlConfiguration"]
    ),
]
```

Also add **RequestResponse** (and your HTTP client) in the app target when calling APIs.

## Quick start

```swift
import IntlConfiguration
import RequestResponse

let entities: [Entity] = try await http.send(EntityApi.configuration()).value

let cameras = entities.cameras()
let names = entities.named()
let coords = entities.locations()
let monitors = entities.monitors()
let rtspPorts = entities.rtsp()
```

## Core types

### AccessPoint

Intellect object reference: `ObjectClass:ObjectID`, e.g. `CAM:1`, `MIC:2`.

```swift
let ap = AccessPoint(objectClass: "CAM", objectId: "1")  // "CAM:1"
ap.components?.objectClass  // "CAM"
```

### Entity

Raw configuration row from JSON (`type`, `id`, `extId`, `name`, `state`, region/zone/monitor/display fields, `micId`, `speakerId`, streaming `port`/`cams`, etc.).

Type predicates: `isCamera`, `isStreamingServer`, `isMonitor`, `isDisplay`, `isMacro`, `isFaceRecognitionServer`.

`EntityState` exposes `armState`, `isAlarmed`, `isDisconnected` from `fullState` / `id`.

### Camera

Flat view of a camera built from configuration (no public initializer — use `entities.cameras()`):

| Field | Source |
|-------|--------|
| `id` | `entity.id` (`AccessPoint`) |
| `objectID` | `entity.extId` |
| `name` | display name, coordinates stripped |
| `mic`, `speaker` | optional access points |
| `rtspPort` | from streaming servers via `rtsp()` |
| `telemetryId` | optional PTZ telemetry id |

### Location

Geographic position. Coordinates may be embedded in entity names as `[lat, lon]` or `[lat, lon, heading]`:

```swift
Location.Parser.parse("Camera 1 [55.7558, 37.6173]")
Location.Parser.cleanName("Camera 1 [55.7558, 37.6173]")  // "Camera 1"
```

`Location.create(latitude:longitude:azimuth:)` parses floor-plan string fields (comma decimals).

## `[Entity]` aggregations

| Method | Returns |
|--------|---------|
| `cameras()` | `[Camera]` |
| `named()` | `[AccessPoint: String]` — cleaned display names |
| `locations()` | `[AccessPoint: Location]` — coords parsed from camera names |
| `rtsp()` | `[AccessPoint: Int]` — camera AP → RTSP port |
| `rtspStream()` | `[Entity]` — streaming servers with port and cameras |
| `monitors()` | `[NamedGroup<ObjectID, AccessPoint>]` |
| `displays()` | `[NamedGroup<ObjectID, AccessPoint>]` |
| `regions()` | `[NamedGroup<ObjectID, AccessPoint>]` |
| `zones()` | `[NamedGroup<ObjectID, AccessPoint>]` |
| `zoneRegions()` | `[NamedGroup<ObjectID, ObjectID>]` |
| `linkedObjects()` | `[AccessPoint: AccessPoint]` |
| `faceRecognitionServers()` | `[Entity]` |

`ObjectIDList` fields (`monitorId`, `displayId`, `zoneId`, `cams`) accept one id or several separated by `;`.

## HTTP API descriptors

| Enum | Endpoints |
|------|-----------|
| `EntityApi` | `configuration()`, `test()`, `objectState(id:)` |
| `MacroApi` | `list()`, `execute(id:)`, `execute(object:id:)` |
| `FloorPlanApi` | `list()`, `layerImage(layerId:mapId:)`, `objectActions(id:)` |
| `WebserverApi` | `versionTime()` (proxied video config) |

All return `Request<...>` for RequestResponse.

## Tests

```bash
swift test
```

Fixtures under `Tests/IntlConfigurationTests/Resources/`. Live tests use `.env` (see `.env.example`).

## License

See [LICENSE](LICENSE).
