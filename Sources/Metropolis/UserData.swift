import Foundation
import SwiftyJSON

public protocol MPUserDataAPI {
    /// Get the user's display name.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3profileuseriddisplayname) for
    /// more informataion.
    func getDisplayName(userId: String) async throws -> String

    /// Set the user's display name.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3profileuseriddisplayname) for
    /// more informataion.
    func setDisplayName(userId: String, displayName: String) async throws

    /// Get the user's avatar URL.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3profileuseridavatar_url) for
    /// more informataion.
    func getAvatarUrl(userId: String) async throws -> URL

    /// Set the user's avatar URL.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3profileuseridavatar_url) for
    /// more informataion.
    func setAvatarUrl(userId: String, avatarUrl: URL) async throws

    /// Get this user's profile information.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3profileuserid) for
    /// more informataion.
    func getProfile(userId: String) async throws -> JSON

    /// Get this user's presence state.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3presenceuseridstatus) for
    /// more informataion.
    func getPresence(userId: String) async throws -> MPUserPresenceState

    /// Update this user's presence state.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3presenceuseridstatus) for
    /// more informataion.
    func updatePresence(userId: String, presence: MPUserPresence) async throws

    /// Get some account_data for the user.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3useruseridaccount_datatype) for
    /// more informataion.
    func getAccountData(userId: String, type: String) async throws -> JSON

    /// Set some account_data for the user.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3useruseridaccount_datatype) for
    /// more informataion.
    func setAccountData<Data: Encodable>(userId: String, type: String, data: Data) async throws

    /// Get some account_data for the user.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3useruseridroomsroomidaccount_datatype) for
    /// more informataion.
    func getAccountData(userId: String, roomId: String, type: String) async throws -> JSON

    /// Set some account_data for the user.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3useruseridroomsroomidaccount_datatype) for
    /// more informataion.
    func setAccountData<Data: Encodable>(userId: String, roomId: String, type: String, data: Data)
        async throws

    /// List the tags for a room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3useruseridroomsroomidtags) for
    /// more informataion.
    func getTags(userId: String, roomId: String) async throws -> [String: MPTagContent]

    /// Add a tag to a room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3useruseridroomsroomidtagstag) for
    /// more informataion.
    func addTag(userId: String, roomId: String, tag: String, order: Float?) async throws

    /// Remove a tag from the room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#delete_matrixclientv3useruseridroomsroomidtagstag) for
    /// more informataion.
    func removeTag(userId: String, roomId: String, tag: String) async throws
}

public enum MPUserPresenceKind: String, Codable {
    case offline
    case online
    case unavailable
}

public struct MPUserPresence: Encodable {
    public var presence: MPUserPresenceKind
    public var statusMsg: String?
}

public struct MPUserPresenceState: Decodable {
    public var currentlyActive: Bool?
    public var lastActiveAgo: Int?
    public var presence: MPUserPresenceKind
    public var statusMsg: String?
}

public struct MPTagContent: Codable {
    public var order: Float?
}

extension MPClient: MPUserDataAPI {
    public func getDisplayName(userId: String) async throws -> String {
        struct DisplayName: Decodable {
            var displayname: String
        }

        let path: SafePath = "_matrix/client/v3/profile/\(userId)/displayname"
        let name: DisplayName = try await self.send(.get(path.encoded)).value
        return name.displayname
    }

    public func setDisplayName(userId: String, displayName: String) async throws {
        struct DisplayName: Encodable {
            var displayname: String
        }

        let path: SafePath = "_matrix/client/v3/profile/\(userId)/displayname"
        let name = DisplayName(displayname: displayName)
        try await self.send(.put(path.encoded, body: name))
    }

    public func getAvatarUrl(userId: String) async throws -> URL {
        struct AvatarUrl: Decodable {
            var avatarUrl: URL
        }

        let path: SafePath = "_matrix/client/v3/profile/\(userId)/avatar_url"
        let url: AvatarUrl = try await self.send(.get(path.encoded)).value
        return url.avatarUrl
    }

    public func setAvatarUrl(userId: String, avatarUrl: URL) async throws {
        struct AvatarUrl: Codable {
            var avatarUrl: URL
        }

        let path: SafePath = "_matrix/client/v3/profile/\(userId)/avatar_url"
        let url = AvatarUrl(avatarUrl: avatarUrl)
        try await self.send(.put(path.encoded, body: url))
    }

    public func getProfile(userId: String) async throws -> JSON {
        let path: SafePath = "_matrix/client/v3/profile/\(userId)"
        return try await self.send(.get(path.encoded)).value
    }

    public func getPresence(userId: String) async throws -> MPUserPresenceState {
        let path: SafePath = "_matrix/client/v3/presence/\(userId)/status"
        return try await self.send(.get(path.encoded)).value
    }

    public func updatePresence(userId: String, presence: MPUserPresence) async throws {
        let path: SafePath = "_matrix/client/v3/presence/\(userId)/status"
        try await self.send(.put(path.encoded, body: presence))
    }

    public func getAccountData(userId: String, type: String) async throws -> JSON {
        let path: SafePath = "_matrix/client/v3/user/\(userId)/account_data/\(type)"
        return try await self.send(.get(path.encoded)).value
    }

    public func setAccountData<Data: Encodable>(userId: String, type: String, data: Data)
        async throws
    {
        let path: SafePath = "_matrix/client/v3/user/\(userId)/account_data/\(type)"
        try await self.send(.put(path.encoded, body: data))
    }

    public func getAccountData(userId: String, roomId: String, type: String) async throws -> JSON {
        let path: SafePath = "_matrix/client/v3/user/\(userId)/rooms/\(roomId)/account_data/\(type)"
        return try await self.send(.get(path.encoded)).value
    }

    public func setAccountData<Data: Encodable>(
        userId: String, roomId: String, type: String, data: Data
    ) async throws {
        let path: SafePath = "_matrix/client/v3/user/\(userId)/rooms/\(roomId)/account_data/\(type)"
        try await self.send(.put(path.encoded, body: data))
    }

    public func getTags(userId: String, roomId: String) async throws -> [String: MPTagContent] {
        struct TagList: Decodable {
            var tags: [String: MPTagContent]
        }

        let path: SafePath = "_matrix/client/v3/user/\(userId)/rooms/\(roomId)/tags"
        let list: TagList = try await self.send(.get(path.encoded)).value
        return list.tags
    }

    public func addTag(userId: String, roomId: String, tag: String, order: Float? = nil)
        async throws
    {
        let path: SafePath = "_matrix/client/v3/user/\(userId)/rooms/\(roomId)/tags/\(tag)"
        try await self.send(.put(path.encoded, body: MPTagContent(order: order)))
    }

    public func removeTag(userId: String, roomId: String, tag: String) async throws {
        let path: SafePath = "_matrix/client/v3/user/\(userId)/rooms/\(roomId)/tags/\(tag)"
        try await self.send(.delete(path.encoded))
    }
}
