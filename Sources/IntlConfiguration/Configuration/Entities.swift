import Foundation
import IntlWireFormat

extension Array where Element == Entity {
    public func linkedObjects() -> [AccessPoint: AccessPoint] {
        filter { $0.linkedObjects != nil }
            .reduce(into: [:]) { acc, entity in
                entity.linkedIds().forEach { acc[$0] = entity.id }
            }
    }

    public func named() -> [AccessPoint: String] {
        reduce(into: [:]) { res, entity in
            let raw = stripMarkupTags(entity.name ?? entity.id)
            res[entity.id] = Location.Parser.cleanName(raw).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    public func cameras() -> [Camera] {
        let rtspPorts = rtsp()
        return filter(\.isCamera).map { Camera.from($0, rtspPorts: rtspPorts) }
    }

    public func locations() -> [AccessPoint: Location] {
        filter(\.isCamera).reduce(into: [:]) { res, cam in
            if let loc = Location.Parser.parse(cam.name ?? "") {
                res[cam.id] = loc
            }
        }
    }

    public func faceRecognitionServers() -> [Entity] {
        filter(\.isFaceRecognitionServer)
    }

    public func rtsp() -> [AccessPoint: Int] {
        filter { $0.isStreamingServer }
            .filter { $0.port != nil && $0.cams != nil }
            .reduce(into: [AccessPoint: Int]()) { res, entity in
                guard let port = entity.port, let portInt = Int(port) else { return }
                guard let cams = entity.cams, !cams.values.isEmpty else { return }
                cams.values
                    .map { AccessPoint(objectClass: EntityType.CAM.rawValue, objectId: String($0)) }
                    .forEach { res[$0] = portInt }
            }
    }

    public func monitors() -> [NamedGroup<ObjectID, AccessPoint>] {
        let monitors = filter(\.isMonitor)
        let useCamList = monitors.contains { $0.camList != nil }
        if useCamList {
            return monitors
                .filter { !($0.camList?.isEmpty ?? true) }
                .map { m in
                    let list = m.camList?.map { AccessPoint(objectClass: EntityType.CAM.rawValue, objectId: $0) } ?? []
                    return NamedGroup(id: m.extId, name: m.name ?? "monitor.\(m.extId)", list: list)
                }
                .sorted { $0.name < $1.name }
        }
        let monitorsNamed = monitors.reduce(into: [ObjectID: String]()) { res, entity in
            let key = entity.monitorIds.first ?? entity.extId
            res[key] = entity.name ?? "monitor.\(key)"
        }
        let cameras = filter(\.isCamera)
        return monitorsNamed.map { id, name in
            let list = cameras.filter { $0.monitorIds.contains(id) }.map(\.id)
            return NamedGroup(id: id, name: name, list: list)
        }
        .sorted { $0.name < $1.name }
    }

    public func displays() -> [NamedGroup<ObjectID, AccessPoint>] {
        let displays = filter(\.isDisplay)
        let useCamList = displays.contains { $0.camList != nil }
        if useCamList {
            return displays
                .filter { !($0.camList?.isEmpty ?? true) }
                .map { m in
                    let list = m.camList?.map { AccessPoint(objectClass: EntityType.CAM.rawValue, objectId: $0) } ?? []
                    return NamedGroup(id: m.extId, name: m.name ?? "display.\(m.extId)", list: list)
                }
                .sorted { $0.name < $1.name }
        }
        let displaysNamed = displays.reduce(into: [ObjectID: String]()) { res, entity in
            let key = entity.displayIds.first ?? entity.extId
            res[key] = entity.name ?? "display.\(key)"
        }
        let cameras = filter(\.isCamera)
        return displaysNamed.map { id, name in
            let list = cameras.filter { $0.displayIds.contains(id) }.map(\.id)
            return NamedGroup(id: id, name: name, list: list)
        }
        .sorted { $0.name < $1.name }
    }

    public func regions() -> [NamedGroup<ObjectID, AccessPoint>] {
        let regionsNamed = reduce(into: [ObjectID: String]()) { res, entity in
            guard let regionId = entity.regionId else { return }
            res[regionId] = entity.regionName ?? "region.\(regionId)"
        }
        let cameras = filter(\.isCamera)
        return regionsNamed.map { id, name in
            let list = cameras.filter { $0.regionId == id }.map(\.id)
            return NamedGroup(id: id, name: name, list: list)
        }
        .sorted { compareObjectID($0.id, $1.id) }
    }

    public func zones() -> [NamedGroup<ObjectID, AccessPoint>] {
        let zonesNamed = reduce(into: [ObjectID: String]()) { res, entity in
            for zoneId in entity.zoneIds {
                res[zoneId] = entity.zoneName ?? "zone.\(zoneId)"
            }
        }
        let cameras = filter(\.isCamera)
        return zonesNamed.map { id, name in
            let list = cameras.filter { $0.zoneIds.contains(id) }.map(\.id)
            return NamedGroup(id: id, name: name, list: list)
        }
        .sorted { compareObjectID($0.id, $1.id) }
    }

    public func zoneRegions() -> [NamedGroup<ObjectID, ObjectID>] {
        let regionZones = reduce(into: [ObjectID: ObjectID]()) { res, entity in
            guard let regionId = entity.regionId else { return }
            res[regionId] = entity.zoneIds.first ?? "0"
        }
        let zonesNamed = reduce(into: [ObjectID: String]()) { res, entity in
            for zoneId in entity.zoneIds {
                res[zoneId] = entity.zoneName ?? "zone.\(zoneId)"
            }
        }
        return zonesNamed.map { id, name in
            let regionIds = regionZones
                .filter { $0.value == id }
                .map(\.key)
                .sorted { compareObjectID($0, $1) }
            return NamedGroup(id: id, name: name, list: regionIds)
        }
    }

    public func rtspStream() -> [Entity] {
        filter(\.isStreamingServer)
            .filter { !($0.cams?.isEmpty ?? true) }
            .filter { (Int($0.port ?? "-1") ?? -1) > 0 }
    }
}

private func stripMarkupTags(_ raw: String) -> String {
    var s = raw
    while let start = s.firstIndex(of: "<"), let end = s[start...].firstIndex(of: ">") {
        s.removeSubrange(start...end)
    }
    return s
}

private func compareObjectID(_ a: ObjectID, _ b: ObjectID) -> Bool {
    let aParts = a.split(separator: ".").map { Int($0) ?? 0 }
    let bParts = b.split(separator: ".").map { Int($0) ?? 0 }
    let count = max(aParts.count, bParts.count)
    for i in 0..<count {
        let av = i < aParts.count ? aParts[i] : 0
        let bv = i < bParts.count ? bParts[i] : 0
        if av != bv { return av < bv }
    }
    return false
}
