import Foundation

public protocol MPFilterAPI {
    /// Upload a new filter.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3useruseridfilter) for
    /// more informataion.
    func uploadFilter(userId: String, filter: MPFilter) async throws -> String

    /// Download a filter.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3useruseridfilterfilterid) for
    /// more informataion.
    func downloadFilter(userId: String, filterId: String) async throws -> MPFilter
}

public struct MPFilter: Codable, Equatable {
    public var accountData: EventFilter?
    public var eventFields: [String]?
    public var eventFormat: EventFormat?
    public var presence: EventFilter?
    public var room: RoomFilter?

    public enum EventFormat: String, Codable {
        case client
        case federation
    }

    public struct EventFilter: Codable, Equatable {
        public var limit: Int?
        public var notSenders: [String]?
        public var notTypes: [String]?
        public var senders: [String]?
        public var types: [String]?
    }

    public struct RoomFilter: Codable, Equatable {
        public var accountData: RoomEventFilter?
        public var ephemeral: RoomEventFilter?
        public var includeLeave: Bool?
        public var notRooms: [String]?
        public var rooms: [String]?
        public var state: StateFilter?
        public var timeline: RoomEventFilter?
    }

    public struct RoomEventFilter: Codable, Equatable {
        public var containsUrl: Bool?
        public var includeRedundantMembers: Bool?
        public var lazyLoadMembers: Bool?
        public var limit: Int?
        public var notRooms: [String]?
        public var notSenders: [String]?
        public var notTypes: [String]?
        public var rooms: [String]?
        public var senders: [String]?
        public var types: [String]?
    }

    public struct StateFilter: Codable, Equatable {
        public var containsUrl: Bool?
        public var includeRedundantMembers: Bool?
        public var lazyLoadMembers: Bool?
        public var limit: Int?
        public var notRooms: [String]?
        public var notSenders: [String]?
        public var notTypes: [String]?
        public var rooms: [String]?
        public var senders: [String]?
        public var types: [String]?
    }
}

extension MPClient: MPFilterAPI {
    public func uploadFilter(userId: String, filter: MPFilter) async throws -> String {
        struct Response: Decodable {
            var filterId: String
        }

        let path: SafePath = "_matrix/client/v3/user/\(userId)/filter"
        let response: Response = try await self.send(.post(path.encoded, body: filter)).value
        return response.filterId
    }

    public func downloadFilter(userId: String, filterId: String) async throws -> MPFilter {
        let path: SafePath = "_matrix/client/v3/user/\(userId)/filter/\(filterId)"
        return try await self.send(.get(path.encoded)).value
    }
}
