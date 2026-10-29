import Foundation

public struct ExerciseDefinition: Codable, Hashable, Sendable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct CarePlanStep: Codable, Hashable, Sendable {
    public let exerciseID: String
    public let sets: Int
    public let repetitions: Int

    public init(exerciseID: String, sets: Int, repetitions: Int) {
        self.exerciseID = exerciseID
        self.sets = sets
        self.repetitions = repetitions
    }
}

public struct CarePlan: Codable, Hashable, Sendable {
    public let title: String
    public let durationWeeks: Int
    public let steps: [CarePlanStep]

    public init(title: String, durationWeeks: Int, steps: [CarePlanStep]) {
        self.title = title
        self.durationWeeks = durationWeeks
        self.steps = steps
    }
}

public enum CarePlanValidationError: Error, Equatable, CustomStringConvertible {
    case emptyTitle
    case invalidDuration
    case noSteps
    case unknownExercise(String)
    case invalidDose(exerciseID: String)

    public var description: String {
        switch self {
        case .emptyTitle:
            return "The care-plan title must not be empty."
        case .invalidDuration:
            return "The care-plan duration must be between 1 and 12 weeks."
        case .noSteps:
            return "The care plan must contain at least one exercise step."
        case .unknownExercise(let exerciseID):
            return "The exercise is not present in the approved library: \(exerciseID)."
        case .invalidDose(let exerciseID):
            return "The exercise dose is invalid for: \(exerciseID)."
        }
    }
}

/// Validates structured model output against a local exercise library before persistence.
public struct CarePlanValidator: Sendable {
    public init() {}

    public func validate(
        _ plan: CarePlan,
        against library: Set<ExerciseDefinition>
    ) throws {
        guard !plan.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CarePlanValidationError.emptyTitle
        }
        guard (1...12).contains(plan.durationWeeks) else {
            throw CarePlanValidationError.invalidDuration
        }
        guard !plan.steps.isEmpty else {
            throw CarePlanValidationError.noSteps
        }

        let knownExerciseIDs = Set(library.map(\.id))
        for step in plan.steps {
            guard knownExerciseIDs.contains(step.exerciseID) else {
                throw CarePlanValidationError.unknownExercise(step.exerciseID)
            }
            guard (1...20).contains(step.sets), (1...100).contains(step.repetitions) else {
                throw CarePlanValidationError.invalidDose(exerciseID: step.exerciseID)
            }
        }
    }
}

