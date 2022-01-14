import Foundation

public protocol MPMediaAPI {
    /// Get the configuration for the content repository.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixmediav3config) for
    /// more informataion.
    func getMediaConfig() async throws -> MPMadiaConfig

    func getMediaDownloadUrl(serverName: String, mediaId: String) -> URL
    func getMediaThumbnailUrl(serverName: String, mediaId: String) -> URL
    func getMediaUploadUrl() -> URL
}

public struct MPMadiaConfig: Decodable {
    public var uploadSize: Int?

    enum CodingKeys: String, CodingKey {
        case uploadSize = "m.upload.size"
    }
}

extension MPClient: MPMediaAPI {
    public func getMediaConfig() async throws -> MPMadiaConfig {
        let path: SafePath = "_matrix/media/v3/config"
        return try await self.send(.get(path.encoded)).value
    }

    public func getMediaDownloadUrl(serverName: String, mediaId: String) -> URL {
        return self.client.baseUrl.appendingPathComponent(
            "_matrix/media/v3/download/\(serverName)/\(mediaId)")
    }

    public func getMediaThumbnailUrl(serverName: String, mediaId: String) -> URL {
        return self.client.baseUrl.appendingPathComponent(
            "_matrix/media/v3/thumbnail/\(serverName)/\(mediaId)")
    }

    public func getMediaUploadUrl() -> URL {
        var url = URLComponents(
            url: self.client.baseUrl.appendingPathComponent("_matrix/media/v3/upload/"),
            resolvingAgainstBaseURL: false)!
        if let accessToken = self.client.accessToken {
            url.queryItems = [URLQueryItem(name: "access_token", value: accessToken)]
        }
        return url.url!
    }
}
