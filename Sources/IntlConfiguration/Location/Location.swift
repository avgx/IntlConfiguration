import Foundation

public struct Location : Codable, Sendable, Equatable, Hashable, CustomDebugStringConvertible {
    
    public let latitude: Double
    public let longitude: Double
    public let heading: Double?
    
    public init(latitude: Double, longitude: Double, heading: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.heading = heading
    }
    
    public var debugDescription: String {
        "[\(latitude), \(longitude)]"
    }
    
    public init?(latitude: String?, longitude: String?, azimuth: String?) {
        guard let latStr = latitude, let lonStr = longitude else {
            return nil
        }
        
        /// fix server locate ``, -> .``
        func parseDouble(_ str: String?) -> Double? {
            guard var s = str else { return nil }
            s = s.replacingOccurrences(of: ",", with: ".")
            return Double(s)
        }
        
        guard let latitudeVal = parseDouble(latStr), let longitudeVal = parseDouble(lonStr) else {
            return nil
        }
        
        if latitudeVal == 0 && longitudeVal == 0 {
            return nil
        }
        
        var headingVal: Double? = nil
        if let azStr = azimuth {
            headingVal = parseDouble(azStr)
        }
        
        self.init(latitude: latitudeVal, longitude: longitudeVal, heading: headingVal)
    }
}

extension Location {
    public struct Parser {
        static func matches(for regex: String, in text: String) -> [String] {
            do {
                let regex1 = try NSRegularExpression(pattern: regex)
                let results = regex1.matches(in: text, range: NSRange(text.startIndex..., in: text))
                guard let result = results.first else { return [] }
                let numberOfRanges = result.numberOfRanges
                return (0 ... numberOfRanges - 1).compactMap { rangeAt in
                    let range = result.range(at: rangeAt)
                    if range.location == NSNotFound { return nil }
                    return String(text[Range(range, in: text)!])
                }.filter { !$0.isEmpty }
            } catch {
                return []
            }
        }

        /// Extract geographic coordinates from entity name, e.g. `[55.7558, 37.6173] Moscow`.
        public static func parse(_ rawName: String) -> Location? {
            guard !rawName.isEmpty else { return nil }

            let patternCoords = "\\s*\\[\\s*(\\-?\\d+)(\\.\\d+)?,\\s*(\\-?\\d+)(\\.\\d+)?\\s*(,)?\\s*(\\-?\\d+)?\\.?\\d*\\s*\\]"
            let pattern2 = "\\[.*\\]"

            let m = matches(for: patternCoords, in: rawName)
            guard !m.isEmpty else { return nil }

            let m2 = matches(for: pattern2, in: rawName)
            guard !m2.isEmpty else { return nil }

            let internalCoordStr = m2[0].trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            let components = internalCoordStr
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }

            guard let latitude = Double(components[0]),
                  let longitude = Double(components[1]) else { return nil }

            if latitude < -90 || latitude > 90 { return nil }
            if longitude < -180 || longitude > 180 { return nil }

            if components.count == 2 {
                return Location(latitude: latitude, longitude: longitude, heading: nil)
            }
            if components.count == 3 {
                guard let angle1 = Double(components[2]) else {
                    return Location(latitude: latitude, longitude: longitude, heading: nil)
                }
                if angle1 < -360 || angle1 > 360 {
                    return Location(latitude: latitude, longitude: longitude, heading: nil)
                }
                return Location(latitude: latitude, longitude: longitude, heading: angle1)
            }

            return nil
        }

        /// Remove coordinate suffix from entity name.
        public static func cleanName(_ rawName: String) -> String {
            let patternCoords = "\\s*\\[\\s*(\\-?\\d+)(\\.\\d+)?,\\s*(\\-?\\d+)(\\.\\d+)?\\s*(,)?\\s*(\\-?\\d+)*\\s*\\]"
            let m = matches(for: patternCoords, in: rawName)
            guard !m.isEmpty else { return rawName }
            return rawName.replacingOccurrences(of: m[0], with: "")
        }

        /// Remove leading numeric id prefix, e.g. `12. ` from name.
        public static func cleanId(_ rawName: String) -> String {
            let pattern = "(\\d+\\.)\\s*"
            let m = matches(for: pattern, in: rawName)
            guard !m.isEmpty else { return rawName }
            return rawName.replacingOccurrences(of: m[0], with: "")
        }
    }
}
