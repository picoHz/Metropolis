import XCTest

@testable import Metropolis

final class MediaTests: XCTestCase {
    func testGetMediaConfig() async throws {
        _ = try await getTestAuthClient().getMediaConfig()
    }

    func testGetMediaDownloadUrl() {
        let host = "\(testServerUrl.host!):\(testServerUrl.port!)"
        let serverName = "example.com"
        let mediaId = "PNZkPoKDm6S7WKcbQf42xmAbvvM"
        let url = getAnonClient().getMediaDownloadUrl(serverName: serverName, mediaId: mediaId)
        XCTAssertEqual(
            url.absoluteString, "http://\(host)/_matrix/media/v3/download/\(serverName)/\(mediaId)")
    }

    func testGetMediaThumbnailUrl() {
        let host = "\(testServerUrl.host!):\(testServerUrl.port!)"
        let serverName = "example.com"
        let mediaId = "PNZkPoKDm6S7WKcbQf42xmAbvvM"
        let url = getAnonClient().getMediaThumbnailUrl(serverName: serverName, mediaId: mediaId)
        XCTAssertEqual(
            url.absoluteString, "http://\(host)/_matrix/media/v3/thumbnail/\(serverName)/\(mediaId)"
        )
    }
}
