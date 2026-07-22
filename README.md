# IntlConfiguration

Swift package for topology configuration: decode `secure/configuration`, aggregate cameras and groups, and describe HTTP endpoints for [RequestResponse](https://github.com/avgx/RequestResponse).

Intl-only models live here.

Shared wire types (`AccessPoint`, `ObjectID`, …) come from [IntlWireFormat](https://github.com/avgx/IntlWireFormat).

## Project layout

```
Sources/IntlConfiguration/
├── API/              EntityApi, FloorPlanApi, MacroApi, WebserverApi
├── Configuration/    Entity, EntityState, aggregations on [Entity]
├── Camera/           Camera
├── Location/         Location, coordinate parsing from names
├── FloorPlan/        FloorPlan
├── Macro/            Macro
└── Primitive/        NamedGroup, ArmState

Tests/IntlConfigurationTests/
├── Decoding/         mirrors source domains
├── Integration/      live server tests (.env)
├── Support/          FixtureSupport, DotEnv
└── Resources/        JSON fixtures
```

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

From **IntlWireFormat** — Intellect object reference: `ObjectClass:ObjectID`, e.g. `CAM:1`, `MIC:2`.

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
| `EntityApi` | `configuration()`, `test()`, `objectState(id:)`, `entity(id:)`, `objectStateImage(id:)` |
| `ObjectClassApi` | `states(objectClass:)` |
| `MacroApi` | `list()`, `execute(id:)`, `execute(object:id:)` |
| `FloorPlanApi` | `list()`, `layerImage(layerId:mapId:)`, `objectActions(id:)` |
| `WebserverApi` | `versionTime()` — `GET secure/video/config.properties` (Web1 probe via web2; parse `Server`/`Date` with `VersionTimeProbe`) |

All return `Request<...>` for RequestResponse.

## Tests

```bash
swift test
```

Fixtures under `Tests/IntlConfigurationTests/Resources/`. Decoding tests mirror `Sources/` domains under `Decoding/`. Live tests in `Integration/` use `.env` (see `.env.example`).

## License

See [LICENSE](LICENSE).
