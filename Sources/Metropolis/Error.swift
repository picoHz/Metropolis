import Foundation
import SwiftyJSON

public struct MPStandardError: Decodable, Error, LocalizedError {
    public var errcode: String
    public var error: String
    public var retryAfterMs: Int?

    public var errorDescription: String? {
        return "[\(errcode)] \(error)"
    }
}
