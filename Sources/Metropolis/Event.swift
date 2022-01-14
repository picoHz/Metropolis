import Foundation
import SwiftyJSON

public protocol MPEventAPI {
    /// Synchronise the client's state and receive new messages.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3sync) for
    /// more informataion.
    func sync(since: String?, fullState: Bool?, setPresence: MPUserPresenceKind?, timeout: Int?)
        async -> MPEventStream

    /// Synchronise the client's state and receive new messages.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3sync) for
    /// more informataion.
    func sync(
        filter: MPFilter, since: String?, fullState: Bool?, setPresence: MPUserPresenceKind?,
        timeout: Int?
    ) async throws -> MPEventStream

    /// Synchronise the client's state and receive new messages.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3sync) for
    /// more informataion.
    func sync(
        filterId: String, since: String?, fullState: Bool?, setPresence: MPUserPresenceKind?,
        timeout: Int?
    ) async -> MPEventStream

    /// Send a state event to the given room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3roomsroomidstateeventtypestatekey) for
    /// more informataion.
    func sendStateEvent<Event: Encodable>(
        roomId: String, eventType: String, event: Event, stateKey: String?
    ) async throws -> String

    /// Send a state event to the given room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3roomsroomidsendeventtypetxnid) for
    /// more informataion.
    func sendMessageEvent<Event: Encodable>(
        roomId: String, eventType: String, event: Event, txnId: String
    ) async throws -> String

    /// Informs the server that the user has started or stopped typing.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3roomsroomidtypinguserid) for
    /// more informataion.
    func informTyping(roomId: String, userId: String, typing: Bool, timeout: Int?) async throws

    /// Send a receipt for the given event ID.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidreceiptreceipttypeeventid) for
    /// more informataion.
    func sendReceipt(roomId: String, receiptType: String, eventId: String) async throws

    /// Get a single event by event ID.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomideventeventid) for
    /// more informataion.
    func getRoomEvent(roomId: String, eventId: String) async throws -> MPRoomEvent

    /// Get a list of events for this room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidmessages) for
    /// more informataion.
    func getRoomEvents(
        roomId: String, from: String, to: String?, dir: MPEventDirection, limit: Int?
    ) -> MPRoomEventStream

    /// Get a list of events for this room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidmessages) for
    /// more informataion.
    func getRoomEvents(
        roomId: String, from: String, to: String?, dir: MPEventDirection, limit: Int?,
        filterId: String
    ) -> MPRoomEventStream

    /// Get a list of events for this room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidmessages) for
    /// more informataion.
    func getRoomEvents(
        roomId: String, from: String, to: String?, dir: MPEventDirection, limit: Int?,
        filter: MPFilter
    ) throws -> MPRoomEventStream

    /// Listen on the event stream of a particular room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidmessages) for
    /// more informataion.
    func listenRoomEvents(from: String?, roomId: String?, timeout: Int?)
        -> MPListenedRoomEventStream

    /// Get the state identified by the type and key.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidstateeventtypestatekey) for
    /// more informataion.
    func getStateFromTypeAndKey(roomId: String, eventType: String, stateKey: String) async throws
        -> JSON

    /// Get events and state around the specified event.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidcontexteventid) for
    /// more informataion.
    func getEventContext(roomId: String, eventId: String, limit: Int?) async throws
        -> MPEventContext

    /// Get events and state around the specified event.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidcontexteventid) for
    /// more informataion.
    func getEventContext(roomId: String, eventId: String, filterId: String, limit: Int?)
        async throws -> MPEventContext

    /// Get events and state around the specified event.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidcontexteventid) for
    /// more informataion.
    func getEventContext(roomId: String, eventId: String, filter: MPFilter, limit: Int?)
        async throws -> MPEventContext

    /// Get all state events in the current state of a room.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3roomsroomidstate) for
    /// more informataion.
    func getStateEvents(roomId: String) async throws -> [MPStateEvent]

    /// Reports an event as inappropriate.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3roomsroomidreporteventid) for
    /// more informataion.
    func reportEvent(roomId: String, eventId: String, reason: String?, score: Int?) async throws

    /// Strips all non-integrity-critical information out of an event.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3roomsroomidredacteventidtxnid) for
    /// more informataion.
    func redactEvent(roomId: String, eventId: String, reason: String, txnId: String) async throws
        -> String
}

public struct MPRoomEvent: Decodable {
    public var content: JSON
    public var type: String
    public var eventId: String
    public var originServerTs: Int
    public var sender: String
    public var unsigned: MPEventUnsignedData?
}

public struct MPStateEvent: Decodable {
    public var content: JSON
    public var eventId: String
    public var originServerTs: Int
    public var prevContent: JSON?
    public var sender: String
    public var stateKey: String
    public var type: String
    public var unsigned: MPEventUnsignedData?
}

public struct MPEventUnsignedData: Decodable {
    public var age: Int?
    public var redactedBecause: JSON?
    public var transactionId: String?
    public var prevContent: JSON?
    public var inviteRoomState: MPStrippedState?
    public var knockRoomState: MPStrippedState?
}

public struct MPEventContext: Decodable {
    public var start: String?
    public var end: String?
    public var event: MPRoomEvent?
    public var eventsBefore: [MPRoomEvent]?
    public var eventsAfter: [MPRoomEvent]?
    public var state: [MPStateEvent]?
}

public enum MPEventDirection: String {
    case backward = "b"
    case forward = "f"
}

public struct MPSyncEvents: Decodable {
    public var nextBatch: String
    public var rooms: Rooms?

    public struct Rooms: Decodable {
        public var invite: [String: Invited]?
        public var join: [String: Joined]?
        public var knock: [String: Knocked]?
        public var leave: [String: Left]?

        public struct Timeline: Decodable {
            public var events: [MPRoomEvent]?
            public var limited: Bool?
            public var nextBatch: String?
        }

        public struct Invited: Decodable {
            public var inviteState: State?

            public struct State: Decodable {
                public var events: [MPStrippedState]?
            }
        }

        public struct Joined: Decodable {
            public var accountData: JSON?
            public var ephemeral: Ephemeral?
            public var state: State?
            public var summary: Summary?
            public var timeline: Timeline?
            public var unreadNotifications: UnreadNotificationCounts?

            public struct Ephemeral: Decodable {
                public var events: [JSON]?
            }

            public struct State: Decodable {
                public var events: [MPStateEvent]?
            }

            public struct Summary: Decodable {
                public var heroes: [String]?
                public var invitedMemberCount: Int?
                public var joinedMemberCount: Int?

                enum CodingKeys: String, CodingKey {
                    case heroes = "m.heroes"
                    case invitedMemberCount = "m.invited_member_count"
                    case joinedMemberCount = "m.joined_member_count"
                }
            }

            public struct UnreadNotificationCounts: Decodable {
                public var highlightCount: Int?
                public var notificationCount: Int?
            }
        }

        public struct Knocked: Decodable {
            public var knockState: State?

            public struct State: Decodable {
                public var events: [MPStrippedState]?
            }
        }

        public struct Left: Decodable {
            public var accountData: JSON?
            public var state: State?
            public var timeline: Timeline?

            public struct State: Decodable {
                public var events: [MPStateEvent]?
            }
        }
    }
}

public struct MPStrippedState: Decodable {
    public var content: JSON
    public var sender: String
    public var stateKey: String
    public var type: String
}

struct SyncRequest {
    var filter: String?
    var since: String?
    var fullState: Bool?
    var setPresence: MPUserPresenceKind?
    var timeout: Int?
}

public struct MPEventStream: AsyncSequence {
    public typealias Element = MPSyncEvents
    private let client: MPClient
    private let request: SyncRequest

    public struct AsyncIterator: AsyncIteratorProtocol {
        let client: MPClient
        var request: SyncRequest

        mutating public func next() async throws -> MPSyncEvents? {
            let path: SafePath = "_matrix/client/v3/sync"
            var query: [(String, String?)] = []
            if let since = request.since {
                query.append(("since", since))
            }
            let events: MPSyncEvents = try await client.send(.get(path.encoded, query: query)).value
            request.since = events.nextBatch
            if events.rooms == nil {
                return nil
            }
            return events
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(client: client, request: request)
    }

    init(client: MPClient, request: SyncRequest) {
        self.client = client
        self.request = request
    }
}

struct RoomEventRequest {
    var roomId: String
    var from: String
    var to: String?
    var dir: MPEventDirection
    var limit: Int?
    var filter: String?
}

public struct MPRoomEventStream: AsyncSequence {
    public typealias Element = MPEventContext
    private let client: MPClient
    private let request: RoomEventRequest

    public struct AsyncIterator: AsyncIteratorProtocol {
        let client: MPClient
        var request: RoomEventRequest
        var eos: Bool = false

        mutating public func next() async throws -> MPEventContext? {
            if eos {
                return nil
            }

            let path: SafePath = "_matrix/client/v3/rooms/\(request.roomId)/messages"
            var query: [(String, String?)] = [
                ("from", request.from),
                ("dir", request.dir.rawValue),
            ]
            if let to = request.to {
                query.append(("to", to))
            }
            if let limit = request.limit {
                query.append(("limit", "\(limit)"))
            }
            if let filter = request.filter {
                query.append(("filter", "\(filter)"))
            }

            let events: MPEventContext = try await client.send(.get(path.encoded, query: query))
                .value
            if let end = events.end {
                request.from = end
            }
            else {
                eos = true
            }
            return events
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(client: client, request: request)
    }

    init(client: MPClient, request: RoomEventRequest) {
        self.client = client
        self.request = request
    }
}

public struct MPListenedRoomEventStream: AsyncSequence {
    public typealias Element = [MPRoomEvent]
    private let client: MPClient
    private let request: Request

    public struct AsyncIterator: AsyncIteratorProtocol {
        let client: MPClient
        var request: Request
        public var start: String?
        public var end: String?
        var eos: Bool = false

        mutating public func next() async throws -> [MPRoomEvent]? {
            if eos {
                return nil
            }

            let path: SafePath = "_matrix/client/v3/events"
            var query: [(String, String?)] = []
            if let from = request.from {
                query.append(("from", "\(from)"))
            }
            if let timeout = request.timeout {
                query.append(("timeout", "\(timeout)"))
            }
            if let roomId = request.roomId {
                query.append(("room_id", "\(roomId)"))
            }

            let response: Response = try await client.send(.get(path.encoded, query: query)).value
            start = response.start
            end = response.end

            if let end = end {
                request.from = end
            }
            else {
                eos = true
            }

            return response.chunk
        }
    }

    struct Request {
        var from: String?
        var timeout: Int?
        var roomId: String?
    }

    struct Response: Decodable {
        var chunk: [MPRoomEvent]?
        var end: String?
        var start: String?
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(client: client, request: request)
    }

    init(client: MPClient, request: Request) {
        self.client = client
        self.request = request
    }
}

extension MPClient: MPEventAPI {
    public func sync(
        since: String? = nil, fullState: Bool? = nil, setPresence: MPUserPresenceKind? = nil,
        timeout: Int? = nil
    ) async -> MPEventStream {
        return MPEventStream(
            client: self,
            request: SyncRequest(
                since: since, fullState: fullState, setPresence: setPresence, timeout: timeout))
    }

    public func sync(
        filter: MPFilter, since: String? = nil, fullState: Bool? = nil,
        setPresence: MPUserPresenceKind? = nil, timeout: Int? = nil
    ) async throws -> MPEventStream {
        let filterJson = String(data: try sharedJSONEncoder.encode(filter), encoding: .utf8)
        return MPEventStream(
            client: self,
            request: SyncRequest(
                filter: filterJson, since: since, fullState: fullState, setPresence: setPresence,
                timeout: timeout))
    }

    public func sync(
        filterId: String, since: String? = nil, fullState: Bool? = nil,
        setPresence: MPUserPresenceKind? = nil, timeout: Int? = nil
    ) async -> MPEventStream {
        return MPEventStream(
            client: self,
            request: SyncRequest(
                filter: filterId, since: since, fullState: fullState, setPresence: setPresence,
                timeout: timeout))
    }

    public func sendStateEvent<Event: Encodable>(
        roomId: String, eventType: String, event: Event, stateKey: String? = nil
    ) async throws -> String {
        let path: SafePath =
            "_matrix/client/v3/rooms/\(roomId)/state/\(eventType)/\(stateKey ?? "")"
        let response: EventIDResponse = try await self.send(.put(path.encoded, body: event)).value
        return response.eventId
    }

    public func sendMessageEvent<Event: Encodable>(
        roomId: String, eventType: String, event: Event, txnId: String
    ) async throws -> String {
        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/send/\(eventType)/\(txnId)"
        let response: EventIDResponse = try await self.send(.put(path.encoded, body: event)).value
        return response.eventId
    }

    public func getRoomEvent(roomId: String, eventId: String) async throws -> MPRoomEvent {
        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/event/\(eventId)"
        return try await self.send(.get(path.encoded)).value
    }

    public func getRoomEvents(
        roomId: String, from: String, to: String? = nil, dir: MPEventDirection, limit: Int? = nil
    ) -> MPRoomEventStream {
        MPRoomEventStream(
            client: self,
            request: RoomEventRequest(
                roomId: roomId, from: from, to: to, dir: dir, limit: limit, filter: nil))
    }

    public func getRoomEvents(
        roomId: String, from: String, to: String? = nil, dir: MPEventDirection, limit: Int? = nil,
        filterId: String
    ) -> MPRoomEventStream {
        MPRoomEventStream(
            client: self,
            request: RoomEventRequest(
                roomId: roomId, from: from, to: to, dir: dir, limit: limit, filter: filterId))
    }

    public func getRoomEvents(
        roomId: String, from: String, to: String? = nil, dir: MPEventDirection, limit: Int? = nil,
        filter: MPFilter
    ) throws -> MPRoomEventStream {
        let filterJson = String(data: try sharedJSONEncoder.encode(filter), encoding: .utf8)
        return MPRoomEventStream(
            client: self,
            request: RoomEventRequest(
                roomId: roomId, from: from, to: to, dir: dir, limit: limit, filter: filterJson))
    }

    public func listenRoomEvents(from: String?, roomId: String?, timeout: Int?)
        -> MPListenedRoomEventStream
    {
        MPListenedRoomEventStream(
            client: self,
            request: MPListenedRoomEventStream.Request(from: from, timeout: timeout, roomId: roomId)
        )
    }

    public func getStateFromTypeAndKey(roomId: String, eventType: String, stateKey: String)
        async throws -> JSON
    {
        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/state/\(eventType)/\(stateKey)"
        return try await self.send(.get(path.encoded)).value
    }

    public func getStateEvents(roomId: String) async throws -> [MPStateEvent] {
        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/state"
        return try await self.send(.get(path.encoded)).value
    }

    public func getEventContext(roomId: String, eventId: String, limit: Int? = nil) async throws
        -> MPEventContext
    {
        try await getEventContext(roomId: roomId, eventId: eventId, filter: nil, limit: limit)
    }

    public func getEventContext(
        roomId: String, eventId: String, filterId: String, limit: Int? = nil
    ) async throws -> MPEventContext {
        try await getEventContext(roomId: roomId, eventId: eventId, filter: filterId, limit: limit)
    }

    public func getEventContext(
        roomId: String, eventId: String, filter: MPFilter, limit: Int? = nil
    ) async throws -> MPEventContext {
        let filterJson = String(data: try sharedJSONEncoder.encode(filter), encoding: .utf8)
        return try await getEventContext(
            roomId: roomId, eventId: eventId, filter: filterJson, limit: limit)
    }

    func getEventContext(roomId: String, eventId: String, filter: String?, limit: Int?) async throws
        -> MPEventContext
    {
        var query: [(String, String?)] = []
        if let limit = limit {
            query.append(("limit", "\(limit)"))
        }
        if let filter = filter {
            query.append(("filter", "\(filter)"))
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/context/\(eventId)"
        return try await self.send(.get(path.encoded, query: query)).value
    }

    public func informTyping(roomId: String, userId: String, typing: Bool, timeout: Int? = nil)
        async throws
    {
        struct Typing: Encodable {
            var timeout: Int?
            var typing: Bool
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/typing/\(userId)"
        let typing = Typing(timeout: timeout, typing: typing)
        try await self.send(.put(path.encoded, body: typing))
    }

    public func sendReceipt(roomId: String, receiptType: String, eventId: String) async throws {
        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/receipt/\(receiptType)/\(eventId)"
        try await self.send(.post(path.encoded))
    }

    public func reportEvent(
        roomId: String, eventId: String, reason: String? = nil, score: Int? = nil
    ) async throws {
        struct ContentReport: Encodable {
            var reason: String?
            var score: Int?
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/report/\(eventId)"
        try await self.send(.post(path.encoded, body: ContentReport(reason: reason, score: score)))
    }

    public func redactEvent(roomId: String, eventId: String, reason: String, txnId: String)
        async throws -> String
    {
        struct Redaction: Encodable {
            var reason: String
        }

        let path: SafePath = "_matrix/client/v3/rooms/\(roomId)/redact/\(eventId)/\(txnId)"
        let response: EventIDResponse =
            try await self.send(.put(path.encoded, body: Redaction(reason: reason))).value
        return response.eventId
    }
}
