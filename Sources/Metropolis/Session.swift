import Foundation
import Get

public protocol MPSessionAPI {
    /// Authenticates the user.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3login) for
    /// more informataion.
    func login<A: MPAuthMethod>(method: A, deviceId: String?, initialDeviceDisplayName: String?)
        async throws -> MPClient

    /// Invalidates a user access token.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3logout) for
    /// more informataion.
    func logout() async throws

    /// Invalidates all access tokens for a user.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3logoutall) for
    /// more informataion.
    func logoutAll() async throws

    /// Get the supported login types to authenticate users.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3login) for
    /// more informataion.
    func getSupportedLoginFlows() async throws -> [MPLoginFlow]
}

public struct MPLoginFlow: Decodable {
    public var type: String
    public var identityProviders: [MPIdentityProvider]?
}

public struct MPIdentityProvider: Decodable {
    public var id: String
    public var name: String
    public var icon: String?
    public var brand: String?
}

extension MPClient: MPSessionAPI {
    public func login<A: MPAuthMethod>(
        method: A, deviceId: String? = nil, initialDeviceDisplayName: String? = nil
    ) async throws -> MPClient {
        let path: SafePath = "_matrix/client/v3/login"
        let loginAuth = LoginAuth(
            method: method, deviceId: deviceId, initialDeviceDisplayName: initialDeviceDisplayName)
        let response: LoginResponse = try await self.send(.post(path.encoded, body: loginAuth))
            .value
        let baseUrl = response.homeserver() ?? self.client.baseUrl
        let client = try RESTClient(baseUrl: baseUrl, accessToken: response.accessToken)
        return MPClient(client: client, deviceId: response.deviceId, userId: response.userId)
    }

    public func logout() async throws {
        let path: SafePath = "_matrix/client/v3/logout"
        try await self.client.send(.post(path.encoded))
    }

    public func logoutAll() async throws {
        let path: SafePath = "_matrix/client/v3/logout/all"
        try await self.client.send(.post(path.encoded))
    }

    public func getSupportedLoginFlows() async throws -> [MPLoginFlow] {
        struct LoginFlowList: Decodable {
            var flows: [MPLoginFlow]
        }

        let path: SafePath = "_matrix/client/v3/login"
        let list: LoginFlowList = try await self.send(.get(path.encoded)).value
        return list.flows
    }
}

struct DiscoveryInfo: Decodable {
    var homeserver: ServerInfo
    var identityServer: ServerInfo?

    enum CodingKeys: String, CodingKey {
        case homeserver = "m.homeserver"
        case identityServer = "m.identity_server"
    }
}

struct ServerInfo: Decodable {
    var baseUrl: URL
}

struct LoginResponse: Decodable {
    var accessToken: String
    var deviceId: String
    var userId: String
    var wellKnown: DiscoveryInfo?

    public func homeserver() -> URL? {
        guard let server = self.wellKnown?.homeserver else {
            return nil
        }
        return server.baseUrl
    }
}

private struct LoginAuth<T: MPAuthMethod> {
    public var method: T
    public var deviceId: String?
    public var initialDeviceDisplayName: String?

    enum CodingKeys: String, CodingKey {
        case deviceId
        case initialDeviceDisplayName
    }
}

extension LoginAuth: Encodable {
    public func encode(to encoder: Encoder) throws {
        try method.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let deviceId = deviceId {
            try container.encode(deviceId, forKey: .deviceId)
        }
        if let initialDeviceDisplayName = initialDeviceDisplayName {
            try container.encode(initialDeviceDisplayName, forKey: .initialDeviceDisplayName)
        }
    }
}
