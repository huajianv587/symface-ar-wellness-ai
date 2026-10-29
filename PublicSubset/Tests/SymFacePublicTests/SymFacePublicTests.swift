import Testing
import Foundation
@testable import SymFacePublic

@Test("provider routing prefers an on-device model for care plans")
func providerRoutingPrefersOnDeviceModel() {
    let router = ProviderRouter(
        availableProviders: [.appleFoundationModels, .deepSeek, .offlineTemplate]
    )

    #expect(router.route(for: .carePlan) == .appleFoundationModels)
}

@Test("care plans are validated against the exercise library")
func carePlanValidation() throws {
    let library: Set<ExerciseDefinition> = [
        ExerciseDefinition(id: "jaw-release", name: "Jaw release")
    ]
    let plan = CarePlan(
        title: "Example wellness plan",
        durationWeeks: 4,
        steps: [CarePlanStep(exerciseID: "jaw-release", sets: 2, repetitions: 8)]
    )

    try CarePlanValidator().validate(plan, against: library)
}

@Test("context assembly includes a wellness safety boundary")
func contextAssemblyIncludesSafetyBoundary() {
    let context = WellnessContextBuilder().makeContext(
        scan: ScanObservation(summary: "Example scan summary"),
        health: HealthSnapshot(sleepHours: 7.5, activityMinutes: 30)
    )

    #expect(context.contains("wellness guidance only"))
    #expect(context.contains("sleep_hours=7.5"))
}

