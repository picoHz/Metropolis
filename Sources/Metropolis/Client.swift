import Foundation
import Get

public struct MPClient {
    let client: RESTClient
    public let deviceId: String?
    public let userId: String?

    init(client: RESTClient, deviceId: String? = nil, userId: String? = nil) {
        self.client = client
        self.deviceId = deviceId
        self.userId = userId
    }

    public init(url: URL) throws {
        self.client = try RESTClient(baseUrl: url, accessToken: nil)
        self.deviceId = nil
        self.userId = nil
    }

    func send<T: Decodable>(_ request: Request<T>) async throws -> Response<T> {
        return try await self.client.send(request)
    }

    @discardableResult func send(_ request: Request<Void>) async throws -> Response<Void> {
        try await self.client.send(request)
    }

    func startInteractiveAuth<T: Decodable>(_ mapper: @escaping RequestMapper<T>)
        -> MPInteractiveAuthSession<T>
    {
        MPInteractiveAuthSession<T>(
            client: self.client, body: [String: String](), mapper: mapper)
    }

    func startInteractiveAuth<Body: Encodable, T: Decodable>(
        body: Body, _ mapper: @escaping RequestMapper<T>
    ) -> MPInteractiveAuthSession<T> {
        MPInteractiveAuthSession<T>(client: self.client, body: body, mapper: mapper)
    }

    func startInteractiveAuth(_ mapper: @escaping RequestMapper<Void>) -> MPInteractiveAuthSession<
        Void
    > {
        MPInteractiveAuthSession<Void>(
            client: self.client, body: [String: String](), mapper: mapper)
    }

    func startInteractiveAuth<Body: Encodable>(body: Body, _ mapper: @escaping RequestMapper<Void>)
        -> MPInteractiveAuthSession<Void>
    {
        MPInteractiveAuthSession<Void>(client: self.client, body: body, mapper: mapper)
    }
}
