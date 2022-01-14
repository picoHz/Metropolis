import Foundation

public protocol MPAdminAPI {
    /// Gets information about a particular user.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3adminwhoisuserid) for
    /// more informataion.
    func getUserInfo(userId: String) async throws -> MPUserInfo
}

public struct MPUserInfo: Decodable {
    public var devices: [String: DeviceInfo]?
    public var userId: String?

    public struct DeviceInfo: Decodable {
        public var sessions: [SessionInfo]?
    }

    public struct SessionInfo: Decodable {
        public var connections: [ConnectionInfo]?
    }

    public struct ConnectionInfo: Decodable {
        public var ip: String?
        public var lastSeen: Int?
        public var userAgent: String?
    }
}

extension MPClient: MPAdminAPI {
    public func getUserInfo(userId: String) async throws -> MPUserInfo {
        let path: SafePath = "_matrix/client/v3/admin/whois/\(userId)"
        return try await self.send(.get(path.encoded)).value
    }
}
