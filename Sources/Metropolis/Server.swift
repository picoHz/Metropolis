import Foundation
import SwiftyJSON

public protocol MPServerAPI {
    /// Gets the versions of the specification supported by the server.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientversions) for
    /// more informataion.
    func getServerVersions() async throws -> MPServerVersions

    /// Gets information about the server's capabilities.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3capabilities) for
    /// more informataion.
    func getCapabilities() async throws -> JSON

    /// Obtain TURN server credentials.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3voipturnserver) for
    /// more informataion.
    func getTURNServerCredentials() async throws -> MPTURNServerCredentials?
}

public struct MPServerVersions: Decodable {
    public var versions: [String]
    public var unstableFeatures: [String: Bool]?
}

public struct MPTURNServerCredentials: Decodable {
    public var password: String
    public var ttl: Int
    public var uris: [URL]
    public var username: String
}

extension MPClient: MPServerAPI {
    public func getServerVersions() async throws -> MPServerVersions {
        let path: SafePath = "_matrix/client/versions"
        return try await self.send(.get(path.encoded)).value
    }

    public func getCapabilities() async throws -> JSON {
        struct CapabilityList: Decodable {
            var capabilities: JSON
        }

        let path: SafePath = "_matrix/client/v3/capabilities"
        let caps: CapabilityList = try await self.client.send(.get(path.encoded)).value
        return caps.capabilities
    }

    public func getTURNServerCredentials() async throws -> MPTURNServerCredentials? {
        let path: SafePath = "_matrix/client/v3/voip/turnServer"
        let credentials: JSON = try await self.send(.get(path.encoded)).value
        return try? sharedJSONDecoder.decode(
            MPTURNServerCredentials.self, from: credentials.rawData())
    }
}
