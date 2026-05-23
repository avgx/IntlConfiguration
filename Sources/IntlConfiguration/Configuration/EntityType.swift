import Foundation

public enum EntityType: String, Codable, Hashable, Sendable {
    case CAM
    case STREAMING_SERVER
    case MONITOR
    case DISPLAY
    case MACRO
    case FIRSERVER
    case ULPR
    case GRAY
    case GRELE
    case CAM_VMDA_DETECTOR
    case SPEAKER
    case MIC
    case REGION
}
