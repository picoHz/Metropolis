import Foundation
import SwiftyJSON

public protocol MPSearchAPI {
    /// Searches the user directory.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3user_directorysearch) for
    /// more informataion.
    func searchUserDirectory(searchTerm: String, limit: Int?, acceptLanguage: String?) async throws
        -> MPUserDirectorySearchResponse

    /// Perform a server-side search.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3search) for
    /// more informataion.
    func searchFullText(searchQuery: MPFullTextSearchQuery, nextBatch: String?)
        -> MPFullTextSearchStream
}

public struct MPUser: Decodable {
    public var avatarUrl: URL?
    public var displayName: String?
    public var userId: String
}

public struct MPUserDirectorySearchResponse: Decodable {
    public var limited: Bool
    public var results: [MPUser]
}

public struct MPFullTextSearchQuery {
    public var roomEvents: RoomEvents?

    public struct RoomEvents: Encodable {
        public var eventContext: EventContext?
        public var filter: MPFilter.RoomEventFilter?
        public var groupings: Groupings?
        public var includeState: Bool?
        public var keys: [Key]?
        public var orderBy: OrderBy?
        public var searchTerm: String

        public struct EventContext: Encodable {
            public var afterLimit: Int?
            public var beforeLimit: Int?
            public var includeProfile: Bool?
        }

        public struct Groupings: Encodable {
            public var groupBy: [GroupBy]?

            public struct GroupBy: Encodable {
                public var key: Key?

                public enum Key: String, Encodable {
                    case roomId
                    case sender
                }
            }
        }

        public enum Key: String, Encodable {
            case body = "content.body"
            case name = "content.name"
            case topic = "content.topic"
        }

        public enum OrderBy: String, Encodable {
            case recent
            case rank
        }

    }

    enum CodingKeys: String, CodingKey {
        case searchCategories
        case roomEvents
    }
}

extension MPFullTextSearchQuery: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var searchCategories = container.nestedContainer(
            keyedBy: CodingKeys.self, forKey: .searchCategories)
        if let roomEvents = roomEvents {
            try searchCategories.encode(roomEvents, forKey: .roomEvents)
        }
    }
}

public struct MPFullTextSearchResult {
    public var roomEvents: RoomEvents?

    public struct RoomEvents: Decodable {
        public var count: Int?
        public var groups: [String: [String: Group]]?
        public var highlights: [String]?
        public var nextBatch: String?
        public var results: [Result]?
        public var state: [String: MPStateEvent]?

        public struct Group: Decodable {
            public var nextBatch: String?
            public var order: Int?
            public var results: [String]?
        }

        public struct Result: Decodable {
            public var context: Context?
            public var rank: Int?
            public var result: JSON?
        }

        public struct Context: Decodable {
            public var end: String?
            public var eventsAfter: JSON?
            public var eventsBefore: JSON?
            public var profileInfo: [String: UserProfile]?
            public var start: String?
        }

        public struct UserProfile: Decodable {
            public var avatarUrl: URL?
            public var displayName: String?
        }
    }

    enum CodingKeys: String, CodingKey {
        case searchCategories
        case roomEvents
    }
}

extension MPFullTextSearchResult: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let searchCategories = try container.nestedContainer(
            keyedBy: CodingKeys.self, forKey: .searchCategories)
        self.roomEvents = try searchCategories.decode(RoomEvents.self, forKey: .roomEvents)
    }
}

extension MPClient: MPSearchAPI {
    public func searchUserDirectory(
        searchTerm: String, limit: Int? = nil, acceptLanguage: String? = nil
    ) async throws -> MPUserDirectorySearchResponse {
        struct Query: Encodable {
            var limit: Int?
            var searchTerm: String
        }

        let path: SafePath = "_matrix/client/v3/user_directory/search"
        var headers: [String: String] = [:]
        if let acceptLanguage = acceptLanguage {
            headers["Accept-Language"] = acceptLanguage
        }
        let query = Query(limit: limit, searchTerm: searchTerm)
        return try await self.send(.post(path.encoded, body: query, headers: headers)).value
    }

    public func searchFullText(searchQuery: MPFullTextSearchQuery, nextBatch: String? = nil)
        -> MPFullTextSearchStream
    {
        MPFullTextSearchStream(client: self, saerchQuery: searchQuery, nextBatch: nextBatch)
    }
}

public struct MPFullTextSearchStream: AsyncSequence {
    public typealias Element = MPFullTextSearchResult
    private let client: MPClient
    private let saerchQuery: MPFullTextSearchQuery
    private let nextBatch: String?

    public struct AsyncIterator: AsyncIteratorProtocol {
        let client: MPClient
        var saerchQuery: MPFullTextSearchQuery
        var nextBatch: String?
        var eos: Bool = false

        mutating public func next() async throws -> MPFullTextSearchResult? {
            if eos {
                return nil
            }

            let path: SafePath = "_matrix/client/v3/search"

            var query: [(String, String?)] = []
            if let nextBatch = nextBatch {
                query.append(("next_batch", nextBatch))
            }

            let result: MPFullTextSearchResult =
                try await client.send(.post(path.encoded, query: query, body: saerchQuery)).value
            nextBatch = result.roomEvents?.nextBatch

            if nextBatch == nil {
                eos = true
            }

            return result
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(client: client, saerchQuery: saerchQuery, nextBatch: nextBatch)
    }

    init(client: MPClient, saerchQuery: MPFullTextSearchQuery, nextBatch: String?) {
        self.client = client
        self.saerchQuery = saerchQuery
        self.nextBatch = nextBatch
    }
}
