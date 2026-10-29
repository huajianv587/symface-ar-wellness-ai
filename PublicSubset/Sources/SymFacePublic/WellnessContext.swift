import Foundation

public struct ScanObservation: Codable, Hashable, Sendable {
    public let sessionID: UUID
    public let summary: String
    public let capturedAt: Date

    public init(sessionID: UUID = UUID(), summary: String, capturedAt: Date = .now) {
        self.sessionID = sessionID
        self.summary = summary
        self.capturedAt = capturedAt
    }
}

public struct HealthSnapshot: Codable, Hashable, Sendable {
    public let sleepHours: Double?
    public let activityMinutes: Int?
    public let restingHeartRate: Double?

    public init(
        sleepHours: Double? = nil,
        activityMinutes: Int? = nil,
        restingHeartRate: Double? = nil
    ) {
        self.sleepHours = sleepHours
        self.activityMinutes = activityMinutes
        self.restingHeartRate = restingHeartRate
    }
}

/// Builds a bounded, inspectable context string for a downstream care-plan or chat request.
/// The public subset does not include HealthKit or vendor SDK adapters.
public struct WellnessContextBuilder: Sendable {
    public init() {}

    public func makeContext(
        scan: ScanObservation?,
        health: HealthSnapshot?
    ) -> String {
        var sections = ["SymFace wellness context"]

        if let scan {
            sections.append("Scan observation: \(scan.summary)")
        }

        if let health {
            var signals: [String] = []
            if let sleepHours = health.sleepHours {
                signals.append(String(format: "sleep_hours=%.1f", sleepHours))
            }
            if let activityMinutes = health.activityMinutes {
                signals.append("activity_minutes=\(activityMinutes)")
            }
            if let restingHeartRate = health.restingHeartRate {
                signals.append(String(format: "resting_heart_rate=%.0f", restingHeartRate))
            }
            if !signals.isEmpty {
                sections.append("Selected health signals: " + signals.joined(separator: ", "))
            }
        }

        sections.append("Use this information for wellness guidance only; do not infer a medical diagnosis.")
        return sections.joined(separator: "\n")
    }
}

