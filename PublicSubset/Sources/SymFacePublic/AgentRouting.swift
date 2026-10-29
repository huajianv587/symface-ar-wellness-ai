import Foundation

/// The provider options used by the full SymFace prototype.
/// Network clients and credentials are intentionally excluded from this public subset.
public enum AIProvider: String, CaseIterable, Codable, Sendable {
    case appleFoundationModels
    case openAI
    case claude
    case deepSeek
    case coze
    case offlineTemplate
}

public enum AgentRequest: Sendable {
    case carePlan
    case conversationalSupport
    case unavailableNetworkFallback
}

/// A deterministic routing policy that can be tested without calling an external provider.
public struct ProviderRouter: Sendable {
    public let availableProviders: Set<AIProvider>
    public let preferOnDevice: Bool

    public init(
        availableProviders: Set<AIProvider>,
        preferOnDevice: Bool = true
    ) {
        self.availableProviders = availableProviders
        self.preferOnDevice = preferOnDevice
    }

    public func route(for request: AgentRequest) -> AIProvider {
        switch request {
        case .carePlan:
            if preferOnDevice, availableProviders.contains(.appleFoundationModels) {
                return .appleFoundationModels
            }
            return firstAvailable([.deepSeek, .openAI, .claude, .coze, .offlineTemplate])
        case .conversationalSupport:
            return firstAvailable([.coze, .claude, .openAI, .deepSeek, .offlineTemplate])
        case .unavailableNetworkFallback:
            return .offlineTemplate
        }
    }

    private func firstAvailable(_ candidates: [AIProvider]) -> AIProvider {
        candidates.first(where: availableProviders.contains) ?? .offlineTemplate
    }
}

