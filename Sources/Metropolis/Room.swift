import Foundation
import SwiftyJSON

public protocol MPRoomAPI {
    /// Create a new room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3createroom) for
    /// more informataion.
    func createRoom(room: MPRoomCreationRequest) async throws -> String

    /// Upgrades a room to a new room version.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidupgrade) for
    /// more informataion.
    func upgradeRoom(roomId: String, newVersion: String) async throws -> String

    /// Lists the user's current rooms.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3joined_rooms) for
    /// more informataion.
    func getJoinedRooms() async throws -> [String]

    /// Lists the public rooms on the server.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3publicrooms) for
    /// more informataion.
    func getPublicRooms(limit: Int?, server: String?, since: MPPaginationToken?) async throws
        -> MPPublicRoomStream

    /// Lists the public rooms on the server with optional filter.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3publicrooms) for
    /// more informataion.
    func getPublicRooms(
        genericSearchTerm: String?, includeAllNetworks: Bool?, thirdPartyInstanceId: String?,
        limit: Int?, server: String?, since: MPPaginationToken?
    ) async throws -> MPPublicRoomStream

    /// Set the position of the read marker for a room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidread_markers) for
    /// more informataion.
    func setReadMarker(roomId: String, fullyRead: String, read: String?) async throws

    /// Gets the visibility of a room in the directory.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3directorylistroomroomid) for
    /// more informataion.
    func getRoomVisibility(roomId: String) async throws -> MPRoomVisibility

    /// Sets the visibility of a room in the room directory.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3directorylistroomroomid) for
    /// more informataion.
    func setRoomVisibility(roomId: String, visibility: MPRoomVisibility) async throws

    /// Create a new mapping from room alias to room ID.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3directoryroomroomalias) for
    /// more informataion.
    func createRoomAlias(roomAlias: String, roomId: String) async throws

    /// Remove a mapping of room alias to room ID.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#delete_matrixclientv3directoryroomroomalias) for
    /// more informataion.
    func removeRoomAlias(roomAlias: String) async throws

    /// Get the room ID corresponding to this room alias.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3directoryroomroomalias) for
    /// more informataion.
    func resolveRoomAlias(roomAlias: String) async throws -> MPRoomIdState

    /// Get a list of local aliases on a given room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidaliases) for
    /// more informataion.
    func getLocalRoomAliases(roomId: String) async throws -> [String]

    /// Gets the list of currently joined users and their profile data.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidjoined_members) for
    /// more informataion.
    func getJoinedUsers(roomId: String) async throws -> [MPUser]

    /// Get the m.room.member events for the room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidmembers) for
    /// more informataion.
    func getRoomMembers(
        roomId: String, at: String?, membership: [MPRoomMembership]?,
        notMembership: [MPRoomMembership]?
    ) async throws -> [MPStateEvent]

    /// Start the requesting user participating in a particular room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3joinroomidoralias) for
    /// more informataion.
    func joinRoom(
        roomIdOrAlias: String, serverName: [String]?, request: MPRoomParticipationRequest?
    ) async throws -> String

    /// Start the requesting user participating in a particular room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidjoin) for
    /// more informataion.
    func joinRoom(roomId: String, request: MPRoomParticipationRequest?) async throws -> String

    /// Invite a user to participate in a particular room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidinvite) for
    /// more informataion.
    func inviteUser(roomId: String, userId: String, reason: String?) async throws

    /// Invite a user to participate in a particular room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidinvite-1) for
    /// more informataion.
    func inviteUser(roomId: String, invite: MPRoomInvite3pid) async throws

    /// Ban a user in the room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidban) for
    /// more informataion.
    func banUser(roomId: String, userId: String, reason: String?) async throws

    /// Unban a user from the room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidunban) for
    /// more informataion.
    func unbanUser(roomId: String, userId: String, reason: String?) async throws

    /// Kick a user from the room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidkick) for
    /// more informataion.
    func kickUser(roomId: String, userId: String, reason: String?) async throws

    /// Stop the requesting user remembering about a particular room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidforget) for
    /// more informataion.
    func forgetRoom(roomId: String) async throws

    /// Knock on a room, requesting permission to join.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3knockroomidoralias) for
    /// more informataion.
    func knockRoom(roomIdOrAlias: String, serverName: [String]?, reason: String?) async throws

    /// Stop the requesting user participating in a particular room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidleave) for
    /// more informataion.
    func leaveRoom(roomId: String, reason: String?) async throws
}

public enum MPRoomVisibility: String, Codable {
    case publicRoom = "public"
    case privateRoom = "private"
}

public enum MPRoomMembership: String, Codable {
    case join
    case invite
    case knock
    case leave
    case ban
}

public struct MPRoomIdState: Decodable {
    public var roomId: String
    public var servers: [String]
}

public enum MPRoomPreset: String, Encodable {
    case privateChat = "private_chat"
    case publicChat = "public_chat"
    case trustedPrivateChat = "trusted_private_chat"
}

public struct MPRoomPreviousRoom: Encodable {
    public var eventId: String
    public var roomId: String
}

public struct MPRoomStateEvent: Encodable {
    public var content: JSON
    public var stateKey: String?
    public var type: String
}

public struct MPRoomCreationContent: Encodable {
    public var federate: Bool?
    public var predecessor: MPRoomPreviousRoom?

    enum CodingKeys: String, CodingKey {
        case federate = "m.federate"
        case predecessor
    }
}

public struct MPRoomInvite3pid: Encodable {
    public var address: String
    public var idAccessToken: String
    public var idServer: URL
    public var medium: MPThirdPartyMedium
}

public struct MPRoomPowerLevelContent: Encodable {
    public var ban: Int?
    public var events: [String: Int]?
    public var eventsDefault: Int?
    public var invite: Int?
    public var kick: Int?
    public var notifications: [String: Int]?
    public var redact: Int?
    public var stateDefault: Int?
    public var users: [String: Int]?
    public var usersDefault: Int?
}

public struct MPRoomParticipationRequest: Encodable {
    public var reason: String?
    public var thirdPartySigned: ThirdPartySigned?

    public struct ThirdPartySigned: Encodable {
        public var mxid: String
        public var sender: String
        public var signatures: [String: [String: String]]
        public var token: String
    }
}

public struct MPRoomCreationRequest: Encodable {
    public var creationContent: MPRoomCreationContent?
    public var initialState: [MPRoomStateEvent]?
    public var invite: [String]?
    public var invite3pid: MPRoomInvite3pid?
    public var isDirect: Bool?
    public var name: String?
    public var powerLevelContentOverride: MPRoomPowerLevelContent?
    public var preset: MPRoomPreset?
    public var roomAliasName: String?
    public var roomVersion: String?
    public var topic: String?
    public var visibility: MPRoomVisibility?

    enum CodingKeys: String, CodingKey {
        case creationContent
        case initialState
        case invite
        case invite3pid = "invite_3pid"
        case isDirect
        case name
        case powerLevelContentOverride
        case preset
        case roomAliasName
        case roomVersion
        case topic
        case visibility
    }
}

extension MPClient: MPRoomAPI {
    public func upgradeRoom(roomId: String, newVersion: String) async throws -> String {
        struct RoomUpgrade: Encodable {
            var newVersion: String
        }
        struct RoomUpgradeResult: Decodable {
            var replacementRoom: String
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/upgrade"
        let room = RoomUpgrade(newVersion: newVersion)
        let result: RoomUpgradeResult = try await self.send(.post(path.encoded, body: room)).value
        return result.replacementRoom
    }

    public func createRoom(room: MPRoomCreationRequest) async throws -> String {
        struct RoomCreationResult: Decodable {
            var roomId: String
        }

        let path: SafePath = "_matrix/client/v3/createRoom"
        let result: RoomCreationResult = try await self.send(.post(path.encoded, body: room)).value
        return result.roomId
    }

    public func getJoinedRooms() async throws -> [String] {
        struct JoinedRooms: Decodable {
            var joinedRooms: [String]
        }

        let path: SafePath = "_matrix/client/v3/joined_rooms"
        let rooms: JoinedRooms = try await self.send(.get(path.encoded)).value
        return rooms.joinedRooms
    }

    public func getPublicRooms(
        limit: Int? = nil, server: String? = nil, since: MPPaginationToken? = nil
    ) async throws -> MPPublicRoomStream {
        MPPublicRoomStream(client: self, mode: .normal, limit: limit, server: server, since: since)
    }

    public func getPublicRooms(
        genericSearchTerm: String? = nil, includeAllNetworks: Bool? = nil,
        thirdPartyInstanceId: String? = nil, limit: Int? = nil, server: String? = nil,
        since: MPPaginationToken? = nil
    ) async throws -> MPPublicRoomStream {
        MPPublicRoomStream(
            client: self,
            mode: .filtered(
                genericSearchTerm: genericSearchTerm, includeAllNetworks: includeAllNetworks,
                thirdPartyInstanceId: thirdPartyInstanceId), limit: limit, server: server,
            since: since)
    }

    public func setReadMarker(roomId: String, fullyRead: String, read: String? = nil) async throws {
        struct Marker: Encodable {
            var fullyRead: String
            var read: String?

            enum CodingKeys: String, CodingKey {
                case fullyRead = "m.fully_read"
                case read = "m.read"
            }
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/read_markers"
        let marker = Marker(fullyRead: fullyRead, read: read)
        try await self.send(.post(path.encoded, body: marker)).value
    }

    public func getRoomVisibility(roomId: String) async throws -> MPRoomVisibility {
        struct RoomVisibility: Decodable {
            var visibility: MPRoomVisibility
        }

        let path: SafePath = "_matrix/client/v3/directory/list/room/\(roomId)"
        let room: RoomVisibility = try await self.send(.get(path.encoded)).value
        return room.visibility
    }

    public func setRoomVisibility(roomId: String, visibility: MPRoomVisibility) async throws {
        struct RoomVisibility: Encodable {
            var visibility: MPRoomVisibility
        }

        let path: SafePath = "_matrix/client/v3/directory/list/room/\(roomId)"
        let room = RoomVisibility(visibility: visibility)
        try await self.send(.put(path.encoded, body: room)).value
    }

    public func createRoomAlias(roomAlias: String, roomId: String) async throws {
        struct RoomAliases: Encodable {
            var roomId: String
        }

        let path: SafePath = "_matrix/client/v3/directory/room/\(roomAlias)"
        try await self.send(.put(path.encoded, body: RoomAliases(roomId: roomId))).value
    }

    public func removeRoomAlias(roomAlias: String) async throws {
        let path: SafePath = "_matrix/client/v3/directory/room/\(roomAlias)"
        try await self.send(.delete(path.encoded)).value
    }

    public func resolveRoomAlias(roomAlias: String) async throws -> MPRoomIdState {
        let path: SafePath = "_matrix/client/v3/directory/room/\(roomAlias)"
        return try await self.send(.get(path.encoded)).value
    }

    public func getLocalRoomAliases(roomId: String) async throws -> [String] {
        struct LocalRoomAliases: Decodable {
            var aliases: [String]
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/aliases"
        let list: LocalRoomAliases = try await self.send(.get(path.encoded)).value
        return list.aliases
    }

    public func getJoinedUsers(roomId: String) async throws -> [MPUser] {
        struct JoinedUser: Decodable {
            var avatarUrl: URL?
            var displayName: String?
        }

        struct JoinedUserList: Decodable {
            var joined: [String: JoinedUser]
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/joined_members"
        let list: JoinedUserList = try await self.send(.get(path.encoded)).value
        return list.joined.map { (key, user) in
            MPUser(avatarUrl: user.avatarUrl, displayName: user.displayName, userId: key)
        }
    }

    public func getRoomMembers(
        roomId: String, at: String? = nil, membership: [MPRoomMembership]? = nil,
        notMembership: [MPRoomMembership]? = nil
    ) async throws -> [MPStateEvent] {
        struct Response: Decodable {
            var chunk: [MPStateEvent]
        }

        var query: [(String, String?)] = []
        if let at = at {
            query.append(("at", at))
        }
        if let membership = membership {
            query.append(("membership", membership.map { $0.rawValue }.joined(separator: "m")))
        }
        if let notMembership = notMembership {
            query.append(
                ("not_membership", notMembership.map { $0.rawValue }.joined(separator: "m")))
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/members"
        let response: Response = try await self.send(.get(path.encoded, query: query)).value
        return response.chunk
    }

    public func joinRoom(
        roomIdOrAlias: String, serverName: [String]? = nil,
        request: MPRoomParticipationRequest? = nil
    ) async throws -> String {
        struct Response: Decodable {
            var roomId: String
        }

        var query: [(String, String?)] = []
        if let serverName = serverName {
            query.append(("server_name", serverName.joined(separator: ",")))
        }

        let path: SafePath = "_matrix/client/v3/join/\(roomIdOrAlias)"
        let response: Response =
            try await self.send(
                .post(path.encoded, query: query, body: request ?? MPRoomParticipationRequest())
            )
            .value
        return response.roomId
    }

    public func joinRoom(roomId: String, request: MPRoomParticipationRequest? = nil) async throws
        -> String
    {
        struct Response: Decodable {
            var roomId: String
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/join"
        let response: Response =
            try await self.send(.post(path.encoded, body: request ?? MPRoomParticipationRequest()))
            .value
        return response.roomId
    }

    public func inviteUser(roomId: String, userId: String, reason: String? = nil) async throws {
        struct Invitation: Encodable {
            var reason: String?
            var userId: String
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/invite"
        let invitation = Invitation(reason: reason, userId: userId)
        try await self.send(.post(path.encoded, body: invitation))
    }

    public func inviteUser(roomId: String, invite: MPRoomInvite3pid) async throws {
        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/invite"
        try await self.send(.post(path.encoded, body: invite))
    }

    public func banUser(roomId: String, userId: String, reason: String? = nil) async throws {
        struct Ban: Encodable {
            var reason: String?
            var userId: String
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/ban"
        let ban = Ban(reason: reason, userId: userId)
        try await self.send(.post(path.encoded, body: ban))
    }

    public func unbanUser(roomId: String, userId: String, reason: String? = nil) async throws {
        struct Ban: Encodable {
            var reason: String?
            var userId: String
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/unban"
        let ban = Ban(reason: reason, userId: userId)
        try await self.send(.post(path.encoded, body: ban))
    }

    public func kickUser(roomId: String, userId: String, reason: String? = nil) async throws {
        struct Kick: Encodable {
            var reason: String?
            var userId: String
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/kick"
        let kick = Kick(reason: reason, userId: userId)
        try await self.send(.post(path.encoded, body: kick))
    }

    public func forgetRoom(roomId: String) async throws {
        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/forget"
        try await self.send(.post(path.encoded))
    }

    public func knockRoom(roomIdOrAlias: String, serverName: [String]? = nil, reason: String? = nil)
        async throws
    {
        let path: SafePath = "_matrix/client/v3/knock/\(roomIdOrAlias)"
        struct Reason: Encodable {
            var reason: String?
        }
        var query: [(String, String?)] = []
        if let serverName = serverName {
            query.append(("server_name", serverName.joined(separator: ",")))
        }
        let reason = Reason(reason: reason)
        try await self.send(.post(path.encoded, query: query, body: reason))
    }

    public func leaveRoom(roomId: String, reason: String? = nil) async throws {
        struct Reason: Encodable {
            var reason: String?
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/leave"
        let reason = Reason(reason: reason)
        try await self.send(.post(path.encoded, body: reason))
    }
}

struct EventIDResponse: Decodable {
    public var eventId: String
}

public enum MPPaginationToken {
    case forward(String)
    case backward(String)
}

public struct MPPublicRoomFilter: Encodable {
    public var filter: Filter?
    public var includeAllNetworks: Bool?
    public var limit: Int?
    public var since: String?
    public var thirdPartyInstanceId: String?

    public struct Filter: Encodable {
        public var genericSearchTerm: String?
    }
}

public struct MPPublicRoom: Decodable {
    public var aliases: [String]?
    public var avatarUrl: URL?
    public var canonicalAlias: String?
    public var guestCanJoin: Bool
    public var joinRule: String?
    public var name: String?
    public var numJoinedMembers: Int
    public var roomId: String
    public var topic: String?
    public var worldReadable: Bool
}

public struct MPPublicRoomStream: AsyncSequence {
    public typealias Element = [MPPublicRoom]

    private let client: MPClient
    private let mode: Mode
    private let limit: Int?
    private let server: String?
    private let since: MPPaginationToken?

    public struct AsyncIterator: AsyncIteratorProtocol {
        let client: MPClient
        let mode: Mode
        let limit: Int?
        let server: String?
        let since: MPPaginationToken?
        public private(set) var current: MPPaginationToken?
        public private(set) var nextBatch: MPPaginationToken?
        public private(set) var prevBatch: MPPaginationToken?
        public private(set) var totalRoomCountEstimate: Int?
        var eos: Bool = false

        private struct Page: Decodable {
            let chunk: [MPPublicRoom]
            let nextBatch: String?
            let prevBatch: String?
            let totalRoomCountEstimate: Int?
        }

        struct QueryBody: Encodable {
            var filter: Filter?
            var includeAllNetworks: Bool?
            var limit: Int?
            var since: String?
            var thirdPartyInstanceId: String?

            struct Filter: Encodable {
                var genericSearchTerm: String
            }
        }

        mutating public func next() async throws -> [MPPublicRoom]? {
            if eos {
                return nil
            }
            if current == nil {
                current = since
            }

            var query: [(String, String?)] = []
            if let server = server {
                query.append(("server", "\(server)"))
            }

            var since: String?
            if let current = current {
                switch current {
                case .forward(let current):
                    since = current
                case .backward(let current):
                    since = current
                }
            }

            let path: SafePath = "_matrix/client/v3/publicRooms"
            let page: Page

            switch mode {
            case .normal:
                if let limit = limit {
                    query.append(("limit", "\(limit)"))
                }
                if let since = since {
                    query.append(("since", "\(since)"))
                }
                page = try await client.send(.get(path.encoded, query: query)).value

            case .filtered(let genericSearchTerm, let includeAllNetworks, let thirdPartyInstanceId):
                let body = QueryBody(
                    filter: genericSearchTerm.map { QueryBody.Filter(genericSearchTerm: $0) },
                    includeAllNetworks: includeAllNetworks,
                    limit: limit,
                    since: since,
                    thirdPartyInstanceId: thirdPartyInstanceId)

                page = try await client.send(.post(path.encoded, query: query, body: body)).value
            }

            nextBatch = page.nextBatch.map { .forward($0) }
            prevBatch = page.prevBatch.map { .backward($0) }
            totalRoomCountEstimate = page.totalRoomCountEstimate

            if let currentDirection = current {
                switch currentDirection {
                case .forward:
                    current = nextBatch
                case .backward:
                    current = prevBatch
                }
            }
            else {
                current = nextBatch
            }
            if current == nil {
                eos = true
            }

            return page.chunk
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(client: client, mode: mode, limit: limit, server: server, since: since)
    }

    init(client: MPClient, mode: Mode, limit: Int?, server: String?, since: MPPaginationToken?) {
        self.client = client
        self.mode = mode
        self.limit = limit
        self.server = server
        self.since = since
    }

    enum Mode {
        case normal
        case filtered(
            genericSearchTerm: String?, includeAllNetworks: Bool?, thirdPartyInstanceId: String?)
    }
}
