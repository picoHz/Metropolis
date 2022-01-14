import XCTest

@testable import Metropolis

final class MediaTests: XCTestCase {
    func testGetMediaConfig() async throws {
        _ = try await getTestAuthClient().getMediaConfig()
    }
}
