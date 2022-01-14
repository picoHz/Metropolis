import Foundation
import Get

struct RESTClient {
    let baseUrl: URL
    let accessToken: String?
    private let client: APIClient

    init(baseUrl: URL, accessToken: String?) throws {
        guard let host = baseUrl.host else {
            throw URLError(.badURL)
        }

        var config = APIClient.Configuration(host: host)
        config.port = baseUrl.port

        switch baseUrl.scheme {
        case "https":
            break
        case "http":
            config.isInsecure = true
        default:
            throw URLError(.badURL)
        }

        config.delegate = RESTClientDelegate(baseUrl: baseUrl, accessToken: accessToken)
        config.decoder = sharedJSONDecoder
        config.encoder = sharedJSONEncoder

        self.baseUrl = baseUrl
        self.accessToken = accessToken
        self.client = APIClient(configuration: config)
    }

    public func send<T: Decodable>(_ request: Request<T>) async throws -> Response<T> {
        return try await self.client.send(request)
    }

    @discardableResult public func send(_ request: Request<Void>) async throws -> Response<Void> {
        try await self.client.send(request)
    }
}

private struct RESTClientDelegate: APIClientDelegate {
    public let baseUrl: URL
    public let accessToken: String?

    func client(_ client: APIClient, willSendRequest request: inout URLRequest) async {
        if let url = request.url {
            if var newUrl = URLComponents(
                url: self.baseUrl.appendingPathComponent(url.path), resolvingAgainstBaseURL: false)
            {
                newUrl.query = url.query
                newUrl.fragment = url.fragment
                request.url = newUrl.url
            }
        }
        if let accessToken = self.accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
    }

    func client(
        _ client: APIClient, didReceiveInvalidResponse response: HTTPURLResponse, data: Data
    ) -> Error {
        if response.statusCode == 401 {
            if let state = try? sharedJSONDecoder.decode(MPInteractiveAuthState.self, from: data) {
                return state
            }
        }
        do {
            return try sharedJSONDecoder.decode(MPStandardError.self, from: data)
        }
        catch {
            return error
        }
    }
}

struct SafePath: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    struct StringInterpolation: StringInterpolationProtocol {
        var output = ""

        init(literalCapacity: Int, interpolationCount: Int) {

        }

        mutating func appendLiteral(_ literal: String) {
            output.append(literal)
        }

        mutating func appendInterpolation(_ text: String) {
            if let escaped = text.addingPercentEncoding(
                withAllowedCharacters: CharacterSet.urlPathAllowed)
            {
                output.append(escaped)
            }
        }
    }

    let encoded: String

    init(stringLiteral value: String) {
        encoded = value
    }

    init(stringInterpolation: StringInterpolation) {
        encoded = stringInterpolation.output
    }
}

struct AnyEncodable: Encodable {
    private let value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

let sharedJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

let sharedJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()
