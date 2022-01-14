import Foundation
import Get
import SwiftyJSON

typealias RequestMapper<T> = (RESTClient, AnyEncodable) async throws -> T

public struct MPInteractiveAuthSession<T> {
    private let client: RESTClient
    private let body: AnyEncodable
    private let mapper: RequestMapper<T>

    init<Body: Encodable>(client: RESTClient, body: Body, mapper: @escaping RequestMapper<T>) {
        self.client = client
        self.body = AnyEncodable(body)
        self.mapper = mapper
    }

    public func authenticate<A: MPAuthMethod>(method: A, state: MPInteractiveAuthState) async throws
        -> Result<T, MPInteractiveAuthState>
    {
        let session = InteractiveAuthSession(method: method, session: state.session)
        return try await self.authenticate(session: session)
    }

    public func authenticate() async throws -> Result<T, MPInteractiveAuthState> {
        let session = InteractiveAuthSession(method: [String: String](), session: nil)
        return try await self.authenticate(session: session)
    }

    private func authenticate<A: Encodable>(session: InteractiveAuthSession<A>) async throws
        -> Result<T, MPInteractiveAuthState>
    {
        let auth = InteractiveAuth(auth: session, data: self.body)
        do {
            let result: T = try await self.mapper(self.client, AnyEncodable(auth))
            return .success(result)
        }
        catch let state as MPInteractiveAuthState {
            return .failure(state)
        }
    }
}

public struct MPInteractiveAuthState: Decodable, Error {
    public var errcode: String?
    public var error: String?
    public var completed: [String]?
    public var flows: [Stages]
    public var params: JSON?
    public var session: String?

    public struct Stages: Decodable {
        public var stages: [String]
    }
}

private struct InteractiveAuthSession<T: Encodable> {
    public var method: T
    public var session: String?

    enum CodingKeys: String, CodingKey {
        case session
    }
}

extension InteractiveAuthSession: Encodable {
    public func encode(to encoder: Encoder) throws {
        try method.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let session = session {
            try container.encode(session, forKey: .session)
        }
    }
}

private struct InteractiveAuth<T: Encodable> {
    public var auth: InteractiveAuthSession<T>
    public var data: Encodable

    enum CodingKeys: String, CodingKey {
        case auth
    }
}

extension InteractiveAuth: Encodable {
    public func encode(to encoder: Encoder) throws {
        try data.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(auth, forKey: .auth)
    }
}
